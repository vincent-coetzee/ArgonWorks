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
        
    public init(pointer: Int)
        {
        let base = UInt64(bitPattern: Int64(pointer)) & ~(Header.kTagBits << Header.kTagShift)
        self = base | (Argon.Tag.pointer.rawValue << Header.kTagShift)
        }
        
    public var pointerValue: Int
        {
        Int(bitPattern: UInt(self & ~Argon.kPointerTag))
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

public typealias WordPointer = UnsafeMutablePointer<Word>

extension WordPointer
    {
    public init(bitPattern: Word)
        {
        self.init(bitPattern: UInt(bitPattern))!
        }
        
    public subscript(_ index: Word) -> Word
        {
        get
            {
            return(self[Int(index)])
            }
        set
            {
            self[Int(index)] = newValue
            }
        }
    }
    
public typealias Address = Word
