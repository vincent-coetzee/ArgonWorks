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
        self.initializer = coder.decodeObject(forKey: "initializer") as? Initializer
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encodeArguments(self.arguments,forKey: "arguments")
        coder.encode(self.initializer,forKey: "initializer")
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
        let term = TypeInstanciationTerm(type: substitution.substitute(self.type)!,arguments: self.arguments.map{substitution.substitute($0)})
        term.type = substitution.substitute(self.type!)
        term.issues = self.issues
        return(term as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        if self.initializer.isNotNil
            {
            self.initializer!.initializeType(inContext: context)
            self.initializer!.parameters.forEach{$0.initializeType(inContext: context)}
            }
        self.arguments = self.arguments.map{$0.initializeType(inContext: context)}
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.arguments.forEach{$0.initializeTypeConstraints(inContext: context)}
        if self.type!.isClass && !self.type!.classValue.initializers.isEmpty
            {
            self.initializer = self.type!.classValue.mostSpecificInitializer(forArguments: self.arguments,inContext: context)
            }
        if self.initializer.isNotNil
            {
            for (argument,parameter) in zip(self.arguments,self.initializer!.parameters)
                {
                context.append(SubTypeConstraint(subtype: argument.value.type,supertype: parameter.type,origin: .expression(self)))
                }
            context.append(TypeConstraint(left: self.type,right: self.initializer?.declaringType,origin: .expression(self)))
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
        
    public override func emitValueCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        try self.emitCode(into: instance,using: generator)
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        guard let location = self.declaration else
            {
            print("WARNING: CAN NOT FIND LOCATION FOR \(self)")
            return
            }
        var count:Argon.Integer = 1
        instance.append(lineNumber: location.line)
        instance.append(nil,"MAKE",.relocatable(.address(self.type!.memoryAddress)),.none,.none)
        if let initializer = self.initializer
            {
            let temp = instance.nextTemporary()
            for argument in self.arguments.reversed()
                {
                try argument.value.emitCode(into: instance,using: generator)
                instance.append(nil,"PUSH",argument.value.place,.none,.none)
                count += 1
                }
            instance.append("PUSH",.returnRegister,.none,.none)
            instance.append("CALL",.relocatable(.address(initializer.memoryAddress)),.none,.none)
            instance.append("ADD",.stackPointer,.literal(.integer(8 * count)),.stackPointer)
            self._place = temp
            }
        else
            {
            self._place = .returnRegister
            }
        }
    }
