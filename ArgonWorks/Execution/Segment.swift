//
//  Segment.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/12/21.
//

import Foundation
import MachMemory

public enum RuntimeIssue: Error
    {
    case outOfFlipSpace
    case requestedAddressDiffersFromActualAddress
    case invalidAddressAllocated
    }
    
public class Segment
    {
    public enum SegmentType:Word
        {
        case `static` =     68719476736
        case code =        137438953472
        case stack =       274877906944
        case managed =     549755813888
        case space =      1099511627776
        }

    public static let emptySegment = EmptySegment()
    
    public var usedSizeInBytes: Int
        {
        Int(UInt64(self.nextAddress) - self.baseAddress)
        }
        
    public var isEmptySegment: Bool
        {
        false
        }
        
    public class var segmentType: SegmentType
        {
        fatalError()
        }
        
    public var segmentType: SegmentType
        {
        Self.segmentType
        }
        
    public let alignment = Word(MemoryLayout<Word>.alignment)
    
    internal let baseAddress: mach_vm_address_t
    internal let lastAddress: Word
    internal let segmentSizeInBytes: Int
    internal var nextAddress: Word
    internal var wordPointer: WordPointer
    internal let argonModule: ArgonModule
    internal let allocatedSizeInBytes: Int
    internal let pageSizeInBytes: Int32
    
    public var mustAllocateByPage: Bool = false
    public var mustProtectAllocatedPages: Bool = false
    
    public init(memorySize: MemorySize,argonModule: ArgonModule) throws
        {
        self.pageSizeInBytes = getpagesize()
        self.segmentSizeInBytes = (memorySize.inBytes / 4096) * 4096
        self.allocatedSizeInBytes = segmentSizeInBytes
        let address = Self.segmentType.rawValue
        let size = vm_size_t(self.segmentSizeInBytes)
        self.baseAddress = AllocateSegment(address,size)
        if self.baseAddress != address
            {
            throw(RuntimeIssue.requestedAddressDiffersFromActualAddress)
            }
        self.lastAddress = self.baseAddress + Word(self.segmentSizeInBytes)
        self.argonModule = argonModule
        self.nextAddress = self.baseAddress
        self.wordPointer = WordPointer(bitPattern: self.baseAddress)
        }
        
    deinit
        {
        let errorCode = DeallocateSegment(self.baseAddress,vm_size_t(self.segmentSizeInBytes))
        if errorCode != 0
            {
            print("ERROR: \(errorCode) deallocating segment at address \(String(format: "%X",self.baseAddress)) of size \(self.segmentSizeInBytes).")
            }
        }
        
    public func write(toStream: UnsafeMutablePointer<FILE>) throws
        {
        fwrite(UnsafeRawPointer(bitPattern: Int(self.baseAddress)),self.usedSizeInBytes,1,toStream)
        }
    ///
    /// Align the given value to the given alignment but make sure
    /// that it is always bigger by 1 x the alignment, this is to make
    /// sure that when a size is aligned, the returned size is always
    /// at least big enoughn to accomodate the given size.
    ///
    internal static func alignWordToWord(_ value: Word) -> Word
        {
        if value & 7 == 0
            {
            return(value)
            }
        return((value & ~7) + 8)
        
        }
        
    internal func reset()
        {
        ResetMemory(self.baseAddress,Word(self.segmentSizeInBytes))
        self.nextAddress = self.baseAddress
        }
        
    internal func alignToPageBoundary(_ value: Word) -> Word
        {
        Self.alignWordToWord(value)
        }
        
    internal func align(_ value: Word,to alignment: Word) -> Word
        {
        Self.alignWordToWord(value)
        }

    internal func align(_ value: Int,to alignment: Word) -> Word
        {
        Self.alignWordToWord(Word(value))
        }
        
    internal func align(_ value: Word) -> Word
        {
        Self.alignWordToWord(Word(value))
        }

    internal func align(_ value: Int) -> Word
        {
        let mask = Int(self.alignment - 1)
        return(Word((value + (-value & mask)) + Int(self.alignment)))
        }
        
    public func containsAddress(_ address: Address) -> Bool
        {
        address >= self.baseAddress && address <= self.lastAddress
        }
        
    public func allocateMemoryAddress(for symbol: Symbol)
        {
        let size = self.align(symbol.sizeInBytes + symbol.extraSizeInBytes,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += size
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let header = Header(atAddress: address)
        header.tag = .header
        header.sizeInBytes = size
        symbol.setMemoryAddress(address)
//        print("ALLOCATED \(size) BYTES AT \(address) FOR \(Swift.type(of: symbol)) \(symbol.label)")
        }
        
    public func allocateWords(count:Int) -> Address
        {
        let size = self.align((count + 1) * Argon.kWordSizeInBytesInt,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += size
        let header = Header(atAddress: address)
        header.tag = .header
        header.sizeInBytes = size
        header.objectType = Argon.ObjectType.wordBlock
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        return(address)
        }
        
    public func allocateMemoryAddress(for aStatic: StaticObject)
        {
        let size = self.align(aStatic.sizeInBytes + aStatic.extraSizeInBytes,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += size
        let header = Header(atAddress: address)
        header.tag = .header
        header.sizeInBytes = size
        aStatic.memoryAddress = address
        }
        
    public func allocateMemoryAddress(for methodInstance: MethodInstance)
        {
//        print("ALLOCATING ADDRESS FOR METHOD INSTANCE \(methodInstance.label)")
        let size = self.align(methodInstance.sizeInBytes)
//        print("ALLOCATING \(size) BYTES")
        let address = self.nextAddress
        self.nextAddress += size
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let header = Header(atAddress: address)
        header.tag = .header
        header.sizeInBytes = size
        print(header.sizeInBytes)
        methodInstance.setMemoryAddress(address)
//        let addressString = String(format: "%16X",address)
//        print("STARTING DUMP OF METHOD INSTANCE AT ADDRESS \(addressString)")
//        MemoryPointer.dumpRawMemory(atAddress: address,count: 200)
//        MemoryPointer.dumpMemory(atAddress: address,count: 200)
//        print("HEADER SIZE IN BYTES = \(header.sizeInBytes)")
//        print("ALLOCATED \(size) BYTES AT \(address) FOR METHOD INSTANCE \(methodInstance.label)")
        }
        
    public func allocateBytes(size: Int) -> Address
        {
        let realSize = self.align(size)
        let address = self.nextAddress
        self.nextAddress += realSize
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        return(address)
        }
        
    public func allocateBlock(sizeInWords: Int) -> Address
        {
        let newSize = sizeInWords
        let extraSizeInBytes = self.align(newSize * MemoryLayout<Word>.size)
        let blockAddress = self.allocateObject(ofType: ArgonModule.shared.block,extraSizeInBytes: Int(extraSizeInBytes))
        let blockPointer = ClassBasedPointer(address: blockAddress,type: ArgonModule.shared.block)
        blockPointer.setClass(ArgonModule.shared.block)
        blockPointer.sizeInBytes = Word(ArgonModule.shared.block.instanceSizeInBytes) + extraSizeInBytes
        blockPointer.hasBytes = true
        blockPointer.objectType = .block
        blockPointer.setInteger(0,atSlot: "count")
        blockPointer.setInteger(newSize,atSlot: "size")
        blockPointer.setAddress(nil,atSlot: "nextBlock")
        blockPointer.setInteger(0,atSlot: "startIndex")
        blockPointer.setInteger(0,atSlot: "stopIndex")
        let blockAfter = blockAddress + Word(ArgonModule.shared.block.instanceSizeInBytes)
        memset(UnsafeMutableRawPointer(bitPattern: blockAfter),0,Int(extraSizeInBytes))
        return(blockAddress)
        }
        
    public func allocateVector(size: Int) -> Address
        {
        let newSize = Int(self.align(size * Argon.kWordSizeInBytesInt) / Argon.kWordSizeInBytesWord)
        let blockAddress = self.allocateBlock(sizeInWords: newSize)
        let vectorAddress = self.allocateObject(ofType: ArgonModule.shared.vector)
        let pointer = ClassBasedPointer(address: vectorAddress, type: ArgonModule.shared.vector)
        pointer.setClass(ArgonModule.shared.vector)
        pointer.objectType = .vector
        pointer.sizeInBytes = Word(ArgonModule.shared.vector.instanceSizeInBytes)
        pointer.setAddress(blockAddress,atSlot: "block")
        pointer.setInteger(0,atSlot: "count")
        pointer.setInteger(newSize,atSlot: "size")
        let blockPointer = ClassBasedPointer(address: blockAddress,type: ArgonModule.shared.block)
        blockPointer.setInteger(0,atSlot: "count")
        blockPointer.setInteger(newSize,atSlot: "size")
        blockPointer.setAddress(nil,atSlot: "nextBlock")
        blockPointer.setInteger(0,atSlot: "startIndex")
        blockPointer.setInteger(newSize,atSlot: "stopIndex")
        return(vectorAddress)
        }
        
    public func allocateInstructionBlock(for methodInstance: MethodInstance) -> Address
        {
        let bytesSize = methodInstance.instructionsSizeInBytes
        let type = ArgonModule.shared.instructionBlock
        let totalSize = self.align(type.instanceSizeInBytes + bytesSize + Argon.kWordSizeInBytesInt)
        let address = self.nextAddress
        self.nextAddress += totalSize
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let objectPointer = ClassBasedPointer(address: address.cleanAddress,type: type)
        objectPointer.tag = .header
        objectPointer.objectType = .instructionBlock
        objectPointer.setClass(type)
        objectPointer.hasBytes = true
        objectPointer.flipCount = 0
        objectPointer.isForwarded = false
        objectPointer.sizeInBytes = totalSize
        return(address)
        }
        
    public func allocateObject(ofType type: Type) -> Address
        {
        self.allocateObject(ofType: type,extraSizeInBytes: 0)
        }
        
    public func allocateObject(ofType type: Type,extraSizeInBytes: Int) -> Address
        {
        assert(type.isClass,"Creating an object can only be done with a class, enumerations can not be allocated.")
        let size = self.align(type.instanceSizeInBytes + extraSizeInBytes)
        let address = self.nextAddress
        self.nextAddress += size
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let objectPointer = ClassBasedPointer(address: address.cleanAddress,type: type)
        objectPointer.tag = .header
        objectPointer.setClass(type)
        objectPointer.hasBytes = false
        objectPointer.flipCount = 0
        objectPointer.isForwarded = false
        objectPointer.sizeInBytes = size
        objectPointer.setInteger(address.intValue,atSlot: "hash")
        return(address)
        }
        
    public func allocateSymbol(_ string: String) -> Address
        {
        let symbolType = self.argonModule.lookup(label: "Symbol") as! TypeClass
        let sizeInBytes = Self.alignWordToWord(Word(symbolType.instanceSizeInBytes))
        let count = string.utf16.count + 2
        let extraSizeInBytes = (count / 3 * 4) * 2 + 4
        var totalSizeInBytes = Word(extraSizeInBytes) + sizeInBytes
        var address = Self.alignWordToWord(self.nextAddress)
        if self.mustAllocateByPage
            {
            address = self.alignToPageBoundary(address)
            assert(totalSizeInBytes < Int(self.pageSizeInBytes))
            totalSizeInBytes = Word(self.pageSizeInBytes)
            }
        self.nextAddress = address + totalSizeInBytes
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let stringPointer = SymbolPointer(address: address)
        stringPointer.string = string
        let objectPointer = ClassBasedPointer(address: address,type: symbolType)
        objectPointer.objectType = .symbol
        objectPointer.setClass(symbolType)
        objectPointer.sizeInBytes = totalSizeInBytes
//        MemoryPointer.dumpMemory(atAddress: address, count: Int(totalSizeInBytes) / 8 + 10)
        if self.mustProtectAllocatedPages
            {
            let pointer = UnsafeMutableRawPointer(bitPattern: address)
            mprotect(pointer,Int(self.pageSizeInBytes),PROT_READ)
            }
        return(address)
        }
        
    public func allocateBucket(nextBucketAddress: Address?,bucketValue: Address?,bucketKey: Word) -> Address
        {
        let bucketType = ArgonModule.shared.bucket
        let sizeInBytes = Self.alignWordToWord(Word(bucketType.instanceSizeInBytes))
        let address = Self.alignWordToWord(self.nextAddress)
        self.nextAddress = address + sizeInBytes
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let objectPointer = ClassBasedPointer(address: address,type: bucketType)
        objectPointer.objectType = .bucket
        objectPointer.setClass(bucketType)
        objectPointer.sizeInBytes = sizeInBytes
        objectPointer.setAddress(nextBucketAddress,atSlot: "nextBucket?")
        objectPointer.setAddress(bucketValue,atSlot: "bucketValue")
        objectPointer.setWord(bucketKey,atSlot: "bucketKey")
//        MemoryPointer.dumpMemory(atAddress: address, count: Int(sizeInBytes) + Argon.kWordSizeInBytesInt)
        return(address)
        }
        
    public func allocateString(_ string: String) -> Address
        {
        let stringType = self.argonModule.lookup(label: "String") as! TypeClass
        let sizeInBytes = self.align(stringType.instanceSizeInBytes,to: self.alignment)
        let count = (string.utf16.count + 16) / 4
        let blockAddress = self.allocateBlock(sizeInWords:  count)
        let address = self.nextAddress
        self.nextAddress += Word(sizeInBytes)
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let stringPointer = StringPointer(address: address)
        stringPointer.setAddress(blockAddress,atSlot: "block")
        stringPointer.objectType = .string
        stringPointer.string = string
        stringPointer.tag = .header
        stringPointer.setClass(stringType)
        stringPointer.hasBytes = false
        stringPointer.sizeInBytes = sizeInBytes
        stringPointer.flipCount = 0
        stringPointer.objectType = .string
        stringPointer.isPersistent = false
        stringPointer.isForwarded = false
        return(address)
        }
        
    public func allocateArray(size: Int) -> Address
        {
        return(self.allocateArray(size: size,elements: [] as Array<Address>))
        }
        
    public func allocateArray(size: Int,elements: Addresses) -> Address
        {
        assert(size >= elements.count,"Size of array must be >= elements.count")
        let arrayType = ArgonModule.shared.array
        let sizeInBytes = self.align(arrayType.instanceSizeInBytes,to: self.alignment)
        let blockAddress = self.allocateBlock(sizeInWords: size + 1)
        let address = self.nextAddress
        self.nextAddress += Word(sizeInBytes)
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let arrayPointer = ClassBasedPointer(address: address,type: arrayType)
        arrayPointer.setAddress(blockAddress,atSlot: "block")
        arrayPointer.hasBytes = false
        arrayPointer.sizeInBytes = sizeInBytes
        arrayPointer.flipCount = 0
        arrayPointer.objectType = .array
        arrayPointer.tag = .header
        arrayPointer.isPersistent = false
        arrayPointer.isForwarded = false
        arrayPointer.setClass(arrayType)
        arrayPointer.setInteger(elements.count,atSlot: "count")
        arrayPointer.setInteger(size,atSlot: "size")
        let elementPointer = WordPointer(bitPattern: blockAddress + Word(ArgonModule.shared.block.instanceSizeInBytes))
        var index = 0
        for element in elements
            {
            elementPointer[index] = element
            index += 1
            }
        let blockPointer = ClassBasedPointer(address: blockAddress,type: ArgonModule.shared.block)
        blockPointer.setInteger(elements.count,atSlot: "count")
        blockPointer.setInteger(size,atSlot: "size")
        blockPointer.setAddress(nil,atSlot: "nextBlock")
        blockPointer.setInteger(0,atSlot: "startIndex")
        blockPointer.setInteger(elements.count - 1,atSlot: "stopIndex")
        Header(atAddress: address).tag = .header
        return(address)
        }
        
    public func allocateArray(size: Int,elements: Addressables) -> Address
        {
        let addresses = elements.map{$0.cleanAddress}
        return(self.allocateArray(size: size,elements: addresses))
        }
        
    public func display(indent: String,count: Int)
        {
        for index in 0..<count
            {
            let offset = String(format: "%06d",index)
            let data = String(format: "%012X",self.wordPointer[index])
            print("\(indent)[\(offset)] \(data) \(self.wordPointer[index])")
            }
        }
        
    public func testSegment()
        {
        let symbol = "symbol"
        let symbolAddress = self.allocateSymbol(symbol)
        let strings = ["one","two","three","four"]
        let arrayAddress = self.allocateArray(size: 4)
        let arrayPointer = ArrayPointer(dirtyAddress: arrayAddress)!
        for string in strings
            {
            let stringAddress = Word(pointer: self.allocateString(string))
            arrayPointer.append(stringAddress)
            }
        MemoryPointer.dumpMemory(atAddress: symbolAddress,count: 100)
        }
    }
