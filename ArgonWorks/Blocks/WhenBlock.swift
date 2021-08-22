//
//  WhenBlock.swift
//  WhenBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class WhenBlock: Block
    {
    public var conditionPlace: Instruction.Operand
        {
        return(self.condition.place)
        }
        
    public let condition: Expression
    
    init(condition: Expression)
        {
        self.condition = condition
        super.init()
        }
    }
    
