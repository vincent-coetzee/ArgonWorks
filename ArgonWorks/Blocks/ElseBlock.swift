//
//  Elseblock.swift
//  Elseblock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ElseBlock: Block
    {
    public override var displayString: String
        {
        "Else\n" + self.blocks.displayString
        }
    }

public class ElseIfBlock: IfBlock
    {
    }
