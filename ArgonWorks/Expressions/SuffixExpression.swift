//
//  SuffixExpression.swift
//  SuffixExpression
//
//  Created by Vincent Coetzee on 10/8/21.
//

import Foundation

public class SuffixExpression: Expression
    {
    public override var resultType: Type
        {
        return(self.expression.resultType)
        }
        
    public override var displayString: String
        {
        return("\(self.expression.displayString) \(self.operation)")
        }
        
    public let operation: Token.Operator
    public let expression: Expression
    
    init(_ expression:Expression,_ operation:Token.Operator)
        {
        self.operation = operation
        self.expression = expression
        super.init()
        self.expression.setParent(self)
        }
        
    public override func realize(using realizer: Realizer)
        {
        self.expression.realize(using: realizer)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.expression.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        try self.expression.emitCode(into: instance,using: using)
        switch(self.operation.name)
            {
            case "++":
                instance.append(.INC,self.expression.place,.none,self.expression.place)
            case "--":
                instance.append(.DEC,self.expression.place,.none,self.expression.place)
            default:
                break
            }
        }
    }
