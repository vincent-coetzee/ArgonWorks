//
//  WhileBlock.swift
//  WhileBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class WhileBlock: Block
    {
    private var condition:Expression
    
    init(condition: Expression)
        {
        self.condition = condition
        super.init()
        condition.container = .block(self)
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
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.condition,forKey: "condition")
        super.encode(with: coder)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)WHILE: \(Swift.type(of: self))")
        print("\(indent)CONDITION: \(self.condition.type.displayString)")
        self.condition.display(indent: indent + "\t")
        for block in self.blocks
            {
            block.display(indent: indent + "\t")
            }
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let block = WhileBlock(condition: self.condition.freshTypeVariable(inContext: context))
        for innerBlock in self.blocks
            {
            block.addBlock(innerBlock.freshTypeVariable(inContext: context))
            }
        block.type = self.type.freshTypeVariable(inContext: context)
        return(block as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.condition.initializeTypeConstraints(inContext: context)
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        context.append(TypeConstraint(left: self.condition.type,right: context.booleanType,origin: .block(self)))
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
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        let startLabel = buffer.nextLabel
        let endLabel = buffer.nextLabel
        buffer.pendingLabel = startLabel
        try self.condition.emitCode(into: buffer,using: generator)
        buffer.add(.BRF,self.condition.place,endLabel.operand)
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: generator)
            }
        buffer.add(.BR,startLabel.operand)
        buffer.pendingLabel = endLabel
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let newBlock = super.substitute(from: substitution)
        newBlock.condition = substitution.substitute(self.condition)
        for block in self.blocks
            {
            newBlock.addBlock(substitution.substitute(block))
            }
        return(newBlock)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.condition.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
    }
