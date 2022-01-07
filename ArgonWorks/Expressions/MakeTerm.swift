//
//  MakeTerm.swift
//  MakeTerm
//
//  Created by Vincent Coetzee on 18/8/21.
//

import Foundation

///
///
/// A MakeTerm creates instances of classes. The MakeTerm is of the form
///
/// MAKE(SomeClass,arg1,arg2,arg3)
///
/// After a class is made and the instance actually exists, the compiler
/// will go looking for a method called "initialize", whose arguments most
/// closely match those passed to the MAKE term and then invoke that method
/// passing the arguments ( and the instance ) to that method. The methods
/// are examined at compile time not at runtime, so loading extra methods
/// in at runtime won't cause them to be invoked.
///
/// 
public class MakeTerm: Expression
    {
    private var arguments: Arguments

    required init?(coder: NSCoder)
        {
        self.arguments = coder.decodeArguments(forKey: "arguments")
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encodeArguments(self.arguments,forKey: "arguments")
        }

    public init(type: Type,arguments: Arguments)
        {
        self.arguments = arguments
        super.init()
        self.type = type
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
        let term = MakeTerm(type: substitution.substitute(self.type),arguments: self.arguments.map{substitution.substitute($0)})
        term.type = substitution.substitute(self.type)
        term.issues = self.issues
        return(term as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.arguments = self.arguments.map{$0.initializeType(inContext: context)}
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.arguments.forEach{$0.initializeTypeConstraints(inContext: context)}
        }
        
    public override func visit(visitor: Visitor) throws
        {
        for argument in self.arguments
            {
            try argument.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        if self.type.isGenericClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The class of this MAKE term is an uninstanciated class and can not be used until it is instanciated.")
            }
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
        instance.append(lineNumber: location.line)
        instance.append(.MAKE,.address(self.type.memoryAddress))
        ///
        ///
        /// Need to add the logic for identifying and invoking the appropriate
        /// initialize method.
        ///
        ///
        self._place = .returnValue
        }
    }
