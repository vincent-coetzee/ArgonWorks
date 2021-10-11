//
//  InnerInstructionBufferPointer.swift
//  InnerInstructionBufferPointer
//
//  Created by Vincent Coetzee on 19/8/21.
//

///
///
/// An InnerInstructionBufferPointer differs from the various other
/// instruction array points and buffers and so by cirtue of the fact
/// it actually CONTAINS the 4 WORD encoded instruction in it's buffers,
/// it does not just point to them like the other pointer types or buffers
/// do. This allocates enough space to contain the encoded form of
/// the instructions added to it.
///
///
import Foundation

public class InnerInstructionBufferPointer: InnerPointer
    {
    public class func allocate(bufferCount: Int,in vm: VirtualMachine) -> InnerInstructionBufferPointer
        {
        let sizeInBytes = 8 * MemoryLayout<Word>.size + 4 * bufferCount * MemoryLayout<Word>.size
        let address = vm.managedSegment.allocateObject(sizeInBytes: sizeInBytes)
        let wordPointer = WordPointer(address: address)
        wordPointer![4] = Word(bitPattern: Int64(vm.topModule.argonModule.object.magicNumber))
        wordPointer![5] = vm.topModule.argonModule.object.memoryAddress
        wordPointer![7] = 0
        return(InnerInstructionBufferPointer(address: address))
        }
        
    public var instructionsAddress: Word
        {
        return(self.address + Word(8 * MemoryLayout<Word>.size))
        }
        
    public var count: Int
        {
        get
            {
            return(self.intSlotValue(atKey: "count"))
            }
        set
            {
            self.setSlotValue(newValue,atKey: "count")
            }
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kArraySizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","count"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
    public func append(_ instruction:Instruction)
        {
        let index = 8 + Word(self.count)
        let instructionPointer = WordPointer(address: self.address + index * Word(MemoryLayout<Word>.size))
//        instruction.write(to: instructionPointer!)
        self.count += 1
        }
    }
