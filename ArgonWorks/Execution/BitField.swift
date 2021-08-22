//
//  HostedBitField.swift
//  HostedBitField
//
//  Created by Vincent Coetzee on 28/7/21.
//

import Foundation

//public struct BitBlock
//    {
//    public let start:Int
//    public let stop:Int
//    public var value:UInt8
//    }
//    
//public protocol BitKeeper
//    {
//    var bitOffset: Int { get set }
//    
//    func readBits(atOffset:Int?,inWidth:Int) -> Word
//    func writeBits(_ bits:Word,atOffset:Int?,inWidth:Int)
//    func nextBitBlock() -> BitBlock
//    func nextPutBitBlock(_ bitBlock:BitBlock)
//    }
//    
//public struct BitField<T>
//    {
//    private let offset:Int?
//    private let width:Int
//    private let mask: Word
//    private var bitKeeper: BitKeeper
//    
//    init(offset:Int?,width:Int,on bitKeeper:BitKeeper)
//        {
//        self.offset = offset
//        self.width = width
//        self.mask = (1 << Word(self.width + 1)) - 1
//        self.bitKeeper = bitKeeper
//        }
//        
//    func decode() -> Word
//        {
//        self.bitKeeper.readBits(atOffset: self.offset,inWidth: self.width)
//        }
//        
//    func decode() -> T where T:RawRepresentable,T.RawValue == Int
//        {
//        let bits = self.bitKeeper.readBits(atOffset: self.offset,inWidth: self.width)
//        let value = T(rawValue: Int(bits))!
//        return(value)
//        }
//        
//    func encode(_ value:T) where T:RawRepresentable,T.RawValue == Int
//        {
//        let bits = Word(bitPattern: value.rawValue) & self.mask
//        self.bitKeeper.writeBits(bits,atOffset: self.offset,inWidth: self.width)
//        }
//        
//    func encode(_ value:Word)
//        {
//        let bits = value & self.mask
//        self.bitKeeper.writeBits(bits,atOffset: self.offset,inWidth: self.width)
//        }
//    }
//
//extension BitField where T == Word
//    {
//    var value: T
//        {
//        get
//            {
//            return(self.decode())
//            }
//        }
//    }
//
//extension BitField where T:RawRepresentable,T.RawValue == Int
//    {
//    public var value: T
//        {
//        get
//            {
//            return(self.decode())
//            }
//        set
//            {
//            self.encode(newValue)
//            }
//        }
//    }
//
//public struct BitArray
//    {
//    private class Block
//        {
//        let start:Int
//        let stop:Int
//        var byte:UInt8
//        
//        init(start:Int,stop:Int)
//            {
//            self.start = start
//            self.stop = stop
//            self.byte = 0
//            }
//            
//        public var bitsFree: Int
//            {
//            return(stop - start)
//            }
//            
//        public func setBits(_ bits:Word,from:Int,to:Int)
//            {
//            let length = stop - start
//            let mask = Word(1) << Word(length) - 1
//            let maskedValue = bits & mask
//            self.byte = UInt8(maskedValue)
//            }
//            
//        public func extractBits(count:Int,from:Word,at offset:Int)
//            {
//            let mask = (Word(1) << Word(count) - 1) << Word(offset)
//            let value:Word = (from & mask) >> Word(offset)
//            self.byte = UInt8(value)
//            }
//        }
//        
//    private var currentOffset:Int = 0
//    private var currentBlock: Block = Block(start:0,stop:8)
//    private var bytes = Array<UInt8>()
//    
//    private func nextBlock() -> Block
//        {
//        return(Block(start: currentOffset,stop: currentOffset + 8))
//        }
//        
//    public mutating func writeBits(_ bits:Word,atOffset:Int?,inWidth:Int)
//        {
//        var block = self.nextBlock()
//        var offset = atOffset.isNil ? self.currentOffset : atOffset!
//        let top = offset + inWidth
//        while offset < top
//            {
//            let bitsUsed = min(top-offset,block.bitsFree)
//            block.extractBits(count: bitsUsed,from: bits,at: offset)
//            offset += bitsUsed
//            self.writeBlock(block)
//            block = self.nextBlock()
//            }
//        self.currentOffset += inWidth
//        }
//        
//    private func writeBlock(_ block:Block)
//        {
//        let index = block.start / 8
//        }
//    }
