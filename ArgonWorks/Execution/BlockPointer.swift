//
//  BlockPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/2/22.
//

import Foundation

public class BlockPointer: ClassBasedPointer
    {
    public var size: Int
        {
        get
            {
            self.integer(atSlot: "size")
            }
        set
            {
            self.setInteger(newValue,atSlot: "size")
            }
        }
        
    public var count: Int
        {
        get
            {
            self.integer(atSlot: "count")
            }
        set
            {
            self.setInteger(newValue,atSlot: "count")
            }
        }
        
    public init(address: Address,type: Type)
        {
        super.init(address: address,class: type as! TypeClass)
        }
        
    public subscript(_ index: Int) -> Word
        {
        get
            {
            self.wordPointer[index + self.someClass.layoutSlots.count]
            }
        set
            {
            self.wordPointer[index + self.someClass.layoutSlots.count] = newValue
            }
        }
    }
