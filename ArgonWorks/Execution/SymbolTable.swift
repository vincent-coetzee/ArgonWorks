//
//  SymbolTable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/12/21.
//

import Foundation

public class SymbolTable
    {
    private static let kTableSize = 1024
    
    private let baseAddress: Address
    private let context: ExecutionContext
    private let wordPointer: WordPointer
    
    init(context: ExecutionContext)
        {
        self.context = context
        self.baseAddress = context.staticSegment.allocateWords(count: Self.kTableSize)
        self.wordPointer = WordPointer(bitPattern: self.baseAddress)
        }
        
    public func addSymbol(_ symbol: Argon.Symbol) -> Address
        {
        let hash = symbol.polynomialRollingHash
        let index = hash % Self.kTableSize
        let word = self.wordPointer[index]
        if word == 0
            {
            let address = context.staticSegment.allocateSymbol(symbol)
            let bucket = context.staticSegment.allocateWords(count: 2)
            let bucketPointer = WordPointer(bitPattern: bucket)
            bucketPointer[0] = address
            bucketPointer[1] = 0
            return(address)
            }
        else
            {
            return(self.insertSymbol(symbol,atIndex: index))
            }
        }
        
    private func insertSymbol(_ symbol: Argon.Symbol,atIndex: Int) -> Address
        {
        var bucketPointer = WordPointer(bitPattern: self.wordPointer[atIndex])
        while bucketPointer[1] != 0
            {
            let symbolAddress = bucketPointer[0]
            if let pointer = StringPointer(dirtyAddress: symbolAddress)
                {
                if pointer == symbol
                    {
                    return(symbolAddress)
                    }
                }
            else
                {
                bucketPointer = WordPointer(bitPattern: bucketPointer[1])
                }
            }
        return(self.insertNewSymbol(symbol,atIndex: atIndex,afterBucket: bucketPointer))
        }
        
    private func insertNewSymbol(_ symbol: Argon.Symbol,atIndex: Int,afterBucket: WordPointer) -> Address
        {
        let newBucket = self.context.staticSegment.allocateWords(count: 2)
        let newSymbol = self.context.staticSegment.allocateSymbol(symbol)
        afterBucket[1] = newBucket
        let bucketPointer = WordPointer(bitPattern: newBucket)
        bucketPointer[0] = newSymbol
        bucketPointer[1] = 0
        return(newSymbol)
        }
    }
