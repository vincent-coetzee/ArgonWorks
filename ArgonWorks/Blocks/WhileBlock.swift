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
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
//        let start = buffer.toHere()
        try self.condition.emitCode(into: buffer,using: generator)
        buffer.append(.BRF,self.condition.place,.none,.label(0))
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: generator)
            }
        buffer.append(.BR,.none,.none,.label(0))
        }
    }
