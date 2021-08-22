//
//  BooleanSlot.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 23/7/21.
//

import Foundation

public class BooleanSlot:Slot
    {
    public override var cloned: Slot
        {
        let newSlot = BooleanSlot(label: self.label,type:self.type)
        newSlot.setOffset(self.offset)
        return(newSlot)
        }
        
    public override func printFormattedSlotContents(base:WordPointer)
        {
        let offsetValue = self.offset
        let offsetString = String(format: "%08X",offsetValue)
        let name = self.label.aligned(.left,in:25)
        let word = base.word(atByteOffset: offsetValue)
        let value = word.rawBooleanValue
        print("\(offsetString) \(name) BOO \(word.bitString) \(value)")
        }
    }
