//
//  Method.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import AppKit

public class Method:Symbol
    {
    public override var allNamedInvokables: Array<NamedInvokable>
        {
        return(self.instances.map{NamedInvokable(fullName: $0.fullName, invokable: $0)})
        }
        
    public override var isInvokable: Bool
        {
        return(true)
        }
        
    public override var isLiteral: Bool
        {
        return(true)
        }
        
    public override var asLiteralExpression: LiteralExpression?
        {
        return(LiteralExpression(.method(self)))
        }
        
    public var maximumInstanceArity: Int
        {
        max(self.instances.map{$0.arity})
        }
        
    public override var canBecomeAType: Bool
        {
        return(true)
        }
        
    public var isSystemMethod: Bool
        {
        return(false)
        }

    public var genericMethodInstances: MethodInstances
        {
//        self.instances.filter{$0.hasGenericParameter}
        fatalError()
        }
        
    public var isMainMethod: Bool = false
    public var returnType: Type = Type.unknown
    public var proxyParameters = Parameters()
    public var isGenericMethod = false
    public var isIntrinsic = false
    
    public private(set) var instances = MethodInstances()
    
    public required init?(coder: NSCoder)
        {
//        print("START DECODE METHOD")
        self.isMainMethod = coder.decodeBool(forKey: "isMainMethod")
        self.returnType = coder.decodeObject(forKey: "returnType") as! Type
        self.proxyParameters = coder.decodeObject(forKey: "proxyParameters") as! Parameters
        self.isGenericMethod = coder.decodeBool(forKey: "isGenericMethod")
        self.isIntrinsic = coder.decodeBool(forKey: "isIntrinsic")
        self.instances = coder.decodeObject(forKey: "instances") as! MethodInstances
        super.init(coder: coder)
//        print("END DECODE METHOD \(self.label)")
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        #if DEBUG
//        print("ENCODE METHOD \(self.label)")
        #endif
        coder.encode(self.isMainMethod,forKey: "isMainMethod")
        coder.encode(self.returnType,forKey: "returnType")
        coder.encode(self.proxyParameters,forKey: "proxyParameters")
        coder.encode(self.isGenericMethod,forKey: "isGenericMethod")
        coder.encode(self.isIntrinsic,forKey: "isIntrinsic")
        coder.encode(self.instances,forKey: "instances")
        super.encode(with: coder)
        }
        
    public class func method(label:String) -> Method
        {
        return(Method(label:label))
        }
        
    public func instancesWithArity(_ arity:Int) -> MethodInstances
        {
        self.instances.filter{$0.arity == arity}
        }
        
    public override var iconName: String
        {
        "IconMethod"
        }
        
    public override var symbolColor: NSColor
        {
        .argonPink
        }
        
    public override var children: Array<Symbol>
        {
        return(self.instances)
        }
        
    public override var allChildren: Array<Symbol>
        {
        return(self.instances)
        }
        
    public override var isExpandable: Bool
        {
        return(self.instances.count > 0)
        }
        
    public override func analyzeSemantics(using: SemanticAnalyzer)
        {
        for instance in self.instances
            {
            instance.analyzeSemantics(using: using)
            }
        }
        
    public override func visit(visitor: Visitor) throws
        {
        for instance in self.instances
            {
            try instance.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        for instance in self.instances
            {
            try instance.emitCode(using: generator)
            }
        }
        
    public override func dump(depth: Int)
        {
        let string = String(repeating: "\t", count: depth)
        print("\(string)\(Swift.type(of: self)) \(self.label)")
        for instance in self.instances
            {
            instance.dump(depth: depth + 1)
            }
        }
        
    public func instance(_ types:Type...,returnType:Type = VoidClass.voidClass.type) -> Method
        {
        let instance = MethodInstance(label: self.label)
        var parameters = Parameters()
        var index = 0
        for type in types
            {
            parameters.append(Parameter(label: "_\(index)",type:type))
            index += 1
            }
        instance.parameters = parameters
        instance.returnType = returnType
        self.addInstance(instance)
        return(self)
        }

    public func hasInstanceWithSameSignature(as instance: MethodInstance) -> Bool
        {
        let signature = instance.typeSignature
        for anInstance in self.instances
            {
            if anInstance.typeSignature == signature && anInstance.index != instance.index
                {
                return(true)
                }
            }
        return(false)
        }

    public func mostSpecificInstance(forTypes: Types) -> MethodInstance?
        {
        var actualInstances = self.eliminateImpossibleMethodInstances(forTypes: forTypes)
        actualInstances.sort{$0.moreSpecific(than: $1, forTypes: forTypes)}
        return(actualInstances.last)
        }
        
    private func eliminateImpossibleMethodInstances(forTypes types: Types) -> MethodInstances
        {
        let count = types.count
        return(self.instances.filter{$0.parameters.count == count && $0.parameterTypesAreSupertypes(ofTypes: types)})
        }
        
    public func addInstance(_ instance:MethodInstance)
        {
        if self.isMainMethod
            {
            self.instances = [instance]
            }
        else
            {
            self.instances.append(instance)
            }
        instance.setParent(self)
        self.proxyParameters = instance.parameters
        self.returnType = instance.returnType
        }
        
    public func filledInTagSignature(forArguments: Arguments) -> TagSignature?
        {
        let incoming = TagSignature(arguments: forArguments)
        let some = self.instances.filter{$0.tagSignature == incoming}
        guard !some.isEmpty else
            {
            return(nil)
            }
        return(some.first!.tagSignature.withArguments(forArguments))
        }
        
    public override func initializeType(inContext: TypeContext) throws
        {
        for instance in self.instances
            {
            try instance.initializeType(inContext: inContext)
            }
        }
        
    public override func initializeTypeConstraints(inContext: TypeContext) throws
        {
        for instance in self.instances
            {
            try instance.initializeTypeConstraints(inContext: inContext)
            }
        }
    }

extension Array
    {
    func containsNil<Item>() -> Bool where Element == Optional<Item>
        {
        self.filter{$0.isNil}.count > 0
        }
    }
    
public typealias Methods = Array<Method>
