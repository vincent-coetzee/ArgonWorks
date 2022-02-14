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
            let stringPointer = StringPointer(address: address!)
            return(stringPointer.string == "Class")
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
        
    internal let someAddress: Address
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
        for slot in self.someClass.allInstanceSlots
            {
            self.someSlots[slot.label] = slot
            }
//        for slot in self.someSlots.values
//            {
//            print("SLOT: \(slot.label) OFFSET: \(slot.offset) OWNER: \(slot.owningClass!.label)")
//            }
        }
        
    public func setClass(_ type: Type)
        {
        let theClass = (type as! TypeClass)
        self.setClass(theClass)
        }
        
    public func setClass(_ aClass: TypeClass)
        {
        self.header.tag = .header
        self.header.hasBytes = aClass.hasBytes
        aClass.layoutObject(atAddress: self.address)
        }
    
    private func index(ofSlot: String) -> Int
        {
        if let slot = self.someSlots[ofSlot]
            {
            let index = self.someClass.offsetInObject(ofSlot: slot) / Argon.kWordSizeInBytesInt
            return(index)
            }
        fatalError("Invalid slot \(ofSlot) in class \(someClass.label)")
        }
        
    public func integer(atSlot: String) -> Int
        {
        return(Int(bitPattern: self.wordPointer[self.index(ofSlot: atSlot)]))
        }
        
    public func setInteger(_ integer: Int,atSlot: Label)
        {
        self.wordPointer[self.index(ofSlot: atSlot)] = Word(integer: integer)
        }
        
    public func boolean(atSlot: String) -> Bool
        {
        return((self.wordPointer[self.index(ofSlot: atSlot)] & 1) == 1)
        }
        
    public func setBoolean(_ boolean: Bool,atSlot: Label)
        {
        self.wordPointer[self.index(ofSlot: atSlot)] = Word(boolean: boolean)
        }
        
    public func word(atSlot: String) -> Word
        {
        return(self.wordPointer[self.index(ofSlot: atSlot)])
        }
        
    public func setWord(_ word: Word,atSlot: Label)
        {
        self.wordPointer[self.index(ofSlot: atSlot)] = word
        }
        
    public func address(atSlot: String) -> Address?
        {
        let index = self.index(ofSlot: atSlot)
        return(self.wordPointer[index].isNull ? nil : self.wordPointer[index].cleanAddress)
        }
        
    public func setAddress(_ address: Address?,atSlot: Label)
        {
        let index = self.index(ofSlot: atSlot)
        if address.isNotNil && address! == 0
            {
            print("halt")
            }
        self.wordPointer[index] = address.isNil ? Argon.kNullTag: Word(pointer: address!.cleanAddress)
        }
    }
