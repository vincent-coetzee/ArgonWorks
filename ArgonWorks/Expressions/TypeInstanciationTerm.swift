//
//  MakeTerm.swift
//  MakeTerm
//
//  Created by Vincent Coetzee on 18/8/21.
//

import Foundation

public class TypeInstanciationTerm: Expression
    {
    private var arguments: Arguments
    
    required init?(coder: NSCoder)
        {
        self.arguments = coder.decodeArguments(forKey: "arguments")
        self._type = Type()
        super.init(coder: coder)
        self._type = type
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.arguments,forKey: "arguments")
        }
        
    private var _type: Type
    
    public init(type: Type,arguments: Arguments)
        {
        self.arguments = arguments
        self._type = type
        super.init()
        for argument in arguments
            {
            argument.value.setParent(self)
            }
        self.type = type
        }
        
    public override var displayString: String
        {
        let string = "[" + self.arguments.displayString + "]"
        return("MAKE(\(self.type.displayString),\(string))")
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        self.arguments = try self.arguments.map{try $0.initializeType(inContext: context)}
        self.type = self._type
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        print(" ")
        }
        
    public override func visit(visitor: Visitor) throws
        {
        for argument in self.arguments
            {
            try argument.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func deepCopy() -> Self
        {
        let copy = super.deepCopy()
        copy.arguments = self.arguments.map{$0.deepCopy()}
        return(copy)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        if self.type.isGenericClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The class of this MAKE term is an uninstanciated class and can not be used until it is instanciated.")
            }
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type.lookup(label: label))
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
//        guard let location = self.declaration else
//            {
//            print("WARNING: CAN NOT FIND LOCATION FOR \(self)")
//            return
//            }
//        var count:Argon.Integer = 1
//        instance.append(lineNumber: location.line)
//        for argument in self.arguments.reversed()
//            {
//            try argument.value.emitCode(into: instance,using: generator)
//            instance.append(nil,"PUSH",argument.value.place,.none,.none)
//            count += 1
//            }
//        instance.append(nil,"PUSH",.relocatable(.type(self.type)),.none,.none)
//        instance.append(nil,"CALL",.relocatable(.function(Function(label: "MAKE"))),.none,.none)
//        instance.append("ADD",.stackPointer,.literal(.integer(count * 8)),.stackPointer)
//        if self._type.isClass && !self._type.classValue.initializers.isEmpty
//            {
//            let temp = instance.nextTemporary()
//            instance.append("MOV",.returnRegister,.none,temp)
//            instance.append("PUSH",.returnRegister,.none,.none)
//            let initializer = self._type.classValue.initializers.first!
//            instance.append("CALL",.relocatable(.function(initializer)),.none,.none)
//            instance.append("ADD",.stackPointer,.literal(.integer(8)),.stackPointer)
//            self._place = temp
//            }
//        else
//            {
//            self._place = .returnRegister
//            }
        }
    }
