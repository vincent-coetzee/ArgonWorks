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
    private var initializer: Initializer?
    
    required init?(coder: NSCoder)
        {
        self.arguments = coder.decodeArguments(forKey: "arguments")
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.arguments,forKey: "arguments")
        }

    public init(type: Type,arguments: Arguments)
        {
        self.arguments = arguments
        super.init()
        self.type = type
        for argument in arguments
            {
            argument.value.setParent(self)
            }
        if self.type!.isClass && !self.type!.classValue.initializers.isEmpty
            {
            self.initializer = self.type!.classValue.mostSpecificInitializer(forArguments: self.arguments)
            }
        }
        
    public override func display(indent: String)
        {
        print("\(indent)TYPE INSTANCIATION \(self.type.displayString)")
        print("\(indent)ARGUMENTS:")
        for argument in self.arguments
            {
            print("\(indent)\t\(argument.tag ?? "") \(argument.value.type.displayString)")
            argument.value.display(indent: indent + "\t")
            }
        }
        
    public override var displayString: String
        {
        let string = "[" + self.arguments.displayString + "]"
        return("MAKE(\(self.type.displayString),\(string))")
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        TypeInstanciationTerm(type: substitution.substitute(self.type!),arguments: self.arguments.map{substitution.substitute($0)}) as! Self
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        if self.initializer.isNotNil
            {
            try self.initializer!.initializeType(inContext: context)
            try self.initializer!.parameters.forEach{try $0.initializeType(inContext: context)}
            }
        self.arguments = try self.arguments.map{try $0.initializeType(inContext: context)}
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.arguments.forEach{try $0.initializeTypeConstraints(inContext: context)}
        if self.initializer.isNotNil
            {
            for (argument,parameter) in zip(self.arguments,self.initializer!.parameters)
                {
                context.append(SubTypeConstraint(subtype: argument.value.type,supertype: parameter.type,origin: .expression(self)))
                }
            }
        if let className = self.initializer?.declaringClass?.fullName,let aType = self.enclosingScope.lookup(name: className) as? Type
            {
            context.append(TypeConstraint(left: self.type,right: aType,origin: .expression(self)))
            context.append(TypeConstraint(left: self.type,right: TypeConstructor(label: className.displayString,generics: self.initializer!.parameters.map{$0.type!}),origin: .expression(self)))
            }
        }
        
    public override func visit(visitor: Visitor) throws
        {
        for argument in self.arguments
            {
            try argument.visit(visitor: visitor)
            }
        if self.initializer.isNotNil
            {
            try initializer!.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        if self.type!.isGenericClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The class of this MAKE term is an uninstanciated class and can not be used until it is instanciated.")
            }
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type?.lookup(label: label))
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
