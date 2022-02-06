//
//  CodeBuffer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/1/22.
//

import Foundation

public protocol BitFieldType
    {
    static var bitWidth: Int { get }
    init?(rawValue: Word)
    var rawValue: Word { get }
    }
    
public class BitSet
    {
    private struct Location
        {
        let byteIndex: Word
        let bitIndex: Word
        }
        
    private struct BitField
        {
        let name: String
        let start: Word
        let width: Word
        
        public var end: Word
            {
            self.start + self.width
            }
            
        public var mask: Word
            {
            (1 << width) - 1
            }
        }
        
    public var maximumFieldOffset: Word
        {
        var offset:Word = 0
        for field in self.bitFields.values
            {
            offset = max(offset,field.end)
            }
        return(offset)
        }
        
    public var words = Array<Word>(repeating: 0, count: 16)
    private var bitFields = Dictionary<String,BitField>()
    
    public init()
        {
        }
        
    public init(words: Array<Word>)
        {
        self.words = words
        }
        
    public func reset()
        {
        self.words = [0]
        }
        
    public func setBits<T>(_ value: T,atName: String) where T:RawRepresentable, T.RawValue == Word
        {
        let bits = value.rawValue
        self.setBits(bits,atName: atName)
        }
        
    public func addBitField(named: String,width: Int)
        {
        var start = 0
        for field in self.bitFields.values
            {
            start = max(Int(field.end),start)
            }
        self.addBitField(named: named,at: start,width: width)
        print("ADDED FIELD \(named) FROM \(start) TO \(start + width)")
        }
        
    public func addBitField(named: String,at: Int,width: Int)
        {
        if width > 64
            {
            fatalError("Fields can only be up to 63 bits in length")
            }
        for field in self.bitFields.values
            {
            if Word(at) > field.start && Word(at + width) < field.end
                {
                fatalError("Fields can not overlap, new field(\(at),\(at+width)) overlaps \(field.start),\(field.end)")
                }
            }
        let field = BitField(name: named,start: Word(at),width: Word(width))
        self.bitFields[field.name] = field
        }
        
    public func addBitField(named: String,ofType: BitFieldType.Type)
        {
        self.addBitField(named: named,width: ofType.bitWidth)
        }
        
    public func setBits(_ value: BitFieldType,atName: String)
        {
        self.setBits(value.rawValue,atName: atName)
        }
        
    public func bits<T>(atName: String) -> T where T:BitFieldType
        {
        return(T(rawValue: self.bits(atName: atName))!)
        }
        
    public func setBits(_ bits: Word,atName: String)
        {
        let field = self.bitFields[atName]!
        let lower = self.findBounds(field.start)
        let upper = self.findBounds(field.end)
        while upper.0 > self.words.count
            {
            self.doubleInSize()
            }
//        var lowerTop = upper.1
//        if upper.0 > lower.0
//            {
//            lowerTop = 63
//            }
//        let lowerBottom = lower.1
//        let lowerMaskHigh = ((Word(1) << lowerTop) - Word(1)) << 1 + 1
//        print("LOWER MASK HIGH: \(lowerMaskHigh.bitString)")
//        let lowerMaskLow = (Word(1) << lowerBottom) - Word(1)
//        print("LOWER MASK LOW : \(lowerMaskLow.bitString)")
//        let lowerMask = lowerMaskHigh - lowerMaskLow
//        print("LOWER MASK     : \(lowerMask.bitString)")
        var lowerWord = self.words[Int(lower.0)]
//        print("LOWER WORD     : \(lowerWord.bitString)")
        let clippedValue = bits & field.mask
        let value1 = clippedValue << lower.1
//        print("VALUE1         : \(value1.bitString)")
        lowerWord |= value1
//        print("LOWER WORD +   : \(lowerWord.bitString)")
        self.words[Int(lower.0)] = lowerWord
        if upper.0 > lower.0
            {
            var upperWord = self.words[Int(upper.0)]
//            print("UPPER WORD     : \(upperWord.bitString)")
            let delta = 64 - lower.1
            let topBits = bits >> delta
//            print("TOP BITS       : \(topBits.bitString)")
            upperWord |= topBits
//            print("UPPER WORD +   : \(upperWord.bitString)")
            self.words[Int(upper.0)] = upperWord
            }
        }
        
    public func bits(atName: String) -> Word
        {
        let field = self.bitFields[atName]!
        let lower = self.findBounds(field.start)
        let upper = self.findBounds(field.end)
        if upper.0 > lower.0
            {
            let topDelta = Word(64) - lower.1
            let lowerMask = ((Word(1) << topDelta) - Word(1)) << lower.1
//            print("LOWER WORD     : \(self.words[Int(lower.0)].bitString)")
//            print("LOWER MASK     : \(lowerMask.bitString)")
            let lowerBits = (self.words[Int(lower.0)] & lowerMask) >> lower.1
//            print("LOWER BITS     : \(lowerBits.bitString)")
            let upperMask = ((Word(1) << upper.1) - Word(1))
//            print("UPPER WORD     : \(self.words[Int(upper.0)].bitString)")
//            print("UPPER MASK     : \(upperMask.bitString)")
            let upperBits = (self.words[Int(upper.0)] & upperMask) << topDelta
//            print("BITS           : \((lowerBits + upperBits).bitString)")
            return(lowerBits | upperBits)
            }
        else
            {
            let word = self.words[Int(lower.0)]
            let mask = ((Word(1) << upper.1) - Word(1)) - ((Word(1) << lower.1) - Word(1))
//            print("WORD           : \(word.bitString)")
//            print("MASK           : \(mask.bitString)")
            let bits = (word & mask) >> lower.1
//            print("BITS           : \(bits.bitString)")
            return(bits)
            }
        }
        
    private func findBounds(_ amount: Word) -> (Word,Word)
        {
        let index = amount / 64
        return((index,amount - (index*64)))
        }
        
    internal func doubleInSize()
        {
        let newSize = self.words.count * 2
        var newWords = Array<Word>(repeating: 0, count: newSize)
        for index in 0..<self.words.count
            {
            newWords[index] = self.words[index]
            }
        self.words = newWords
        }
    }
    
public class FixedSizeBitSet: BitSet
    {
    internal override func doubleInSize()
        {
        fatalError("A fixed size bit set can not grow")
        }
        
    public init(wordCount: Int)
        {
        super.init()
        self.words = Array<Word>(repeating: 0, count: wordCount)
        }
    }
