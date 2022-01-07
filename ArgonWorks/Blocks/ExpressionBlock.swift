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
        }
        
    public required init?(coder: NSCoder)
        {
        self.expression = coder.decodeObject(forKey: "expression") as! Expression
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.expression = Expression()
        super.init()
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.expression,forKey: "expression")
        super.encode(with: coder)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let newBlock = ExpressionBlock(self.expression.freshTypeVariable(inContext: context))
        newBlock.setIndex(self.index)
        for block in self.blocks
            {
            newBlock.addBlock(block.freshTypeVariable(inContext: context))
            }
        newBlock.type = self.type.freshTypeVariable(inContext: context)
        return(newBlock as! Self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)EXPRESSION BLOCK \(Swift.type(of: self))")
        print("\(indent)EXPRESSION:")
        self.expression.display(indent: indent + "\t")
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let block = ExpressionBlock(substitution.substitute(self.expression))
        block.type = substitution.substitute(self.type)
        block.issues = self.issues
        return(block as! Self)
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
        
    public override func visit(visitor: Visitor) throws
        {
        try self.expression.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
        
    public override func initializeType(inContext: TypeContext)
        {
        self.expression.initializeType(inContext: inContext)
        self.type = self.expression.type
        }
        
    public override func initializeTypeConstraints(inContext: TypeContext)
        {
        self.expression.initializeTypeConstraints(inContext: inContext)
        }
    }
