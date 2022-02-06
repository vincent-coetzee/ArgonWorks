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
        
    public var isClass: Bool
        {
        guard self.someSlots["name"].isNotNil else
            {
            return(false)
            }
        let address = self.address(atSlot: "name")
        if address.isNotNil
            {
            if let stringPointer = StringPointer(dirtyAddress: address!)
                {
                return(stringPointer.string == "Class")
                }
            }
        return(false)
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
            return(ClassPointer(address: self.classAddress))
            }
        set
            {
            self.classAddress = Word(pointer: newValue.isNil ? 0 : newValue!.address.cleanAddress)
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
            self.wordPointer[2] = Word(pointer: newValue)
            }
        }
        
    public var hash: Int
        {
        let offset = self.someSlots["hash"]!.offset
        let size = Int(self.sizeInBytes)
        var hashValue:Int = 0
        for index in (offset/8)..<(size/8)
            {
            hashValue = hashValue << 13 ^ Int(bitPattern: self.wordPointer[index])
            }
        self.setInteger(hashValue,atSlot: "hash")
        return(hashValue)
        }
        
    private let someAddress: Address
    internal let someClass: TypeClass
    private var someSlots: Dictionary<Label,Slot>
    internal let wordPointer: WordPointer
    private let header: Header
    
    convenience init(address: Address,type: Type)
        {
        self.init(address: address,class: (type as! TypeClass))
        }
        
    init(address: Address,class aClass: TypeClass)
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
        let theClass = (type as! TypeClass)
        self.setClass(theClass)
        }
        
    private func setLocalSlotValues(forClass aClass: TypeClass,inClass: TypeClass)
        {
        for slot in aClass.localSystemSlots
            {
            let slotName = slot.nameInClass(aClass)
            if slot.slotType.contains(.kSystemClassSlot)
                {
                self.setClassAddress(aClass.memoryAddress,atSlot: slotName)
                }
            else if slot.slotType.contains(.kSystemHeaderSlot) || slot.slotType.contains(.kSystemInnerSlot)
                {
                let actualSlot = inClass.layoutSlot(atLabel: slotName)
                self.setWord(Word(inner: actualSlot.offset),atSlot: slotName)
                }
            else if slot.slotType.contains(.kSystemMagicNumberSlot)
                {
                self.setInteger(aClass.magicNumber,atSlot: slotName)
                }

            }
        if aClass.supertype.isNotNil
            {
            self.setLocalSlotValues(forClass: (aClass.supertype as! TypeClass),inClass: inClass)
            }
        }
        
    public func setClass(_ aClass: TypeClass)
        {
        self.header.tag = .header
        self.header.hasBytes = aClass.hasBytes
        self.magicNumber = aClass.magicNumber
        self.classAddress = aClass.memoryAddress
        self.setLocalSlotValues(forClass: (aClass.supertype as! TypeClass),inClass: aClass)
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
            self.wordPointer[index] = Word(integer: integer)
            return
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
            self.wordPointer[index] = address.pointerAddress
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
        
    public func address(atSlot: String) -> Address?
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            return(self.wordPointer[index].isNull ? nil : self.wordPointer[index].cleanAddress)
            }
        fatalError("Slot not found")
        }
        
    public func setAddress(_ address: Address?,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            if address.isNotNil && address! == 0
                {
                print("halt")
                }
            self.wordPointer[index] = address.isNil ? Argon.kNullTag: Word(pointer: address!.cleanAddress)
            return
            }
        fatalError("Slot not found")
        }
        
    public func setArrayAddress(_ address: Address?,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = address.isNil ? Argon.kNullTag : Word(pointer: address.cleanAddress)
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
        
    public func setArrayPointer(_ array: ArrayPointer?,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = (array.isNil || (array.isNotNil && array!.cleanAddress == 0)) ? Argon.kNullTag : Word(pointer: array!.cleanAddress)
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
            self.wordPointer[index] = Word(pointer: string.cleanAddress)
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
        
    public func setStringAddress(_ string: Address?,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = (string.isNil || (string.isNotNil && string!.cleanAddress == 0)) ? Argon.kNullTag : Word(pointer: string!.cleanAddress)
            return
            }
        fatalError("Slot not found")
        }
    public func setClassAddress(_ string: Address?,atSlot: Label)
        {
        if let slot = self.someSlots[atSlot]
            {
            if string.isNotNil && string! == 0
                {
                fatalError()
                }
            let index = slot.offset / Argon.kWordSizeInBytesInt
            self.wordPointer[index] = string.isNil ? Argon.kNullTag : Word(pointer: string!.cleanAddress)
            return
            }
        fatalError("Slot not found")
        }
    }
