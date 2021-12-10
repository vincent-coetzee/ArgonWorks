//
//  InfixExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/12/21.
//

import Foundation

public class InfixExpression: OperatorExpression
    {
    private let lhs: Expression
    private let rhs: Expression
    
    public init(operatorLabel: Label,operators: MethodInstances,lhs: Expression,rhs: Expression)
        {
        self.lhs = lhs
        self.rhs = rhs
        super.init(operatorLabel: operatorLabel,operators:  operators)
        self.lhs.setParent(self)
        self.rhs.setParent(self)
        }
        
    public override var displayString: String
        {
        return("\(self.lhs.displayString) \(self.operatorLabel) \(self.rhs.displayString)")
        }
        
    required init?(coder: NSCoder)
        {
        self.lhs = coder.decodeObject(forKey:"lhs") as! Expression
        self.rhs = coder.decodeObject(forKey:"rhs") as! Expression
        super.init(coder: coder)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.rhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: context)
        try self.rhs.initializeType(inContext: context)
        if !operators.isEmpty
            {
            self.type = operators.first!.returnType
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "The operator '\(self.operatorLabel)' of the correct type can not be resolved.")
            self.type = context.voidType
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = InfixExpression(operatorLabel: self.operatorLabel,operators: self.operators,lhs: substitution.substitute(self.lhs),rhs: substitution.substitute(self.rhs))
        expression.type = substitution.substitute(self.type!)
        expression.issues = self.issues
        return(expression as! Self)
        }
    }

