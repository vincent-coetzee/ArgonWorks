//
//  Word.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation
import MachMemory

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
    public static var null: Word
        {
        Argon.kNullTag
        }
        
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
        return(self & ~(Argon.kTagBits << Argon.kTagShift))
        }
        
    public var isNull: Bool
        {
        self & Argon.kNullTag == Argon.kNullTag
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
        let mask = Argon.kTagBits << Argon.kTagShift
        return(((self & mask) >> Argon.kTagShift) == Argon.Tag.header.rawValue)
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
        return(((self & ~(Argon.kTagBits << Argon.kTagShift)) >> Argon.kTagShift) == 1)
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
        let tag = (Argon.Tag.boolean.rawValue & Argon.kTagBits) << Argon.kTagShift
        let base:Word = boolean ? 1 : 0
        self = tag | base
        }
        
    public init(integer: Int)
        {
        self = UInt64(bitPattern: integer) & ~(Argon.kTagBits << Argon.kTagShift)
        }
        
    public init(integer: Argon.Integer)
        {
        self = UInt64(bitPattern: integer) & ~(Argon.kTagBits << Argon.kTagShift)
        }
        
    public init(integer: Argon.Integer32)
        {
        self = UInt64(bitPattern: Int(integer)) & ~(Argon.kTagBits << Argon.kTagShift)
        }
        
//    public init(address: Word,offset: Word)
//        {
//        let bottom = address & 17592186044415
//        let top = (offset & 0b11111111_11111111) << 44
//        self = top | bottom
//        }
        
    public init(uInteger: Argon.UInteger)
        {
        self = uInteger & ~(Argon.kTagBits << Argon.kTagShift)
        }
        
    public init(character: Argon.Character)
        {
        let tag = (Argon.Tag.character.rawValue & Argon.kTagBits) << Argon.kTagShift
        let base = Word(character & 65535)
        self = tag | base
        }
        
    public init(byte: Argon.Byte)
        {
        let tag = (Argon.Tag.byte.rawValue & Argon.kTagBits) << Argon.kTagShift
        let base = Word(byte & 255)
        self = tag | base
        }
        
    public init(float: Argon.Float)
        {
        let pattern = float.bitPattern >> 4
        let base = pattern & ~Argon.kTagMask
        self = base | Argon.kFloatTag
        }
        
    public init(symbolIndex: Int,offset:Word)
        {
        let top = (Word(symbolIndex) & Word(16383)) << Word(45)
        let bottom = (offset & Word(17592186044415))
        self = top | bottom
        }
        
    public var symbolValue: (Int,Word)
        {
        let top = (self >> Word(45)) & Word(16383)
        let bottom = (self & Word(17592186044415))
        return((Int(top),bottom))
        }
        
    public var innerValue: Int
        {
        Int(self & 4294967295)
        }
        
    public var pointerValue: Address
        {
        Address(self & ~Argon.kPointerTag)
        }
        
    public var integerValue: Argon.Integer
        {
        Argon.Integer(self & ~Argon.kIntegerTag)
        }
        
    public var intValue: Int
        {
        Int(bitPattern: self & ~Argon.kIntegerTag)
        }
        
    public var floatValue: Argon.Float
        {
        return(Argon.Float(bitPattern: self << 4))
        }
        
    public init(pointer: Word)
        {
        let base = UInt64(bitPattern: Int64(pointer)) & ~(Argon.kTagBits << Argon.kTagShift)
        self = base | (Argon.Tag.pointer.rawValue << Argon.kTagShift)
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
        
    public mutating func setValue<T>(_ value: T,of bitPattern: BitPattern) where T:RawRepresentable,T.RawValue == Word
        {
        let bitValue = value.rawValue & bitPattern.bits
        let mask = bitPattern.bits << bitPattern.shift
        self &= ~mask
        self |= bitValue << bitPattern.shift
        }
        
    public func value<T>(of bitPattern: BitPattern) -> T where T:RawRepresentable,T.RawValue == Word
        {
        let bits = (self & (bitPattern.bits << bitPattern.shift)) >> bitPattern.shift
        return(T(rawValue: bits)!)
        }
        
    public static func testWord()
        {
        let pointer = Word(pointer: 1)
        assert(pointer == Argon.kPointerTag + 1,"A pointer of 1 should be \((Argon.kPointerTag + 1).bitString) but is \(pointer.bitString)")
        assert(pointer.pointerValue == 1,"Pointer value should be 1 but is \(pointer.pointerValue)")
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
    public static var alignment: Word
        {
        Word(MemoryLayout<Address>.alignment)
        }
        
    public var tag: Argon.Tag
        {
        get
            {
            let mask = Argon.kTagBits << Argon.kTagShift
            if let tag = Argon.Tag(rawValue: (self & mask) >> Argon.kTagShift)
                {
                return(tag)
                }
            return(.integer)
            }
        set
            {
            let value = (newValue.rawValue & Argon.kTagBits) << Argon.kTagShift
            self = (self & ~(Argon.kTagBits << Argon.kTagShift)) | value
            }
        }
        
//    public var isEnumerationInstancePointer: Bool
//        {
//        let value = (Argon.kIsEnumerationInstancePointerBitMask & self) >> Argon.kIsEnumerationInstancePointerShift
//        return(value & 1 == 1)
//        }
        
    public var cleanAddress: Address
        {
        return(self & ~(Argon.kTagBits << Argon.kTagShift))
        }
        
    public var pointerAddress: Address
        {
        (self & ~Argon.kPointerTag) | Argon.kPointerTag
        }
        
    public var isNil: Bool
        {
        self.cleanAddress == 0
        }
        
    public var isNotNil: Bool
        {
        self.cleanAddress != 0
        }
    }

public typealias Addresses = Array<Address>

