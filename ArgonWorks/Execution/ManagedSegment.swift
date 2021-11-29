//
//  ManagedSegment.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 21/7/21.
//

import Foundation

public typealias FileStream = UnsafeMutablePointer<FILE>

    
public class ManagedSegment:Segment
    {
    public override var spaceFree: MemorySize
        {
        return(self.fromSpace.spaceFree)
        }
        
    public override var spaceUsed: MemorySize
        {
        return(self.fromSpace.spaceUsed)
        }
        
    public override var segmentType:SegmentType
        {
        .managed
        }
        
    private struct Space
        {
        private static let kBitsByte = UInt8(Argon.Tag.bits.rawValue) << 4
        
        public var isFull: Bool
            {
            return(self.baseAddress >= self.endAddress)
            }
            
        public var spaceFree: MemorySize
            {
            return(MemorySize.bytes(Int(self.endAddress - self.nextAddress)))
            }
            
        public var spaceUsed: MemorySize
            {
            return(MemorySize.bytes(Int(self.nextAddress - self.baseAddress)))
            }
            
        private var basePointer: UnsafeMutableRawBufferPointer
        internal let baseAddress: Word
        internal var nextAddress: UInt64
        private var endAddress: UInt64
        private var wordPointer: WordPointer
        private let size: MemorySize
        public var virtualMachine: VirtualMachine!
        
        init(size: MemorySize)
            {
            self.virtualMachine = nil
            print("ALLOCATING SPACE OF \(size.convertToHighestUnit().displayString)")
            self.size = size
            self.basePointer = UnsafeMutableRawBufferPointer.allocate(byteCount: size.inBytes, alignment: MemoryLayout<UInt64>.alignment)
            self.baseAddress = unsafeBitCast(self.basePointer.baseAddress,to: Word.self)
            self.endAddress = baseAddress + UInt64(size.inBytes)
            if self.endAddress.doesWordHaveBitsInSecondFromTopByte
                {
                fatalError("This address has bits in the top two bytes of it which means it can't be used for enumerations etc.")
                }
            self.nextAddress = baseAddress
            self.wordPointer = WordPointer(address: self.baseAddress)!
            print("MANAGED SEGMENT SPACE OF SIZE \(self.size.inBytes) ALLOCATED AT 0x\(self.baseAddress.addressString)")
            }
        
        public func deallocate()
            {
            self.basePointer.deallocate()
            }
            
        public mutating func allocateObject(sizeInBytes:Int) -> Word
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
            
        public mutating func allocateString(_ input:String) -> Word
            {
//            let extraBytes = ((input.utf8.count / 7) + 1) * 8
//            let theClass = self.virtualMachine.topModule.argonModule.string
//            let totalBytes = theClass.sizeInBytes + extraBytes
//            let address = self.allocateObject(sizeInBytes: totalBytes)
//            if address.isZero
//                {
//                print("ERROR IN ManagedSegment.allocateString")
//                print("ERROR ALLOCATING STRING AT \(address.addressString)")
//                return(0)
//                }
//            let object = WordPointer(address: address)!
//            object[1] = Word(bitPattern: Int64(theClass.magicNumber))      // WRITE THE _magicNumber
//            object[2] = theClass.memoryAddress                             // WRITE THE _classPointer
//            let objectClass = self.virtualMachine.topModule.argonModule.object
//            object[3] = Word(bitPattern: Int64(0))                         // WRITE THE _ObjectHeader
//            object[4] = Word(bitPattern: Int64(objectClass.magicNumber))   // WRITE THE _ObjectMagicNumber
//            object[5] = objectClass.memoryAddress                          // WRITE THE _ObjectClassPointer
//            let offset = UInt(address) + UInt(theClass.sizeInBytes)
//            let offsetOfCount = 56
//            let bytePointer = UnsafeMutablePointer<UInt8>(bitPattern: offset)!
//            let countAddress = Word(offsetOfCount) + address
//            let wordPointer = WordPointer(address: countAddress)!          // WRITE THE count
//            wordPointer[0] = Word(input.utf8.count)
//            let string = input.utf8
//            var position = 0
//            var index = string.startIndex
//            var count = string.count
//            while position < count
//                {
//                if position % 7 == 0
//                    {
//                    bytePointer[position] = Self.kBitsByte
//                    position += 1
//                    count += 1
//                    }
//                else
//                    {
//                    bytePointer[position] = string[index]
//                    position += 1
//                    index = string.index(after: index)
//                    }
//                }
            return(.zero)
            }
        }
    
    public override var startOffset: Word
        {
        return(self.fromSpace.baseAddress)
        }
        
    public override var endOffset: Word
        {
        return(self.fromSpace.nextAddress)
        }

    public override var virtualMachine: VirtualMachine!
        {
        didSet
            {
            self.fromSpace.virtualMachine = self.virtualMachine
            self.toSpace.virtualMachine = self.virtualMachine
            self.middleSpace.virtualMachine = self.virtualMachine
            self.finalSpace.virtualMachine = self.virtualMachine
            }
        }
        
    private var fromSpace: Space
    private var toSpace: Space
    private var middleSpace: Space
    private var finalSpace: Space
    
    override init(size: MemorySize)
        {
        self.fromSpace = Space(size: size)
        self.toSpace = Space(size: size)
        self.middleSpace = Space(size: size * 3 / 4)
        self.finalSpace = Space(size: size / 2)
        super.init(size: size)
        }
            
    deinit
        {
        self.fromSpace.deallocate()
        self.toSpace.deallocate()
        self.middleSpace.deallocate()
        self.finalSpace.deallocate()
        }
        
    private func collectGarbage()
        {
        }
        
    public override func allocateObject(sizeInBytes:Int) -> Word
        {
        if self.fromSpace.isFull
            {
            self.collectGarbage()
            }
        return(self.fromSpace.allocateObject(sizeInBytes: sizeInBytes))
        }

    public override func allocateString(_ string:String) -> Word
        {
        return(self.fromSpace.allocateString(string))
        }
    }
