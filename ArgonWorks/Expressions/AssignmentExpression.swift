//
//  AssignmentExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/11/21.
//

import Foundation

public class AssignmentExpression: Expression
    {
    private let rhs: Expression
    private let lhs: Expression
    
    public required init?(coder: NSCoder)
        {
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.rhs,forKey: "rhs")
        coder.encode(self.lhs,forKey: "lhs")
        }

    init(_ lhs:Expression,_ rhs:Expression)
        {
        self.rhs = rhs
        self.lhs = lhs
        super.init()
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        AssignmentExpression(substitution.substitute(self.lhs),substitution.substitute(self.rhs)) as! Self
        }
        
    public override func display(indent: String)
        {
        print("\(indent)ASSIGNMENT EXPRESSION:")
        print("\(indent)LHS: \(self.lhs.type.displayString)")
        self.lhs.display(indent: indent + "\t")
        print("\(indent)RHS: \(self.rhs.type.displayString)")
        self.rhs.display(indent: indent + "\t")
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        self.lhs.type = self.lhs.type.freshTypeVariable(inContext: context)
        self.rhs.type = self.lhs.type.freshTypeVariable(inContext: context)
        context.append(TypeConstraint(left: self.lhs.type,right: self.rhs.type,origin: .expression(self)))
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: context)
        try self.rhs.initializeType(inContext: context)
        self.type = context.voidType
        }

    public override var displayString: String
        {
        return("\(self.lhs.displayString) = \(self.rhs.displayString)")
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.lhs.analyzeSemantics(using: analyzer)
        self.rhs.analyzeSemantics(using: analyzer)
        }
    }
