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
        let address = self.address(atSlot: "name")
        if address.isNotNil
            {
            let stringPointer = StringPointer(address: address!,argonModule: self.argonModule)
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
            return(ClassPointer(address: self.classAddress,argonModule: self.argonModule))
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
        
    internal let someAddress: Address
    internal let someClass: TypeClass
    internal let wordPointer: WordPointer
    private let header: Header
    private var indexCache: Dictionary<Label,Int> = [:]
    private var argonModule: ArgonModule
    
    convenience init(address: Address,type: Type,argonModule: ArgonModule)
        {
        self.init(address: address,class: (type as! TypeClass),argonModule: argonModule)
        }
        
    init(address: Address,class aClass: TypeClass,argonModule: ArgonModule)
        {
        self.argonModule = argonModule
        self.someClass = aClass
        self.someAddress = address.cleanAddress
        self.wordPointer = WordPointer(bitPattern: address.cleanAddress)
        self.header = Header(atAddress: address.cleanAddress)
        self.indexCache = self.someClass.slotIndexCache
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
        return(self.someClass.slotIndexCache[ofSlot]!)
        }
        
    public func integer(atSlot: String) -> Int
        {
        return(Int(bitPattern: self.wordPointer[self.indexCache[atSlot]!]))
        }
        
    public func setInteger(_ integer: Int,atSlot: Label)
        {
        self.wordPointer[self.indexCache[atSlot]!] = Word(integer: integer)
        }
        
    public func integer(atIndex: Int) -> Int
        {
        return(Int(bitPattern: self.wordPointer[atIndex]))
        }
        
    public func setInteger(_ integer: Int,atIndex: Int)
        {
        self.wordPointer[atIndex] = Word(integer: integer)
        }
        
    public func boolean(atSlot: String) -> Bool
        {
        return((self.wordPointer[self.indexCache[atSlot]!] & 1) == 1)
        }
        
    public func setBoolean(_ boolean: Bool,atSlot: Label)
        {
        self.wordPointer[self.indexCache[atSlot]!] = Word(boolean: boolean)
        }
        
    public func word(atSlot: String) -> Word
        {
        return(self.wordPointer[self.indexCache[atSlot]!])
        }
        
    public func setWord(_ word: Word,atSlot: Label)
        {
        self.wordPointer[self.indexCache[atSlot]!] = word
        }
        
    public func word(atIndex: Int) -> Word
        {
        return(self.wordPointer[atIndex])
        }
        
    public func setWord(_ word: Word,atIndex: Int)
        {
        self.wordPointer[atIndex] = word
        }
        
    public func address(atSlot: String) -> Address?
        {
        let index = self.indexCache[atSlot]!
        return(self.wordPointer[index].isNull ? nil : self.wordPointer[index].cleanAddress)
        }
        
    public func address(atIndex: Int) -> Address?
        {
        return(self.wordPointer[atIndex].isNull ? nil : self.wordPointer[atIndex].cleanAddress)
        }
        
    public func setAddress(_ address: Address?,atSlot: Label)
        {
        let index = self.indexCache[atSlot]!
        if address.isNotNil && address! == 0
            {
            print("halt")
            }
        self.wordPointer[index] = address.isNil ? Argon.kNullTag: Word(pointer: address!.cleanAddress)
        }
        
    public func setAddress(_ address: Address?,atIndex: Int)
        {
        if address.isNotNil && address! == 0
            {
            print("halt")
            }
        self.wordPointer[atIndex] = address.isNil ? Argon.kNullTag: Word(pointer: address!.cleanAddress)
        }
    }
