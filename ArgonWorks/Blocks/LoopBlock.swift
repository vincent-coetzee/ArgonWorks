//
//  LoopBlock.swift
//  LoopBlock
//
//  Created by Vincent Coetzee on 12/8/21.
//

import Foundation

public class LoopBlock: Block,BlockContext,Scope
    {
    public var startExpressions: Array<Expression>!
        {
        didSet
            {
            self.startExpressions.setParent(self)
            }
        }
        
    public var endExpression: Expression!
        {
        didSet
            {
            self.endExpression.setParent(self)
            }
        }
        
    public var updateExpressions: Array<Expression>!
        {
        didSet
            {
            self.updateExpressions.setParent(self)
            }
        }
    
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
        for expression in start
            {
            expression.setParent(self)
            }
        for expression in update
            {
            expression.setParent(self)
            }
        end.setParent(self)
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
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for expression in self.startExpressions
            {
            try expression.initializeTypeConstraints(inContext: context)
            }
        for expression in self.updateExpressions
            {
            try expression.initializeTypeConstraints(inContext: context)
            }
        try self.endExpression.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.endExpression.type,right: context.booleanType,origin: .block(self)))
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
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
        let newStarts = self.startExpressions.map{substitution.substitute($0)}
        let newUpdates = self.updateExpressions.map{substitution.substitute($0)}
        let newEnd = substitution.substitute(endExpression)
        let loop = LoopBlock(start: newStarts, end: newEnd, update: newUpdates)
        for block in self.blocks
            {
            let newBlock = substitution.substitute(block)
            newBlock.type = substitution.substitute(block.type!)
            loop.addBlock(newBlock)
            }
        loop.type = substitution.substitute(self.type!)
        return(loop as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        for expression in self.startExpressions
            {
            try expression.initializeType(inContext: context)
            }
       for expression in self.updateExpressions
            {
            try expression.initializeType(inContext: context)
            }
        try endExpression.initializeType(inContext: context)
        self.type = context.voidType
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
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
        
    public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        for expression in self.startExpressions
            {
            try expression.emitCode(into: buffer, using: using)
            }
        let label = buffer.nextLabel()
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
        buffer.append(nil,"BRLT",.none,.none,.label(label))
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
