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
        }
        
    public required init?(coder: NSCoder)
        {
        self.startExpressions = []
        self.endExpression = Expression()
        self.updateExpressions = []
        super.init(coder: coder)
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
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
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
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
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
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)LOOP")
        for expression in self.startExpressions
            {
            expression.dump(depth: depth+1)
            }
        self.endExpression.dump(depth: depth+1)
        for expression in self.updateExpressions
            {
            expression.dump(depth: depth+1)
            }
        for block in self.blocks
            {
            block.dump(depth: depth + 1)
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
