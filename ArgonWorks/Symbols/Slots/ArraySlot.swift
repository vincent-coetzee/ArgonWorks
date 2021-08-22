//
//  ArraySlot.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

public class ArraySlot:Slot
    {
    public override var isArraySlot:Bool
        {
        return(true)
        }
        
    public override var cloned: Slot
        {
        let newSlot = ArraySlot(label: self.label,type:self.type)
        newSlot.setOffset(self.offset)
        return(newSlot)
        }
        
    public override func printFormattedSlotContents(base:WordPointer)
        {
        let offsetValue = self.offset
        let offsetString = String(format: "%08X",offsetValue)
        let name = self.label.aligned(.left,in:25)
        let word = base.word(atByteOffset: offsetValue)
        let arrayPointer = InnerArrayPointer(address: word)
        let addressString = String(format: "0x%08X",word)
        print("\(offsetString) \(name) ARR \(word.bitString) \(addressString) \(arrayPointer.count)/\(arrayPointer.size)")
        }
    }
