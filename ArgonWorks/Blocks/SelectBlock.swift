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
    private var whenBlocks:Array<WhenBlock>
    public var otherwiseBlock: OtherwiseBlock?
    
    init(value: Expression)
        {
        self.value = value
        whenBlocks = Array<WhenBlock>()
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
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        let aClass = self.value.resultType
        try self.value.emitCode(into: buffer,using: generator)
        var linksToBottom = Array<Instruction.LabelMarker>()
        var fromCompare:Instruction.LabelMarker?
        for when in whenBlocks
            {
            let outputRegister = generator.registerFile.findRegister(forSlot: nil, inBuffer: buffer)
            if aClass.isPrimitiveClass && !aClass.isStringClass
                {
                buffer.append(.CMPW,self.value.place,when.condition.place,.register(outputRegister))
                }
            else
                {
                buffer.append(.CMPO,self.value.place,when.condition.place,.register(outputRegister))
                }
            if fromCompare.isNotNil
                {
                try buffer.toHere(fromCompare!)
                }
            buffer.append(.BRNEQ,.register(outputRegister),.none,.label(0))
            fromCompare = buffer.triggerFromHere()
            try when.emitCode(into: buffer,using: generator)
            buffer.append(.BR,.none,.none,.label(0))
            linksToBottom.append(buffer.triggerFromHere())
            }
        if self.otherwiseBlock.isNotNil
            {
            try self.otherwiseBlock!.emitCode(into: buffer,using: generator)
            }
        for link in linksToBottom
            {
            try buffer.toHere(link)
            }
        }
    }
