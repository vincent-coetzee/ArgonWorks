//
//  HandlerBlock.swift
//  HandlerBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class HandlerBlock: ClosureBlock
    {
    public var symbols = Array<String>()
    
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        }
        
    public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        let literal = T3AInstruction.LiteralValue.array(self.symbols.map{T3AInstruction.LiteralValue.symbol($0)})
        let codeLabel = buffer.nextLabel()
        buffer.append(nil,"HAND",.literal(literal),.label(codeLabel),.none)
        let label = buffer.nextLabel()
        buffer.append(nil,"BR",.label(label),.none,.none)
        buffer.pendingLabel = codeLabel
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: using)
            }
        buffer.pendingLabel = label
        }
    }
