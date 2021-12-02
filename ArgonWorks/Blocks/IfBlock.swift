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
        
    private var condition:Expression
    
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
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)IF")
        condition.dump(depth: depth+1)
        for block in self.blocks
            {
            block.dump(depth: depth + 1)
            }
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        IfBlock(condition: substitution.substitute(self.condition)) as! Self
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
    
