//
//  IfBlock.swift
//  IfBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class IfBlock: Block
    {
    public override var displayString: String
        {
        "IFBlock " + self.condition.displayString  + " " + self.elseBlock.displayString
        }
        
    internal var condition:Expression
    
    internal var elseBlock: Block?
        {
        didSet
            {
            self.elseBlock?.setParent(self)
            }
        }
    
    public init(condition: Expression)
        {
        self.condition = condition
        super.init()
        self.condition.setParent(self)
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
        
    public override func display(indent: String)
        {
        print("\(indent)IF \(Swift.type(of: self))")
        self.condition.display(indent: indent + "\t")
        for block in self.blocks
            {
            block.display(indent: indent + "\t")
            }
        self.elseBlock?.display(indent: indent + "\t")
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let ifBlock = IfBlock(condition: substitution.substitute(self.condition))
        for block in self.blocks
            {
            ifBlock.addBlock(substitution.substitute(block))
            }
        ifBlock.type = substitution.substitute(self.type!)
        return(ifBlock as! Self)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let ifBlock = IfBlock(condition: self.condition.freshTypeVariable(inContext: context))
        for block in self.blocks
            {
            ifBlock.addBlock(block.freshTypeVariable(inContext: context))
            }
        ifBlock.type = self.type!.freshTypeVariable(inContext: context)
        return(ifBlock as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.condition.initializeType(inContext: context)
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
        try self.elseBlock?.initializeType(inContext: context)
        self.type = context.voidType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.condition.initializeTypeConstraints(inContext: context)
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        try self.elseBlock?.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.condition.type,right: context.booleanType,origin: .block(self)))
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.condition.visit(visitor: visitor)
        try self.elseBlock?.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
        
   public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.condition.analyzeSemantics(using: analyzer)
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        self.elseBlock?.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        let outLabel = buffer.nextLabel()
        try self.condition.emitCode(into: buffer,using: using)
        buffer.append(nil,"BRF",self.condition.place,.none,.label(outLabel))
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: using)
            }
        if self.elseBlock.isNotNil
            {
            buffer.pendingLabel = outLabel
            try self.elseBlock!.emitCode(into: buffer,using: using)
            }
        else
            {
            buffer.pendingLabel = outLabel
            }
        }
    }
    
