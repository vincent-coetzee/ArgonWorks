//
//  StackSegment.swift
//  StackSegment
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class StackSegment: Segment
    {
    public override var spaceFree: MemorySize
        {
        return(MemorySize.bytes(Int(self.stackTop) - Int(self.stackPointer)))
        }
        
    public override var spaceUsed: MemorySize
        {
        return(MemorySize.bytes(Int(self.stackPointer-self.baseAddress)))
        }
        
    public override var segmentType:SegmentType
        {
        .stack
        }
        
    public let base: UnsafeMutableRawPointer
    public let baseAddress: Word
    public let stackTop: Word
    public var stackPointer: Word

    public override init(size: MemorySize)
        {
        self.base = malloc(size.inBytes)
        self.baseAddress = Word(bitPattern: Int64(Int(bitPattern: self.base)))
        self.stackTop = self.baseAddress + Word(size.inBytes)
        if self.stackTop.doesWordHaveBitsInSecondFromTopByte
            {
            fatalError("This address has bits in the top two bytes of it which means it can't be used for enumerations etc.")
            }
        self.stackPointer = self.stackTop - Word(MemoryLayout<Word>.size)
        super.init(size: size)
        }
            
    deinit
        {
        free(self.base)
        }
        
    public override func allocateAddress(sizeInBytes: Int) -> Address
        {
        let newAddress = self.allocateObject(sizeInBytes: sizeInBytes)
        let address = Address.relative(self.segmentRegister,Int(newAddress - baseAddress))
        return(address)
        }
        
    public override func allocateObject(sizeInBytes:Int) -> Word
        {
        if self.stackPointer >= self.baseAddress
            {
            fatalError("The StackSegment has run out of space, allocate a larger space and rerun the system")
            }
        let size = ((sizeInBytes / 8) + 1) * 8
        self.stackPointer -= Word(size)
        let newPointer = self.stackPointer
        let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(newPointer))!
        var header:Header = 0
        header.tag = .header
        header.sizeInWords = sizeInBytes / MemoryLayout<Word>.size
        header.isForwarded = false
        header.flipCount = 0
        header.hasBytes = false
        pointer[0] = header
        return(newPointer)
        }
        
    public override func allocateString(_ input:String) -> Word
        {
        let extraBytes = ((input.utf8.count / 7) + 1) * 8
        let theClass = self.virtualMachine.topModule.argonModule.string
        let totalBytes = theClass.sizeInBytes + extraBytes
        let address = self.allocateObject(sizeInBytes: totalBytes)
        if address.isZero
            {
            print("ERROR IN ManagedSegment.allocateString")
            print("ERROR ALLOCATING STRING AT \(address.addressString)")
            return(0)
            }
        let object = WordPointer(address: address)!
        object[1] = Word(bitPattern: Int64(theClass.magicNumber))      // WRITE THE _magicNumber
        object[2] = theClass.memoryAddress                             // WRITE THE _classPointer
        let objectClass = self.virtualMachine.topModule.argonModule.object
        object[3] = Word(bitPattern: Int64(0))                         // WRITE THE _ObjectHeader
        object[4] = Word(bitPattern: Int64(objectClass.magicNumber))   // WRITE THE _ObjectMagicNumber
        object[5] = objectClass.memoryAddress                          // WRITE THE _ObjectClassPointer
        let offset = UInt(address) + UInt(theClass.sizeInBytes)
        let offsetOfCount = theClass.layoutSlot(atLabel: "count")!.offset
        let bytePointer = UnsafeMutablePointer<UInt8>(bitPattern: offset)!
        let countAddress = Word(offsetOfCount) + address
        let wordPointer = WordPointer(address: countAddress)!          // WRITE THE count
        wordPointer[0] = Word(input.utf8.count)
        let string = input.utf8
        var position = 0
        var index = string.startIndex
        var count = string.count
        while position < count
            {
            if position % 7 == 0
                {
                bytePointer[position] = Self.kBitsByte
                position += 1
                count += 1
                }
            else
                {
                bytePointer[position] = string[index]
                position += 1
                index = string.index(after: index)
                }
            }
        return(address)
        }
        
    public func push(_ word:Word)
        {
        WordPointer(address: self.stackPointer)!.pointee = word
        self.stackPointer -= Word(MemoryLayout<Word>.size)
        }
        
    public func pop() -> Word
        {
        self.stackPointer += Word(MemoryLayout<Word>.size)
        return(WordPointer(address: self.stackPointer)!.pointee)
        }
    }
