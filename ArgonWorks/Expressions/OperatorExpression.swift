//
//  OperatorExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/10/21.
//

import Foundation

public class OperatorExpression: Expression
    {
    private let operation: Operator
    
    init(operation: Operator)
        {
        self.operation = operation
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE OPERATOR EXPRESSION")
        self.operation = coder.decodeObject(forKey: "operation") as! Operator
        super.init(coder: coder)
//        print("END DECODE OPERATOR EXPRESSION")
        }
        
    public override func deepCopy() -> Self
        {
        fatalError()
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.operation,forKey: "operation")
        super.encode(with: coder)
        }
    }
    
public class InfixExpression: OperatorExpression
    {
    private let lhs: Expression
    private let rhs: Expression
    
    init(operation: Operator,lhs: Expression,rhs:Expression)
        {
        self.lhs = lhs
        self.rhs = rhs
        super.init(operation: operation)
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE INFIX EXPRESSION")
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        super.init(coder: coder)
//        print("END DECODE INFIX EXPRESSION")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.rhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.lhs.analyzeSemantics(using: analyzer)
        self.rhs.analyzeSemantics(using: analyzer)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func initializeType(inContext: TypeContext) throws
        {
        try self.lhs.initializeType(inContext: inContext)
        try self.rhs.initializeType(inContext: inContext)
        self.type = self.lhs.type
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.lhs.initializeTypeConstraints(inContext: context)
        try self.rhs.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.lhs.type,right: self.rhs.type,origin: .expression(self)))
        }
    }

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
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.rhs.analyzeSemantics(using: analyzer)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
    }

public class PostfixExpression: OperatorExpression
    {
    private let lhs: Expression
    
    init(operation: Operator,lhs: Expression)
        {
        self.lhs = lhs
        super.init(operation: operation)
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE POSTFX EXPRESSION")
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        super.init(coder: coder)
//        print("END DECODE POSTFIX EXPRESSION")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.lhs,forKey: "lhs")
        super.encode(with: coder)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.lhs.analyzeSemantics(using: analyzer)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
    }
