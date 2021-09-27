//
//  BlockExpression.swift
//  BlockExpression
//
//  Created by Vincent Coetzee on 8/8/21.
//

import Foundation

public class BlockExpression: Expression
    {
    public override var displayString: String
        {
        return("BLOCK")
        }
        
    public override var topModule: TopModule
        {
        return(self.block.topModule)
        }
        
    private let block: Block
    
    init(block:Block)
        {
        self.block = block
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.block = coder.decodeObject(forKey: "block") as! Block
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.block,forKey: "block")
        }
        
    public override func emitCode(into instance: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.block.emitCode(into: instance,using: using)
        }
    }
