//
//  VectorPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/2/22.
//

import Foundation
import MachMemory

public class VectorPointer: ClassBasedPointer
    {
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
        
    private var blockAddress: Address = 0
    private var baseAddress: Address = 0
    private let segment: Segment
    private var blockPointer = WordPointer(bitPattern: 1)!
    
    init(address: Address,segment: Segment)
        {
        self.segment = segment
        super.init(address: address.cleanAddress,class: ArgonModule.shared.vector as! TypeClass)
        self.blockAddress = self.address(atSlot: "block").cleanAddress
        self.baseAddress = self.blockAddress + Word(ArgonModule.shared.block.instanceSizeInBytes)
        self.blockPointer = WordPointer(bitPattern: self.baseAddress)
        }
        
    public func remove(atIndex: Int)
        {
        if atIndex >= self.count
            {
            fatalError()
            }
        let fromAddress = self.baseAddress + Word((atIndex + 1) * Argon.kWordSizeInBytesInt)
        let toAddress = self.baseAddress + Word(atIndex * Argon.kWordSizeInBytesInt)
        let fromPointer = UnsafeMutableRawPointer(bitPattern: fromAddress)
        let toPointer = UnsafeMutableRawPointer(bitPattern: toAddress)
        let size = self.count - atIndex
        memmove(toPointer,fromPointer,size)
        self.count -= 1
        }
        
    public func append(_ word: Word)
        {
        if self.count >= self.size
            {
            self.grow()
            }
        self.blockPointer[self.count] = word
        self.count += 1
        }
        
    private func grow()
        {
        let newSize = self.size * 11 / 3
        let extraBytes = newSize * MemoryLayout<Word>.size
        let newBlock = segment.allocateObject(ofType: ArgonModule.shared.block, extraSizeInBytes: extraBytes)
        let newBaseAddress = newBlock + Word(ArgonModule.shared.block.instanceSizeInBytes)
        let oldBaseAddress = self.address(atSlot: "block")! + Word(ArgonModule.shared.block.instanceSizeInBytes)
        let size = self.size * Argon.kWordSizeInBytesInt
        memcpy(UnsafeMutableRawPointer(bitPattern: newBaseAddress),UnsafeMutableRawPointer(bitPattern: oldBaseAddress),size)
        self.setAddress(newBlock,atSlot: "block")
        self.setInteger(newSize,atSlot: "size")
        self.blockAddress = newBlock
        self.baseAddress = newBaseAddress
        self.blockPointer = WordPointer(bitPattern: self.baseAddress)
        self.size = newSize
        }
        
    public subscript(_ index: Int) -> Word
        {
        get
            {
            if index >= self.count
                {
                fatalError()
                }
            return(self.blockPointer[index])
            }
        set
            {
            while index >= self.size
                {
                self.grow()
                }
            self.blockPointer[index] = newValue
            }
        }
    }
