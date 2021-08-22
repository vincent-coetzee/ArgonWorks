//
//  InnerBlockPointer.swift
//  InnerBlockPointer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class InnerBlockPointer: InnerPointer
    {
    public static func allocate(arraySize:Int,in vm: VirtualMachine) -> InnerBlockPointer
        {
        let size = arraySize * 3 / 2
        let totalSize = Self.kBlockSizeInBytes + (size * 8)
        let address = vm.managedSegment.allocateObject(sizeInBytes: totalSize)
        let pointer = InnerBlockPointer(address: address)
        pointer.setClass(vm.topModule.argonModule.block)
        pointer.headerTypeCode = .block
        pointer.size = size
        pointer.count = 0
        return(pointer)
        }
    
    public var count: Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"count")))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"count")
            }
        }
        
    public var size: Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"blockSize")))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"blockSize")
            }
        }
        
    public var nextBlock: Word
        {
        get
            {
            return(Word(self.slotValue(atKey:"nextBlock")))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"nextBlock")
            }
        }
        
    internal var basePointer:WordPointer
    
    required init(address:Word)
        {
        self.basePointer = WordPointer(address: address + Word(Self.kArraySizeInBytes))!
        super.init(address: address)
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kBlockSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","blockSize","count","nextBlock"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
    public subscript(_ index:Int) -> Word
        {
        get
            {
            return(self.basePointer[index])
            }
        set
            {
            self.basePointer[index] = newValue
            }
        }
        
    internal func copy(from block:InnerBlockPointer,count: Int)
        {
        self.basePointer.assign(from: block.basePointer,count: count)
        }
    }
