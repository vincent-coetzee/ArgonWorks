//
//  Word.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

public typealias Word = UInt64

extension Word:Identifiable
    {
    public var id: UInt64
        {
        return(self)
        }
    }
    
extension Word
    {
    public var bitString: String
        {
        var bitPattern = UInt64(1)
        var string = ""
        let count = MemoryLayout<UInt64>.size * 8
        for index in 1...count
            {
            string += (self & bitPattern) == bitPattern ? "1" : "0"
            string += index > 0 && index < count && index % 8 == 0 ? " " : ""
            bitPattern <<= 1
            }
        return(String(string.reversed()))
        }
        
    public var droppingTag: Word
        {
        return(self & ~(Header.kTagBits << Header.kTagShift))
        }
        
    public var isNil: Bool
        {
        self == 1
        }
        
    public var isZero: Bool
        {
        return(self == 0)
        }
        
    public var addressString: String
        {
        return(String(format:"%012X",self))
        }
        
    public var isHeader: Bool
        {
        let mask = Header.kTagBits << Header.kTagShift
        return(((self & mask) >> Header.kTagShift) == Argon.Tag.header.rawValue)
        }
        
    public func shifted(_ amount:Word) -> Word
        {
        return(self << amount)
        }
    ///
    ///
    /// Strip off the tag and return the value of he
    /// receiver as a Bool
    ///
    ///
    public var rawBooleanValue:Bool
        {
        return(((self & ~(Header.kTagBits << Header.kTagShift)) >> Header.kTagShift) == 1)
        }
        
    public init(bitPattern: WordPointer)
        {
        self.init(UInt(bitPattern: bitPattern))
        }
        
    public init(bitPattern: UnsafeMutableRawPointer)
        {
        self.init(UInt(bitPattern: bitPattern))
        }
        
    public init(boolean:Bool)
        {
        let tag = (Argon.Tag.boolean.rawValue & Header.kTagBits) << Header.kTagShift
        let base:Word = boolean ? 1 : 0
        self = tag | base
        }
        
    public init(integer: Int)
        {
        self = UInt64(bitPattern: integer) & ~(Header.kTagBits << Header.kTagShift)
        }
        
    public init(integer: Argon.Integer)
        {
        self = UInt64(bitPattern: integer) & ~(Header.kTagBits << Header.kTagShift)
        }
        
    public init(uInteger: Argon.UInteger)
        {
        self = uInteger & ~(Header.kTagBits << Header.kTagShift)
        }
        
    public init(character: Argon.Character)
        {
        let tag = (Argon.Tag.character.rawValue & Header.kTagBits) << Header.kTagShift
        let base = Word(character & 65535)
        self = tag | base
        }
        
    public init(byte: Argon.Byte)
        {
        let tag = (Argon.Tag.byte.rawValue & Header.kTagBits) << Header.kTagShift
        let base = Word(byte & 255)
        self = tag | base
        }
        
    public init(float: Argon.Float)
        {
        let pattern = float.bitPattern >> 4
        let base = pattern & ~Argon.kTagMask
        self = base | Argon.kFloatTag
        }
        
    public init(object: Word)
        {
        let base = UInt64(bitPattern: Int64(object)) & ~(Header.kTagBits << Header.kTagShift)
        self = base | (Argon.Tag.object.rawValue << Header.kTagShift)
        }
        
    public var objectValue: Int
        {
        Int(bitPattern: UInt(self & ~Argon.kObjectTag))
        }
        
    public var integerValue: Argon.Integer
        {
        Argon.Integer(self & ~Argon.kIntegerTag)
        }
        
    public var floatValue: Argon.Float
        {
        return(Argon.Float(bitPattern: self << 4))
        }
        
    public var booleanValue: Bool
        {
        self & ~Argon.kBooleanTag == 1
        }
        
    public var byteValue: Argon.Byte
        {
        Argon.Byte(self & 255)
        }
        
    public var characterValue: Character
        {
        Character(Unicode.Scalar(Int(self & 65535))!)
        }
        
    public func bitString(length:Int) -> String
        {
        var bitPattern = UInt64(1)
        var string = ""
        let count = MemoryLayout<UInt64>.size * 8
        for index in 1...count
            {
            string += (self & bitPattern) == bitPattern ? "1" : "0"
            string += index > 0 && index < count && index % 8 == 0 ? " " : ""
            bitPattern <<= 1
            }
        let extra = string.count - length
        let newString = string.dropFirst(extra)
        return(String(newString.reversed()))
        }
        
    public var doesWordHaveBitsInSecondFromTopByte: Bool
        {
        let mask = (Word(1) << 16 - 1) << 48
        let topBit = Word(1) << Word(63)
        let topBits = (self & topBit) & mask
        return(topBits > 0)
        }
        
    public init(bitPattern integer:Int)
        {
        self.init(bitPattern: Int64(integer))
        }
        
    public static func testWord()
        {
        let pointer = Word(object: 1)
        assert(pointer == Argon.kObjectTag + 1,"A pointer of 1 should be \((Argon.kObjectTag + 1).bitString) but is \(pointer.bitString)")
        assert(pointer.objectValue == 1,"Pointer value should be 1 but is \(pointer.objectValue)")
        let float = Word(float: 2931.492781)
        print(float.bitString)
//        assert(float.floatValue == 1,"Float value should be 2931.492781 but is \(float.floatValue)")
        }
    }

public typealias Words = Array<Word>

public typealias HWord = Int32

public typealias Address = Word

extension Address
    {
    public var tag: Argon.Tag
        {
        get
            {
            let mask = Header.kTagBits << Header.kTagShift
            if let tag = Argon.Tag(rawValue: (self & mask) >> Header.kTagShift)
                {
                return(tag)
                }
            return(.integer)
            }
        set
            {
            let value = (newValue.rawValue & Header.kTagBits) << Header.kTagShift
            self = (self & ~(Header.kTagBits << Header.kTagShift)) | value
            }
        }
        
    public var segment: Argon.Segment
        {
        get
            {
            return(Argon.Segment(rawValue: (self & Argon.kSegmentExtendedMask) >> Header.kTagShift)!)
            }
        set
            {
            let value = (newValue.rawValue & Argon.kSegmentMask) << Argon.kSegmentShift
            self = (self & ~Argon.kSegmentExtendedMask) | value
            }
        }
        
    public var isEnumerationInstancePointer: Bool
        {
        let value = (Argon.kIsEnumerationInstancePointerBitMask & self) >> Argon.kIsEnumerationInstancePointerShift
        return(value & 1 == 1)
        }
        
    public var cleanAddress: Address
        {
        return(self & ~(Header.kTagBits << Header.kTagShift))
        }
        
    public var objectAddress: Address
        {
        (self & ~Argon.kObjectTag) | Argon.kObjectTag
        }
    }

public typealias Addresses = Array<Address>

