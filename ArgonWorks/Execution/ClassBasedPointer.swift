//
//  ClassBasedPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public class ClassBasedPointer
    {
    public var address: Address
        {
        self.someAddress
        }
        
    public var sizeInWords: Int
        {
        get
            {
            return(self.header.sizeInWords)
            }
        set
            {
            self.header.sizeInWords = newValue
            }
        }
        
    public var sizeInBytes: Word
        {
        get
            {
            return(Word(self.header.sizeInWords * Argon.kWordSizeInBytesInt))
            }
        set
            {
            self.header.sizeInWords = Int(newValue) / Argon.kWordSizeInBytesInt
            }
        }
        
    public var flipCount: Int
        {
        get
            {
            return(self.header.flipCount)
            }
        set
            {
            self.header.flipCount = newValue
            }
        }
        
    public var magicNumber: Int
        {
        get
            {
            return(Int(self.wordPointer[1]))
            }
        set
            {
            self.wordPointer[1] = Word(newValue)
            }
        }
        
    public var objectType: Argon.ObjectType
        {
        get
            {
            return(self.header.objectType)
            }
        set
            {
            self.header.objectType = newValue
            }
        }
        
    public var tag: Argon.Tag
        {
        get
            {
            return(self.header.tag)
            }
        set
            {
            self.header.tag = newValue
            }
        }
        
    public var hasBytes: Bool
        {
        get
            {
            return(self.header.hasBytes)
            }
        set
            {
            self.header.hasBytes = newValue
            }
        }
        
    public var isForwarded: Bool
        {
        get
            {
            return(self.header.isForwarded)
            }
        set
            {
            self.header.isForwarded = newValue
            }
        }
        
    public var isPersistent: Bool
        {
        get
            {
            return(self.header.isPersistent)
            }
        set
            {
            self.header.isPersistent = newValue
            }
        }

        
    public var classPointer: ClassPointer?
        {
        get
            {
            return(ClassPointer(dirtyAddress: self.classAddress))
            }
        set
            {
            self.classAddress = newValue.dirtyAddress
            }
        }
        
    public var classAddress: Address
        {
        get
            {
            self.wordPointer[2].cleanAddress
            }
        set
            {
            self.wordPointer[2] = newValue.objectAddress
            }
        }
        
    private let someAddress: Address
    private let someClass: Class
    private var someSlots: Dictionary<Label,Slot>
    private let wordPointer: WordPointer
    private let header: Header
    
    convenience init(address: Address,type: Type)
        {
        self.init(address: address,class: (type as! TypeClass).theClass)
        }
        
    init(address: Address,class aClass: Class)
        {
        self.someClass = aClass
        self.someAddress = address.cleanAddress
        self.someSlots = Dictionary<Label,Slot>()
        self.wordPointer = WordPointer(bitPattern: address.cleanAddress)
        self.header = Header(atAddress: address.cleanAddress)
        self.initSlots()
        }
        
    private func initSlots()
        {
        for slot in self.someClass.layoutSlots
            {
            self.someSlots[slot.label] = slot
            }
        }
        
    public func setClass(_ type: Type)
        {
        let theClass = (type as! TypeClass).theClass
        self.classAddress = theClass.memoryAddress.cleanAddress
        self.setInteger(theClass.magicNumber,atSlot: "_magicNumber")
        for supertype in theClass.superclasses
            {
            self.setLocalSlotValues(forClass: (supertype as! TypeClass).theClass)
            }
        }
        
    public func setClass(_ aClass: Class)
        {
        self.classAddress = aClass.memoryAddress.cleanAddress
        self.setInteger(aClass.magicNumber,atSlot: "_magicNumber")
        self.setAddress(aClass.memoryAddress,atSlot: "_class")
        for supertype in aClass.superclasses
            {
            self.setLocalSlotValues(forClass: (supertype as! TypeClass).theClass)
            }
        }
        
    private func setLocalSlotValues(forClass aClass: Class)
        {
        for slot in aClass.localSystemSlots
            {
            switch(slot.slotType)
                {
                case .class:
                    self.setAddress(aClass.memoryAddress,atSlot: slot.label)
                case .header:
                    self.setWord(0,atSlot: slot.label)
                case .magicNumber:
                    self.setInteger(aClass.magicNumber,atSlot: slot.label)
                default:
                    break
                }
            }
        for superclass in aClass.superclasses
            {
            self.setLocalSlotValues(forClass: (superclass as! TypeClass).theClass)
            }
        }
        
    public func integer(atSlot: String) -> Int
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(Int(bitPattern: self.wordPointer[index]))
            }
        fatalError("Slot not found")
        }
        
    public func setInteger(_ integer: Int,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = Word(bitPattern: integer)
            return
            }
        fatalError("Slot not found")
        }
        
    public func enumerationPointer(atSlot: String) -> Address
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            let instance = EnumerationInstance(word: self.wordPointer[index])
            return(instance.pointer)
            }
        fatalError("Slot not found")
        }
        
    public func setEnumerationPointer(_ address: Address,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            let instance = EnumerationInstance(word: self.wordPointer[index])
            instance.pointer = address
            self.wordPointer[index] = instance.bytes
            }
        fatalError("Slot not found")
        }
        
    public func enumerationCaseIndex(atSlot: String) -> Int
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            let instance = EnumerationInstance(word: self.wordPointer[index])
            return(instance.caseIndex)
            }
        fatalError("Slot not found")
        }
        
    public func setEnumerationCaseIndex(_ index:Int,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            let instance = EnumerationInstance(word: self.wordPointer[index])
            instance.caseIndex = index
            self.wordPointer[index] = instance.bytes
            }
        fatalError("Slot not found")
        }
        
    public func enumerationValueCount(atSlot: String) -> Int
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            let instance = EnumerationInstance(word: self.wordPointer[index])
            return(instance.valueCount)
            }
        fatalError("Slot not found")
        }
        
    public func setEnumerationValueCount(_ index:Int,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            let instance = EnumerationInstance(word: self.wordPointer[index])
            instance.valueCount = index
            self.wordPointer[index] = instance.bytes
            }
        fatalError("Slot not found")
        }
        
    public func setEnumerationPointer(_ pointer:Address,caseIndex: Int,valueCount: Int,atSlot: String)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            let instance = EnumerationInstance(word: self.wordPointer[index])
            instance.valueCount = valueCount
            instance.caseIndex = caseIndex
            instance.pointer = pointer
            self.wordPointer[index] = instance.bytes
            }
        fatalError("Slot not found")
        }
        
    public func boolean(atSlot: String) -> Bool
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return((self.wordPointer[index] & 1) == 1)
            }
        fatalError("Slot not found")
        }
        
    public func setBoolean(_ boolean: Bool,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = Word(boolean: boolean)
            return
            }
        fatalError("Slot not found")
        }
        
    public func object(atSlot: String) -> Address
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(self.wordPointer[index].cleanAddress)
            }
        fatalError("Slot not found")
        }
        
    public func setObject(_ address: Address,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = address.objectAddress
            return
            }
        fatalError("Slot not found")
        }
        
    public func word(atSlot: String) -> Word
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(self.wordPointer[index])
            }
        fatalError("Slot not found")
        }
        
    public func setWord(_ word: Word,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = word
            return
            }
        fatalError("Slot not found")
        }
        
    public func address(atSlot: String) -> Address
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(self.wordPointer[index].cleanAddress)
            }
        fatalError("Slot not found")
        }
        
    public func setAddress(_ address: Address?,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = address.objectAddress
            return
            }
        fatalError("Slot not found")
        }
        
    public func arrayPointer(atSlot: String) -> ArrayPointer?
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(ArrayPointer(dirtyAddress: self.wordPointer[index]))
            }
        fatalError("Slot not found")
        }
        
    public func setArrayPointer(_ array: ArrayPointer,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = array.cleanAddress.objectAddress
            return
            }
        fatalError("Slot not found")
        }
        
    public func stringPointer(atSlot: String) -> StringPointer?
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(StringPointer(dirtyAddress: self.wordPointer[index]))
            }
        fatalError("Slot not found")
        }
        
    public func setStringPointer(_ string: StringPointer,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = string.cleanAddress.objectAddress
            return
            }
        fatalError("Slot not found")
        }
        
    public func stringAddress(atSlot: String) -> Address
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(self.wordPointer[index].cleanAddress)
            }
        fatalError("Slot not found")
        }
        
    public func setStringAddress(_ string: Address,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = string.cleanAddress.objectAddress
            return
            }
        fatalError("Slot not found")
        }
    }
