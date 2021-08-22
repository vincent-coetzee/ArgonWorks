//
//  DataSegment.swift
//  DataSegment
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class DataSegment: Segment
    {
    public override var segmentType:SegmentType
        {
        .data
        }
        
    public override var spaceFree: MemorySize
        {
        return(MemorySize.bytes(0))
        }
        
    public override var spaceUsed: MemorySize
        {
        return(MemorySize.bytes(0))
        }

    private let basePointer:UnsafeMutableRawBufferPointer
    private let baseAddress: Word
    private let endAddress: Word
    private var nextAddress: Word
    private var wordPointer: WordPointer
    
    public override init(size: MemorySize)
        {
        print("ALLOCATING SPACE FOR DATA SEGMENT OF \(MemorySize.bytes(size.inBytes).convertToHighestUnit().displayString)")
        self.basePointer = UnsafeMutableRawBufferPointer.allocate(byteCount: size.inBytes, alignment: MemoryLayout<UInt64>.alignment)
        self.baseAddress = unsafeBitCast(self.basePointer.baseAddress,to: Word.self)
        self.endAddress = baseAddress + UInt64(size.inBytes)
        if self.endAddress.doesWordHaveBitsInSecondFromTopByte
            {
            fatalError("This address has bits in the top two bytes of it which means it can't be used for enumerations etc.")
            }
        self.nextAddress = baseAddress
        self.wordPointer = WordPointer(address: self.baseAddress)!
        print("DATA SEGMENT SPACE OF SIZE \(size.inBytes) ALLOCATED AT \(self.baseAddress.addressString)")
        super.init(size: size)
        }
        
    public override func allocateAddress(sizeInBytes: Int) -> Address
        {
        let newAddress = self.allocateObject(sizeInBytes: sizeInBytes)
        let address = Address.relative(self.segmentRegister,Int(newAddress - self.baseAddress))
        return(address)
        }
        
    public override func address(offset: Word) -> Word
        {
        fatalError("This has not been implemented")
        }
        
    public override func allocateObject(sizeInBytes:Int) -> Word
        {
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
