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
        
    public var size: Int
        {
        self.integer(atSlot: "size")
        }
        
    internal var elementPointer: WordPointer
    
    public required init?(dirtyAddress: Word)
        {
        self.elementPointer = WordPointer(bitPattern: 1)
        super.init(address: dirtyAddress.cleanAddress,class: ArgonModule.shared.array as! TypeClass)
        let offset = Word(ArgonModule.shared.array.layoutSlotCount * Argon.kWordSizeInBytesInt)
        self.elementPointer = WordPointer(bitPattern: dirtyAddress.cleanAddress + offset)
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
    }
    
