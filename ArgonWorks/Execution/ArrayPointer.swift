//
//  ArrayPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public class ArrayPointer: ClassBasedPointer,Collection,Pointer
    {
    public var cleanAddress: Address
        {
        self.address.cleanAddress
        }
        
    public var dirtyAddress: Address
        {
        self.address
        }
        
    public var startIndex: Int
        {
        return(0)
        }
    
    public var endIndex: Int
        {
        return(self.count)
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
            self.integer(atSlot: "count")
            }
        set
            {
            self.setInteger(newValue,atSlot: "count")
            }
        }
        
    public var block: Address?
        {
        get
            {
            self.address(atSlot: "block")
            }
        set
            {
            self.setAddress(newValue,atSlot: "block")
            let offset = newValue!.cleanAddress + Word(self.argonModule.block.instanceSizeInBytes)
            self.elementPointer = WordPointer(bitPattern: offset)
            }
        }
        
    public var size: Int
        {
        self.integer(atSlot: "size")
        }
        
    internal var argonModule: ArgonModule
    internal var elementPointer: WordPointer!
    
    public required init?(dirtyAddress: Word,argonModule: ArgonModule)
        {
        self.argonModule = argonModule
        self.elementPointer = WordPointer(bitPattern: 1)
        super.init(address: dirtyAddress.cleanAddress,class: self.argonModule.array as! TypeClass,argonModule: argonModule)
        if let blockAddress = self.address(atSlot: "block")
            {
            let offset = blockAddress + Word(self.argonModule.block.instanceSizeInBytes)
            self.elementPointer = WordPointer(bitPattern: offset)
            }
        }
        
    public func index(after: Int) -> Int
        {
        after + 1
        }
        
    public subscript(_ index: Int) -> Word
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
        self[self.count] = Word(pointer: addressable.cleanAddress)
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
        
    public static func test(inSegment segment: Segment)
        {
        let array1 = segment.allocateArray(size: 15)
        let pointer1 = ArrayPointer(dirtyAddress: array1,argonModule: segment.argonModule)!
        for index in 0..<15
            {
            pointer1[index] = Word(integer: index)
            pointer1.count += 1
            }
        assert(pointer1.count == 15)
        assert(pointer1.size == 15)
        for index in 0..<15
            {
            assert(pointer1[index] == Word(index))
            }
        }
    }
    
