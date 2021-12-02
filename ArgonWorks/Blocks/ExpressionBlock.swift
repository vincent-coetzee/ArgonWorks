//
//  ExpressionBlock.swift
//  ExpressionBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ExpressionBlock: Block
    {
    private var expression:Expression
    public var place: T3AInstruction.Operand = .none
    
    init(_ expression:Expression)
        {
        self.expression = expression
        super.init()
        expression.setParent(self)
        }
        
    public required init?(coder: NSCoder)
        {
        self.expression = Expression()
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.expression = Expression()
        super.init()
        }
        
    internal override func substitute(from: TypeContext.Substitution) -> Self
        {
        ExpressionBlock(from.substitute(self.expression)) as! Self
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        super.analyzeSemantics(using: analyzer)
        self.expression.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        try self.expression.emitCode(into: into,using: using)
        self.place = self.expression.place
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)EXPRESSION BLOCK")
        self.expression.dump(depth: depth+1)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.expression.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
        
    public override func initializeType(inContext: TypeContext) throws
        {
        try self.expression.initializeType(inContext: inContext)
        }
        
    public override func initializeTypeConstraints(inContext: TypeContext) throws
        {
        try self.expression.initializeTypeConstraints(inContext: inContext)
        }
    }
