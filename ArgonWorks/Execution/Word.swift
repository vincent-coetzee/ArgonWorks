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
    public static let nilValue:Word = Word(0).tagged(with: .nil)
    public static let kPersistentPageMask = ((Word(1) << Word(15)) - 1) << 48
    
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
        
    public var tagDropped: Word
        {
        return(self & ~(Header.kTagBits << Header.kTagShift))
        }
        
    public func tagged(with:Argon.Tag) -> Word
        {
        var value = Header(self)
        value.tag = .nil
        return(value)
        }
        
    public var isZero: Bool
        {
        return(self == 0)
        }
        
    public var isPersistentAddress: Bool
        {
        let pageNumber = (self & Self.kPersistentPageMask) >> 48
        return(pageNumber > 0)
        }
        
    public var wordPointer:WordPointer
        {
        WordPointer(bitPattern: UInt(self))!
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
        
    public var withoutTag:Word
        {
        return(self & ~(0b111 << 60))
        }
        
    public func with(_ value:Word,in width:Word) -> Word
        {
        let mask = Word(1) << width - 1
        let newValue = value & mask
        return(self | newValue)
        }
        
    public func with(_ value:Int,in width:Int) -> Word
        {
        let mask = Word(1) << Word(width) - 1
        let newValue = Word(value) & mask
        return(self | newValue)
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
        
    public init(boolean:Bool)
        {
        let tag = (Argon.Tag.boolean.rawValue & Self.kTagBits) << Self.kTagShift
        let base:Word = boolean ? 1 : 0
        self = tag | base
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
    }

public typealias Words = Array<Word>

public typealias HWord = Int32
