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
        self.value = Expression()
        super.init(coder: coder)
        }
        
    public func addWhen(block: WhenBlock)
        {
        self.whenBlocks.append(block)
        }
        
    public func addOtherwise(block: OtherwiseBlock)
        {
        self.otherwiseBlock = block
        }
        
    public override func realize(using realizer: Realizer)
        {
        self.value.realize(using: realizer)
        for block in self.whenBlocks
            {
            block.realize(using: realizer)
            }
        self.otherwiseBlock?.realize(using: realizer)
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)SELECT")
        value.dump(depth: depth+1)
        for block in self.whenBlocks
            {
            block.dump(depth: depth + 1)
            }
        }
        
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        let aClass = self.value.type
        try self.value.emitCode(into: buffer,using: generator)
        var nextWhen: T3ALabel?
        let endLabel = buffer.nextLabel()
        for when in whenBlocks
            {
            let temp = buffer.nextTemporary()
            if aClass.isPrimitiveClass && !aClass.isStringClass
                {
                buffer.append(nextWhen,"CMPW",self.value.place,when.condition.place,temp)
                }
            else
                {
                buffer.append(nextWhen,"CMPO",self.value.place,when.condition.place,temp)
                }
            nextWhen = buffer.nextLabel()
            buffer.append(nil,"BRNEQ",temp,.none,.label(nextWhen!))
            try when.emitCode(into: buffer,using: generator)
            buffer.append(nil,"BR",.none,.none,.label(endLabel))
            }
        if self.otherwiseBlock.isNotNil
            {
            buffer.pendingLabel = nextWhen
            try self.otherwiseBlock!.emitCode(into: buffer,using: generator)
            }
        buffer.pendingLabel = endLabel
        }
    }
