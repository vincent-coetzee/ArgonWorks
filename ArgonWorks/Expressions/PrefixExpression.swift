//
//  PrefixExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/12/21.
//

import Foundation

public class PrefixExpression: OperatorExpression
    {
    private let rhs: Expression
    
    init(operation: Operator,rhs: Expression)
        {
        self.rhs = rhs
        super.init(operation: operation)
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE PREFIX EXPRESSION")
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        super.init(coder: coder)
//        print("END DECODE INFIX EXPRESSION")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.rhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)PREFIX EXPRESSION: \(self.operation.label)")
        print("\(indent)RHS:")
        self.rhs.display(indent: indent + "\t")
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.rhs.analyzeSemantics(using: analyzer)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.rhs.initializeType(inContext: context)
        self.type = self.operation.returnType.freshTypeVariable(inContext: context)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = PrefixExpression(operation: self.operation,rhs: substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type!)
        return(expression as! Self)
        }
    }

