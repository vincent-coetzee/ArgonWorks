//
//  FixedSegment.swift
//  FixedSegment
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class StaticSegment:Segment
    {
    public override var startOffset: Word
        {
        return(self.baseAddress)
        }
        
    public override var endOffset: Word
        {
        return(self.nextAddress)
        }
        
    public var bytesInUse: MemorySize
        {
        return(.bytes(Int(self.nextAddress - self.baseAddress)))
        }
        
    public override var segmentType:SegmentType
        {
        .static
        }
        
    private var basePointer: UnsafeMutableRawBufferPointer
    private let baseAddress: Word
    private var nextAddress: UInt64
    private var endAddress: UInt64
    private var wordPointer: WordPointer
    
    override init(size: MemorySize)
        {
        self.basePointer = UnsafeMutableRawBufferPointer.allocate(byteCount: size.inBytes, alignment: MemoryLayout<UInt64>.alignment)
        self.baseAddress = unsafeBitCast(self.basePointer.baseAddress,to: Word.self)
        self.endAddress = baseAddress + UInt64(size.inBytes)
        if self.endAddress.doesWordHaveBitsInSecondFromTopByte
            {
            fatalError("This address has bits in the top two bytes of it which means it can't be used for enumerations etc.")
            }
        self.nextAddress = baseAddress
        self.wordPointer = WordPointer(address: self.baseAddress)!
        super.init(size:size)
        print("MANAGED SEGMENT OF SIZE \(size.inBytes) ALLOCATED AT \(self.baseAddress.addressString)")
        }

    public override func allocateAddress(sizeInBytes: Int) -> Address
        {
        let newAddress = self.allocateObject(sizeInBytes: sizeInBytes)
        let address = Address.relative(self.segmentRegister,Int(newAddress - self.baseAddress))
        return(address)
        }
        
    public override func allocateObject(sizeInBytes:Int) -> Word
        {
        if self.nextAddress >= self.endAddress
            {
            fatalError("The FixedSegment has run out of space, allocate a larger space and rerun the system")
            }
        let newPointer = self.nextAddress;
        self.nextAddress += UInt64(sizeInBytes)
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
        
    }
