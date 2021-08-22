//
//  TupleExpression.swift
//  TupleExpression
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Foundation

public class TupleExpression: Expression
    {
    public override var displayString: String
        {
        let string = "(" + self.expressions.map{$0.displayString}.joined(separator: ",") + ")"
        return("TUPLE\(string)")
        }
        
    public override var resultType: TypeResult
        {
        return(.class(Tuple(label: Argon.nextName("1TUPLE"))))
        }
        
    private var expressions = Expressions()
    
    public override init()
        {
        super.init()
        }
        
    public func append(_ expression: Expression)
        {
        self.expressions.append(expression)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        }
        
    public override func realize(using realizer:Realizer)
        {
        for expression in self.expressions
            {
            expression.realize(using: realizer)
            }
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        print("TupleExpression NEEDS TO GENERATE CODE")
        }
    }
