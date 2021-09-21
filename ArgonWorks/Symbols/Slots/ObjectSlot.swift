//
//  ObjectSlot.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 23/7/21.
//

import Foundation

public class ObjectSlot:Slot
    {
    public override var cloned: Slot
        {
        let newSlot = ObjectSlot(label: self.label,type:self.type)
        newSlot.setOffset(self.offset)
        return(newSlot)
        }
        
    public override func printFormattedSlotContents(base:WordPointer)
        {
        let offsetValue = self.offset
        let offsetString = String(format: "%08X",offsetValue)
        let name = self.label.aligned(.left,in:25)
        let word = base.word(atByteOffset: offsetValue)
        let addressString = String(format: "0x%08X",word)
        print("\(offsetString) \(name) OBJ \(word.bitString) \(addressString)")
        }
    }
