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
    public override var asLiteralExpression: LiteralExpression?
        {
        return(LiteralExpression(.method(self)))
        }
        
    public override var type: Type
        {
        get
            {
            return(.method(self))
            }
        set
            {
            }
        }
        
    public var maximumInstanceArity: Int
        {
        max(self.instances.map{$0.arity})
        }
        
    public override var canBecomeAType: Bool
        {
        return(true)
        }
        
    public var methodSignatures: MethodSignatures
        {
        self.instances.map{$0.methodSignature}
        }
        
    public var isSystemMethod: Bool
        {
        return(false)
        }

    public var isMain: Bool = false
    public var returnType: Type = .class(VoidClass.voidClass)
    public var proxyParameters = Parameters()
    public var dispatchRootNode: DispatchRootNode?
    public var isGenericMethod = false
    public var isIntrinsic = false
    
    public private(set) var instances = MethodInstances()
    
    public required init?(coder: NSCoder)
        {
        self.isMain = coder.decodeBool(forKey: "isMain")
        self.returnType = coder.decodeType(forKey: "returnType")!
        self.proxyParameters = coder.decodeObject(forKey: "proxyParameters") as! Parameters
        self.isGenericMethod = coder.decodeBool(forKey: "isGenericMethod")
        self.isIntrinsic = coder.decodeBool(forKey: "isIntrinsic")
        self.instances = coder.decodeObject(forKey: "instances") as! MethodInstances
        super.init(coder: coder)
        }
        
    public override init(label: Label)
        {
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        print("ENCODE METHOD \(self.label)")
        super.encode(with: coder)
        coder.encode(self.isMain,forKey: "isMain")
        coder.encodeType(self.returnType,forKey: "returnType")
        coder.encode(self.proxyParameters,forKey: "proxyParameters")
        coder.encode(self.isGenericMethod,forKey: "isGenericMethod")
        coder.encode(self.isIntrinsic,forKey: "isIntrinsic")
        coder.encode(self.instances,forKey: "instances")
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
        
    public override var children: Array<Symbol>?
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
        
    public override func realize(using realizer: Realizer)
        {
        for instance in self.instances
            {
            instance.realize(using: realizer)
            }
        }
        
    public override func analyzeSemantics(using: SemanticAnalyzer)
        {
        for instance in self.instances
            {
            instance.analyzeSemantics(using: using)
            }
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        for instance in self.instances
            {
            try instance.emitCode(using: generator)
            }
        }
        
    public func instance(_ types:Type...,returnType:Type = .class(VoidClass.voidClass)) -> Method
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
        
    @discardableResult
    public func validateInvocation(location:Location,arguments:Arguments,reportingContext: ReportingContext) -> Bool
        {
        var parameterSetMatchCount = 0
        for instance in self.instances
            {
            if instance.parameters.count != arguments.count
                {
                reportingContext.dispatchError(at: location,message: "Invocation of multimethod '\(self.label)' has a different parameter count to the definition.")
                }
            parameterSetMatchCount += instance.isParameterSetCoherent(with: arguments) ? 1 : 0
            }
        if parameterSetMatchCount == 0
            {
            reportingContext.dispatchError(at: location,message: "A specific instance of the multimethod '\(self.label)' can not be found, therefore this invocation can not be dispatched.")
            return(false)
            }
        return(true)
        }
        
    public func buildDispatchTree(reportingContext: ReportingContext)
        {
        }
        
    public func dispatch(with classes: Types) -> MethodInstance?
        {
        return(self.dispatchRootNode?.dispatch(with: classes))
        }
        
    public func addInstance(_ instance:MethodInstance)
        {
        if self.isMain
            {
            self.instances = [instance]
            }
        else
            {
            self.instances.append(instance)
            }
        instance.setParent(self)
        self.proxyParameters = instance.parameters
        }
        
    public func mostSpecificInstance(for arguments:Arguments) -> MethodInstance?
        {
        if self.instances.isEmpty
            {
            return(nil)
            }
        let types = arguments.resultTypes
        if types.isUnknown
            {
            return(nil)
            }
        let classes = types.map{$0}
        let scores = self.instances.map{$0.dispatchScore(for: classes)}
        var lowest:Int? = nil
        var selectedInstance:MethodInstance?
        for (instance,score) in zip(self.instances,scores)
            {
            if lowest.isNil
                {
                lowest = score
                selectedInstance = instance
                }
            else if score < lowest!
                {
                lowest = score
                selectedInstance = instance
                }
            }
        return(selectedInstance)
        }
        
    public func dump()
        {
        for instance in self.instances
            {
            instance.dump()
            }
        }
    }

    
public typealias Methods = Array<Method>

extension Types
    {
    public var isUnknown: Bool
        {
        for type in self
            {
            if type.isUnknown
                {
                return(true)
                }
            }
        return(false)
        }
    }
