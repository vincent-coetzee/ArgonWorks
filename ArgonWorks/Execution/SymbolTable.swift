//
//  SymbolTable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/12/21.
//

import Foundation

public class SymbolTable
    {
    private struct Bucket
        {
        var symbolPointer: Address
        var nextPointer: Address
        var symbolIndex: Word
        }
        
    private typealias BucketPointer = UnsafeMutablePointer<Bucket>
        
    private static let kTableSize:Word = 4096
    
    private let baseAddress: Address
    private let context: ExecutionContext
    private let wordPointer: WordPointer
    private var symbolIndex = 1
    
    init(context: ExecutionContext)
        {
        self.context = context
        self.baseAddress = context.staticSegment.allocateWords(count: Int(Self.kTableSize))
        self.wordPointer = WordPointer(bitPattern: self.baseAddress)
        }
        
    public func registerSymbol(_ symbol: Argon.Symbol) -> Word
        {
        if symbol.isEmpty || symbol == "#"
            {
            return(0)
            }
        let cleanSymbol = String(symbol.dropFirst())
        let hash = Word(integer: cleanSymbol.polynomialRollingHash)
        let index = Int(hash % Self.kTableSize)
        let word = self.wordPointer[index]
        if word == 0
            {
            let address = context.staticSegment.allocateSymbol(symbol)
            let bucket = context.staticSegment.allocateWords(count: 3)
            let bucketStruct = UnsafeMutablePointer<Bucket>(bitPattern: bucket)
            bucketStruct.pointee.symbolPointer = address
            bucketStruct.pointee.nextPointer = 0
            bucketStruct.pointee.symbolIndex = Word(integer: symbol.polynomialRollingHash)
            self.symbolIndex += 1
            MemoryPointer.dumpMemory(atAddress: bucket,count: 3)
            self.wordPointer[index] = bucket
            return(bucketStruct.pointee.symbolIndex)
            }
        else
            {
            return(self.insertSymbol(cleanSymbol,atIndex: index))
            }
        }
        
    private func insertSymbol(_ symbol: Argon.Symbol,atIndex: Int) -> Word
        {
        var bucketPointer = BucketPointer(bitPattern: self.wordPointer[atIndex])
        repeat
            {
            let symbolAddress = bucketPointer.pointee.symbolPointer
            if let pointer = StringPointer(dirtyAddress: symbolAddress)
                {
                if pointer == symbol
                    {
                    return(bucketPointer.pointee.symbolIndex)
                    }
                }
            if bucketPointer.pointee.nextPointer != 0
                {
                bucketPointer = BucketPointer(bitPattern: bucketPointer.pointee.nextPointer)
                }
            }
        while bucketPointer.pointee.nextPointer != 0
        return(self.insertNewSymbol(symbol,atIndex: atIndex,afterBucket: bucketPointer))
        }
        
    private func insertNewSymbol(_ symbol: Argon.Symbol,atIndex: Int,afterBucket: BucketPointer) -> Word
        {
        let newBucket = self.context.staticSegment.allocateWords(count: 2)
        let newSymbol = self.context.staticSegment.allocateSymbol(symbol)
        afterBucket.pointee.nextPointer = newBucket
        let bucketPointer = BucketPointer(bitPattern: newBucket)
        bucketPointer.pointee.symbolPointer = newSymbol
        bucketPointer.pointee.nextPointer = 0
        bucketPointer.pointee.symbolIndex = Word(integer: symbol.polynomialRollingHash)
        self.symbolIndex += 1
        return(bucketPointer.pointee.symbolIndex)
        }
        
    public func symbolString(forSymbol: Word) -> String
        {
        let index = Int(forSymbol % Self.kTableSize)
        if self.wordPointer[index] == 0
            {
            fatalError("Looking for string of \(forSymbol) and it's not in the table.")
            }
        var bucket = BucketPointer(bitPattern: self.wordPointer[index])
        repeat
            {
            if bucket.pointee.symbolIndex == forSymbol
                {
                if let pointer = StringPointer(dirtyAddress: bucket.pointee.symbolPointer)
                    {
                    return(pointer.string)
                    }
                fatalError("Looking for string of \(forSymbol) and it's not in the table.")
                }
            if bucket.pointee.nextPointer != 0
                {
                bucket = BucketPointer(bitPattern: bucket.pointee.nextPointer)
                }
            }
        while bucket.pointee.nextPointer != 0
        fatalError("Looking for string of \(forSymbol) and it's not in the table.")
        }
        
    public func symbolPointer(forSymbol: Word) -> Address
        {
        let index = Int(forSymbol % Self.kTableSize)
        if self.wordPointer[index] == 0
            {
            fatalError("Looking for address of \(forSymbol) and it's not in the table.")
            }
        var bucket = BucketPointer(bitPattern: self.wordPointer[index])
        repeat
            {
            if bucket.pointee.symbolIndex == forSymbol
                {
                return(bucket.pointee.symbolPointer)
                }
            if bucket.pointee.nextPointer != 0
                {
                bucket = BucketPointer(bitPattern: bucket.pointee.nextPointer)
                }
            }
        while bucket.pointee.nextPointer != 0
        fatalError("Looking for address of \(forSymbol) and it's not in the table.")
        }
    }
