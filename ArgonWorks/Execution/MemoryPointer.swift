//
//  NakedPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/12/21.
//

import Foundation

public class MemoryPointer
    {
    public var addressString: String
        {
        String(format: "%010X",self.address)
        }
        
    public var className: String
        {
        self.classPointer.namePointer!.string
        }
        
    let address: Address
    let wordPointer: WordPointer
    var classPointer: ClassPointer!
    var slots = Dictionary<String,SlotPointer>()
    
    init(address: Address)
        {
        self.address = address.cleanAddress
        self.wordPointer = WordPointer(bitPattern: address.cleanAddress)
        self.loadClass()
        }
        
    private func loadClass()
        {
        self.classPointer = ClassPointer(dirtyAddress: self.wordPointer[2])
        if let array = self.classPointer?.slotsPointer
            {
            for pointer in array.compactMap({SlotPointer(dirtyAddress: $0)})
                {
                self.slots[pointer.namePointer!.string] = pointer
                }
            }
        }
        
    public func word(atSlotNamed slotName: String) -> Word
        {
        if let slot = self.slots[slotName]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(self.wordPointer[index])
            }
        fatalError("Slot \(slotName) not found in object at address \(self.addressString)")
        }
    
    public func setWord(_ word: Word,atSlotNamed slotName: String)
        {
        if let slot = self.slots[slotName]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = word
            return
            }
        fatalError("Slot \(slotName) not found in object at address \(self.addressString)")
        }
        
    public func address(atSlotNamed slotName: String) -> Address
        {
        if let slot = self.slots[slotName]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(self.wordPointer[index].cleanAddress)
            }
        fatalError("Slot \(slotName) not found in object at address \(self.addressString)")
        }
    
    public func setAddress(_ word: Word,atSlotNamed slotName: String)
        {
        if let slot = self.slots[slotName]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = Word(object: word)
            return
            }
        fatalError("Slot \(slotName) not found in object at address \(self.addressString)")
        }
        
    public func boolean(atSlotNamed slotName: String) -> Bool
        {
        if let slot = self.slots[slotName]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(self.wordPointer[index] & 1 == 1)
            }
        fatalError("Slot \(slotName) not found in object at address \(self.addressString)")
        }
    
    public func setBoolean(_ boolean: Bool,atSlotNamed slotName: String)
        {
        if let slot = self.slots[slotName]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = Word(boolean: boolean)
            return
            }
        fatalError("Slot \(slotName) not found in object at address \(self.addressString)")
        }
        
    public func integer(atSlotNamed slotName: String) -> Int
        {
        if let slot = self.slots[slotName]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(Int(bitPattern: self.wordPointer[index]))
            }
        fatalError("Slot not found")
        }
        
    public func setInteger(_ integer: Int,atSlotNamed slotName: Label)
        {
        if let slot = self.slots[slotName]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = Word(integer: integer)
            return
            }
        fatalError("Slot not found")
        }
        
    public static func string(forTaggedValue value: Word) -> String
        {
        var valueString = ""
        switch(value.tag)
            {
            case .integer:
                valueString = "INTEGER: \(value)"
            case .boolean:
                valueString = "BOOLEAN: \(value.booleanValue)"
            case .byte:
                valueString = "BYTE: \(value.byteValue)"
            case .character:
                valueString = "CHARACTER \(value.characterValue)"
            case .header:
                let size = Header(word: value).sizeInBytes
                valueString = "HEADER: BYTE SIZE: \(size)"
            case .object:
                let objectString = String(format: "%010X",value)
                let className = ""
//                if value.cleanAddress != 0
//                    {
//                    let otherPointer = MemoryPointer(address: value.cleanAddress)
//                    className = otherPointer.className
//                    }
                valueString = "OBJECT: \(objectString) \(className)"
            case .float:
                valueString = "FLOAT: \(value.floatValue)"
            }
        return(valueString)
        }
        
    public static func dumpMemory(atAddress address: Address,count: Int)
        {
        let pointer = WordPointer(bitPattern: address.cleanAddress)
        var offset = 0
        for index in 0..<count
            {
            let word = pointer[index]
            let addressString = String(format: "%014X",address + Word(index * Argon.kWordSizeInBytesInt))
            let wordBitString = word.bitString
            let wordString = Self.string(forTaggedValue: word)
            if wordString.hasPrefix("HEADER")
                {
                offset = 0
                }
            else
                {
                offset += 1
                }
            let offsetString = String(format: "%05d",offset * Argon.kWordSizeInBytesInt)
            if word.tag == .header
                {
                print("----------------------------------------------------------------------------------------------------")
                }
            print("[\(addressString)] [\(offsetString)] \(wordBitString) \(wordString)")
            }
        }
    }
