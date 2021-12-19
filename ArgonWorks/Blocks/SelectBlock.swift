//
//  SelectBlock.swift
//  SelectBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class SelectBlock: Block
    {
    private let value:Expression
    private var whenBlocks:Array<WhenBlock> = []
    public var otherwiseBlock: OtherwiseBlock?
    
    init(value: Expression)
        {
        self.value = value
        whenBlocks = Array<WhenBlock>()
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.value = coder.decodeObject(forKey: "value") as! Expression
        self.whenBlocks = coder.decodeObject(forKey: "whenBlocks") as! Array<WhenBlock>
        self.otherwiseBlock = coder.decodeObject(forKey: "otherwiseBlock") as? OtherwiseBlock
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.value,forKey: "value")
        coder.encode(self.whenBlocks,forKey: "whenBlocks")
        coder.encode(self.otherwiseBlock,forKey: "otherwiseBlock")
        super.encode(with: coder)
        }
        
    public required init()
        {
        self.value = Expression()
        super.init()
        }
        
    public func addWhen(block: WhenBlock)
        {
        self.whenBlocks.append(block)
        }
        
    public func addOtherwise(block: OtherwiseBlock)
        {
        self.otherwiseBlock = block
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.value.visit(visitor: visitor)
        for when in self.whenBlocks
            {
            try when.visit(visitor: visitor)
            }
        try self.otherwiseBlock?.visit(visitor: visitor)
        try super.visit(visitor: visitor)
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        SelectBlock(value: substitution.substitute(self.value)) as! Self
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let block = SelectBlock(value: self.value.freshTypeVariable(inContext: context))
        for innerBlock in self.blocks
            {
            block.addBlock(innerBlock.freshTypeVariable(inContext: context))
            }
        block.type = self.type?.freshTypeVariable(inContext: context)
        return(block as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.value.initializeTypeConstraints(inContext: context)
        for block in self.whenBlocks
            {
            block.initializeTypeConstraints(inContext: context)
            context.append(TypeConstraint(left: self.value.type,right: block.condition.type,origin: .block(self)))
            }
        self.otherwiseBlock?.initializeTypeConstraints(inContext: context)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.value.initializeType(inContext: context)
        for block in self.whenBlocks
            {
            block.initializeType(inContext: context)
            }
        self.otherwiseBlock?.initializeType(inContext: context)
        self.type = context.voidType
        }
        
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
//        let aClass = self.value.type
//        try self.value.emitCode(into: buffer,using: generator)
//        var nextWhen: T3ALabel?
//        let endLabel = buffer.nextLabel()
//        for when in whenBlocks
//            {
//            if aClass.isPrimitiveClass && !aClass.isStringClass
//                {
//                buffer.append(nextWhen,"CMPW",self.value.place,when.condition.place,.none)
//                }
//            else
//                {
//                buffer.append(nextWhen,"CMPO",self.value.place,when.condition.place,.none)
//                }
//            nextWhen = buffer.nextLabel()
//            buffer.append(nil,"BRNEQ",.none,.none,.label(nextWhen!))
//            try when.emitCode(into: buffer,using: generator)
//            buffer.append(nil,"BR",.none,.none,.label(endLabel))
//            }
//        if self.otherwiseBlock.isNotNil
//            {
//            buffer.pendingLabel = nextWhen
//            try self.otherwiseBlock!.emitCode(into: buffer,using: generator)
//            }
//        buffer.pendingLabel = endLabel
        }
    }
