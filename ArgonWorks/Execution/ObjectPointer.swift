//
//  ObjectPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 15/12/21.
//

import Foundation

public class ObjectPointer: Addressable,Pointer
    {
    public class func sizeInBytes() -> Int
        {
        32
        }
    
    internal static let alignment = MemoryLayout<Word>.alignment
    
    public var dirtyAddress: Address
        {
        return(self._dirtyAddress)
        }
        
    public var cleanAddress: Address
        {
        return(self._cleanAddress)
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
            return(ClassPointer(address: self.classAddress!))
            }
        set
            {
            self.classAddress = newValue!.address.pointerAddress
            }
        }
        
    public var classAddress: Address?
        {
        get
            {
            let word = self.wordPointer[2]
            return(word.isNull ? nil : word.cleanAddress)
            }
        set
            {
            self.wordPointer[2] = newValue.isNil ? Argon.kNullTag : Word(pointer: newValue!)
            }
        }
        
    internal var wordPointer: WordPointer
    internal let _dirtyAddress: Word
    internal let _cleanAddress: Word
    internal let header: Header
    
    public required init?(dirtyAddress: Word)
        {
        if dirtyAddress.cleanAddress == 0
            {
            return(nil)
            }
        self._dirtyAddress = dirtyAddress
        self._cleanAddress = dirtyAddress.cleanAddress
        self.wordPointer = WordPointer(bitPattern: dirtyAddress.cleanAddress)
        self.header = Header(atAddress: dirtyAddress.cleanAddress)
        }
        
    internal func align(_ value: Int,to alignment: Int) -> Int
        {
        let mask = alignment - 1
        return(value + (-value & mask))
        }
        
    internal func alignAddress(_ value: Address) -> Address
        {
        let mask = Int64(MemoryLayout<Address>.alignment - 1)
        return(Address(Int64(value) + (-Int64(value) & mask)))
        }
        
    @inline(__always)
    public func setBoolean(_ boolean: Bool,atIndex: Int)
        {
        var value:Address = boolean ? 1 : 0
        value.tag = .boolean
        self.wordPointer[atIndex] = value
        }
        
    @inline(__always)
    public func boolean(atIndex: Int) -> Bool
        {
        return(self.wordPointer[atIndex].cleanAddress == 1)
        }

    public subscript(_ index: Int) -> Word
        {
        get
            {
            self.wordPointer[index]
            }
        set
            {
            self.wordPointer[index] = newValue
            }
        }
        
    public func setInteger(_ integer:Int,atIndex: Int)
        {
        self.wordPointer[atIndex] = Word(integer: integer)
        }
        
    public func setAddress(_ address:Address?,atIndex: Int)
        {
        if address.isNotNil && address! == 0
            {
            fatalError("SET NIL VALUE DO NOT USE 0 as NIL")
            }
        self.wordPointer[atIndex] = address.isNil ? Argon.kNullTag : Word(pointer: address!)
        }
        
    public func address(atIndex: Int) -> Address?
        {
        let value = self.wordPointer[atIndex]
        return(value.isNull ? nil : value.pointerValue)
        }
        
    public func integer(atIndex: Int) -> Int
        {
        let value = self.wordPointer[atIndex]
        return(Int(bitPattern: value))
        }
        
    public func setWord(_ address:Word,atIndex: Int)
        {
        self.wordPointer[atIndex] = address
        }
        
    public func word(atIndex: Int) -> Word
        {
        self.wordPointer[atIndex]
        }
    }

