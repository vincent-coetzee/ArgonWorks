//
//  MakeTerm.swift
//  MakeTerm
//
//  Created by Vincent Coetzee on 18/8/21.
//

import Foundation

public class ClassInstanciationTerm: Expression
    {
    private let type: Class
    private let arguments: Arguments
    
    public init(type: Class,arguments: Arguments)
        {
        self.type = type
        self.arguments = arguments
        super.init()
        for argument in arguments
            {
            argument.value.setParent(self)
            }
        }
        
    public override var displayString: String
        {
        let string = "[" + self.arguments.displayString + "]"
        return("MAKE(\(self.type.displayString),\(string))")
        }
        
    public override var resultType: TypeResult
        {
        return(.class(self.type))
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        if self.type.isGenericClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration, message: "The class of this MAKE term is an uninstanciated class and can not be used until it is instanciated.")
            }
        }
        
    public override func realize(using realizer:Realizer)
        {
        self.type.realize(using: realizer)
        for argument in self.arguments
            {
            argument.value.realize(using: realizer)
            }
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        print("MakeExpression NEEDS TO GENERATE CODE")
        }
    }
