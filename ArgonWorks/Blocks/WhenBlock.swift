//
//  WhenBlock.swift
//  WhenBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class WhenBlock: Block
    {
    public var conditionPlace: T3AInstruction.Operand
        {
        return(self.condition.place)
        }
        
    public let condition: Expression
    
    init(condition: Expression)
        {
        self.condition = condition
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.condition = coder.decodeObject(forKey: "condition") as! Expression
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.condition = Expression()
        super.init()
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.condition,forKey: "condition")
        super.encode(with: coder)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.condition.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let block = WhenBlock(condition: self.condition.freshTypeVariable(inContext: context))
        for innerBlock in self.blocks
            {
            block.addBlock(innerBlock.freshTypeVariable(inContext: context))
            }
        block.type = self.type.freshTypeVariable(inContext: context)
        return(block as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.condition.initializeType(inContext: context)
        for block in self.blocks
            {
            block.initializeType(inContext: context)
            }
        self.type = context.voidType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.condition.initializeTypeConstraints(inContext: context)
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let when = WhenBlock(condition: substitution.substitute(self.condition))
        for block in self.blocks
            {
            when.addBlock(substitution.substitute(block))
            }
        when.type = self.type
        return(when as! Self)
        }
    }
    
