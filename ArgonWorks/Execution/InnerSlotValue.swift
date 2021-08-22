//
//  InnerSlotValuePointer.swift
//  InnerSlotValuePointer
//
//  Created by Vincent Coetzee on 15/8/21.
//

import Foundation

public struct InnerSlotValue
    {
    public private(set) var value: Word
    private let index: Int
    private var wordPointer: WordPointer?
    private let slotPointer: InnerSlotPointer
    
    public var isSlotScalarValue: Bool
        {
        return(self.slotPointer.isScalarSlot)
        }
        
    public var slotIndex: Int
        {
        return(self.index)
        }
        
    public var slotName: String
        {
        return(self.slotPointer.name)
        }
        
    public var slotOffset: Int
        {
        return(self.slotPointer.offset)
        }
        
    public var slotClass: InnerClassPointer
        {
        return(self.slotPointer.slotClass)
        }
        
    public var slotValue: Word
        {
        return(self.value)
        }
        
    public var slotTypeCode: TypeCode
        {
        return(TypeCode(rawValue: self.slotPointer.typeCode)!)
        }
        
    init(index: Int,wordPointer: WordPointer?,slotPointer: InnerSlotPointer)
        {
        self.index = index
        self.wordPointer = wordPointer
        self.value = wordPointer?[index] ?? 0
        self.slotPointer = slotPointer
        }
    }
