//
//  BlockPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 10/2/22.
//

import Foundation

public class BlockPointer: ClassBasedPointer
    {
    public var bytesAddress: Address
        {
        Word(bitPattern: self.bytePointer)
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
        get
            {
            self.integer(atSlot: "size")
            }
        set
            {
            self.setInteger(newValue,atSlot: "size")
            }
        }
        
    public var startIndex: Int
        {
        get
            {
            self.integer(atSlot: "startIndex")
            }
        set
            {
            self.setInteger(newValue,atSlot: "startIndex")
            }
        }
        
    public var stopIndex: Int
        {
        get
            {
            self.integer(atSlot: "stopIndex")
            }
        set
            {
            self.setInteger(newValue,atSlot: "stopIndex")
            }
        }
        
    public var nextBlockAddress: Address?
        {
        get
            {
            self.address(atSlot: "count")
            }
        set
            {
            self.setAddress(newValue,atSlot: "count")
            }
        }
        
    private var dataPointer: WordPointer
    private var bytePointer: BytePointer
    private let argonModule: ArgonModule
    
    public init(address: Address,argonModule: ArgonModule)
        {
        self.argonModule = argonModule
        self.dataPointer = WordPointer(bitPattern: address + Word(argonModule.block.instanceSizeInBytes))
        self.bytePointer = BytePointer(bitPattern: address + Word(argonModule.block.instanceSizeInBytes))
        super.init(address: address,class: argonModule.block as! TypeClass,argonModule: argonModule)
        }
        
    public func append(_ word: Word)
        {
        if self.count + 1 >= self.size
            {
            fatalError("Size of block exceeded")
            }
        }
        
    public subscript(_ index: Int) -> Word
        {
        get
            {
            self.wordPointer[index]
            }
        set
            {
            self.wordPointer[index] = newValue
            }
        }
        
    public subscript(_ index: Int) -> UInt8
        {
        get
            {
            self.bytePointer[index]
            }
        set
            {
            self.bytePointer[index] = newValue
            }
        }
    }
