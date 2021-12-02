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
        self.condition = Expression()
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.condition = Expression()
        super.init()
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.condition.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.condition.initializeType(inContext: context)
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
        self.type = self.condition.type
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.condition.initializeTypeConstraints(inContext: context)
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        WhenBlock(condition: substitution.substitute(self.condition)) as! Self
        }
    }
    
