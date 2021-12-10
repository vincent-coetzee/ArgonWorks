//
//  WhileBlock.swift
//  WhileBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class WhileBlock: Block,StackFrame,Scope
    {
    private let condition:Expression
    
    init(condition: Expression)
        {
        self.condition = condition
        super.init()
        self.condition.setParent(self)
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
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.condition.initializeTypeConstraints(inContext: context)
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        context.append(TypeConstraint(left: self.condition.type,right: context.booleanType,origin: .block(self)))
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.condition.initializeType(inContext: context)
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
        self.type = context.voidType
        }
        
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        let startLabel = buffer.nextLabel()
        let endLabel = buffer.nextLabel()
        buffer.pendingLabel = startLabel
        try self.condition.emitCode(into: buffer,using: generator)
        buffer.append(nil,"BRF",self.condition.place,.none,.label(endLabel))
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: generator)
            }
        buffer.append(nil,"BR",.none,.none,.label(startLabel))
        buffer.pendingLabel = endLabel
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let aBlock = WhileBlock(condition: substitution.substitute(self.condition))
        aBlock.type = substitution.substitute(self.type!)
        for block in self.blocks
            {
            aBlock.addBlock(substitution.substitute(block))
            }
        return(aBlock as! Self)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.condition.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
    }
