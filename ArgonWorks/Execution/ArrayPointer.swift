//
//  ArrayPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public class ArrayPointer: ObjectPointer,Collection
    {
    public override class func sizeInBytes() -> Int
        {
        144
        }
    
    public var startIndex: Int
        {
        return(0)
        }
    
    public var endIndex: Int
        {
        return(self.count - 1)
        }
    
    public var array: Addresses
        {
        get
            {
            var array = Addresses()
            for index in 0..<self.count
                {
                array.append(self[index])
                }
            return(array)
            }
        set
            {
            if newValue.count > self.size
                {
                fatalError()
                }
            self.count = 0
            for element in newValue
                {
                self.append(element)
                }
            }
        }
        
    public var count: Int
        {
        get
            {
            Int(self.wordPointer[13])
            }
        set
            {
            self.wordPointer[13] = Word(newValue)
            }
        }
        
    public var size: Int
        {
        Int(self.wordPointer[15])
        }
        
    internal var elementPointer: WordPointer
    
    public required init?(dirtyAddress: Word)
        {
        self.elementPointer = WordPointer(bitPattern: dirtyAddress.cleanAddress + Word(16 * MemoryLayout<Word>.size))
        super.init(dirtyAddress: dirtyAddress)
        }
        
    public func index(after: Int) -> Int
        {
        after + 1
        }
        
    public override subscript(_ index: Int) -> Word
        {
        get
            {
            return(self.elementPointer[index])
            }
        set
            {
            self.elementPointer[index] = newValue
            }
        }
        
    public func append(_ addressable: Addressable)
        {
        if self.count >= self.size
            {
            fatalError("Can not append more the \(self.size) elements.")
            }
        self[self.count] = addressable.dirtyAddress
        self.count += 1
        }
        
    public func append(_ word: Word)
        {
        if self.count >= self.size
            {
            fatalError("Can not append more the \(self.size) elements.")
            }
        self[self.count] = word
        self.count += 1
        }
    }
    
