//
//  LoopBlock.swift
//  LoopBlock
//
//  Created by Vincent Coetzee on 12/8/21.
//

import Foundation

public class LoopBlock: Block
    {
    public var startExpressions: Array<Expression>!
    public var endExpression: Expression!        
    public var updateExpressions: Array<Expression>!
    
    required init()
        {
        super.init()
        }
        
    init(start: Array<Expression>,end: Expression,update: Array<Expression>)
        {
        self.startExpressions = start
        self.endExpression = end
        self.updateExpressions = update
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.startExpressions = (coder.decodeObject(forKey: "startExpressions") as! Expressions)
        self.endExpression = (coder.decodeObject(forKey: "endExpression") as! Expression)
        self.updateExpressions = (coder.decodeObject(forKey: "updateExpressions") as! Expressions)
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.startExpressions,forKey: "startExpressions")
        coder.encode(self.endExpression,forKey: "endExpression")
        coder.encode(self.updateExpressions,forKey: "updateExpressions")
        super.encode(with: coder)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.startExpressions.visit(visitor: visitor)
        try self.endExpression?.visit(visitor: visitor)
        try self.updateExpressions.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let starts = self.startExpressions.map{$0.freshTypeVariable(inContext: context)}
        let updates = self.updateExpressions.map{$0.freshTypeVariable(inContext: context)}
        let end = self.endExpression.freshTypeVariable(inContext: context)
        let block = LoopBlock(start: starts, end: end, update: updates)
        for innerBlock in self.blocks
            {
            block.addBlock(innerBlock.freshTypeVariable(inContext: context))
            }
        block.type = self.type.freshTypeVariable(inContext: context)
        return(block as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        for expression in self.startExpressions
            {
            expression.initializeTypeConstraints(inContext: context)
            }
        for expression in self.updateExpressions
            {
            expression.initializeTypeConstraints(inContext: context)
            }
        self.endExpression.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.endExpression.type,right: ArgonModule.shared.boolean,origin: .block(self)))
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        }
        
    public override func display(indent: String)
        {
        print("\(indent)\(Swift.type(of: self))")
        print("\(indent)START:")
        for expression in self.startExpressions
            {
            expression.display(indent: indent + "\t")
            }
        print("\(indent)END:")
        self.endExpression.display(indent: indent + "\t")
        print("\(indent)UPDATE:")
        for expression in self.updateExpressions
            {
            expression.display(indent: indent + "\t")
            }
        for block in self.blocks
            {
            block.display(indent: indent + "\t")
            }
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let newBlock = super.substitute(from: substitution)
        newBlock.startExpressions = self.startExpressions.map{substitution.substitute($0)}
        newBlock.updateExpressions = self.updateExpressions.map{substitution.substitute($0)}
        newBlock.endExpression = substitution.substitute(self.endExpression)
        for block in self.blocks
            {
            newBlock.addBlock(substitution.substitute(block))
            }
        newBlock.type = substitution.substitute(self.type)
        return(newBlock)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        for expression in self.startExpressions
            {
            expression.initializeType(inContext: context)
            }
       for expression in self.updateExpressions
            {
            expression.initializeType(inContext: context)
            }
        self.endExpression.initializeType(inContext: context)
        self.type = context.voidType
        for block in self.blocks
            {
            block.initializeType(inContext: context)
            }
        }
        
   public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for expression in startExpressions
            {
            expression.analyzeSemantics(using: analyzer)
            }
        self.endExpression.analyzeSemantics(using: analyzer)
        for expression in updateExpressions
            {
            expression.analyzeSemantics(using: analyzer)
            }
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        for expression in self.startExpressions
            {
            try expression.emitCode(into: buffer, using: using)
            }
        let label = buffer.nextLabel
        buffer.pendingLabel = label
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: using)
            }
        for expression in self.updateExpressions
            {
            try expression.emitCode(into: buffer,using: using)
            }
        try self.endExpression.emitCode(into: buffer,using: using)
        buffer.add(.BRF,self.endExpression.place,label.operand)
        }
    }

extension Array where Element:Expression
    {
    public func visit(visitor: Visitor) throws
        {
        for expression in self
            {
            try expression.visit(visitor: visitor)
            }
        }
    }
