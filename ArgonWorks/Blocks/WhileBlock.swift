//
//  WhileBlock.swift
//  WhileBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class WhileBlock: Block
    {
    private let condition:Expression
    
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
    }
