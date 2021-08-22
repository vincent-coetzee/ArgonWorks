//
//  StringSlot.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

public class StringSlot:Slot
    {
    public override var isStringSlot:Bool
        {
        return(true)
        }
        
    public override var cloned: Slot
        {
        let newSlot = StringSlot(label: self.label,type:self.type)
        newSlot.setOffset(self.offset)
        return(newSlot)
        }
        
    public override func printFormattedSlotContents(base:WordPointer)
        {
//        let offsetValue = self.offset
//        let offsetString = String(format: "%08X",offsetValue)
//        let name = self.label.aligned(.left,in:25)
//        let word = base.word(atByteOffset: offsetValue)
//        let stringPointer = StringPointer(address: word)
//        let addressString = String(format: "0x%08X",word)
//        print("\(offsetString) \(name) STR \(word.bitString) \(addressString) \(stringPointer.count): \(stringPointer.string)")
        }
    }
