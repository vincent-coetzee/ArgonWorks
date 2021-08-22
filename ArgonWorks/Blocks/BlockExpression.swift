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
        
    }
