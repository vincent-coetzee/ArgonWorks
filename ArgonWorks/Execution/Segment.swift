//
//  Segment.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/12/21.
//

import Foundation
import MachMemory

public struct RuntimeIssue: Error
    {
    internal let message: String
    
    init(_ message: String)
        {
        self.message = message
        }
    }
    
public class Segment
    {
    public static var pointersNeedingBackpatching = Array<ObjectPointer>()
    
    public enum SegmentType:Word
        {
        case empty =      0
        case `static` =   1099511627776
        case code =       2199023255552
        case stack =      4398046511104
        case managed =    8796093022208
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
        .empty
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
    
    public init(memorySize: MemorySize,argonModule: ArgonModule) throws
        {
        self.segmentSizeInBytes = (memorySize.inBytes / 4096) * 4096
        self.allocatedSizeInBytes = segmentSizeInBytes
        let address = Self.segmentType.rawValue
        let size = vm_size_t(self.segmentSizeInBytes)
        self.baseAddress = AllocateSegment(address,size)
        if self.baseAddress != address
            {
            throw(RuntimeIssue("Requested segment address and allocated segment address are different."))
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
    internal func align(_ value: Word,to alignment: Word) -> Word
        {
        let mask = Int(alignment - 1)
        return(Word((Int(value) + (-Int(value) & mask)) + Int(alignment)))
        }

    internal func align(_ value: Int,to alignment: Word) -> Word
        {
        let mask = Int(alignment - 1)
        return(Word((value + (-value & mask)) + Int(alignment)))
        }
        
    internal func align(_ value: Word) -> Word
        {
        let mask = Int(self.alignment - 1)
        return(Word((Int(value) + (-Int(value) & mask)) + Int(self.alignment)))
        }

    internal func align(_ value: Int) -> Word
        {
        let mask = Int(self.alignment - 1)
        return(Word((value + (-value & mask)) + Int(self.alignment)))
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
        symbol.memoryAddress = address
        print("ALLOCATED \(size) BYTES AT \(address) FOR \(Swift.type(of: symbol)) \(symbol.label)")
        }
        
    public func allocateWords(count:Int) -> Address
        {
        let size = self.align(count * Argon.kWordSizeInBytesInt,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += size
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
        let sizeInBytes = methodInstance.sizeInBytes
        let size = self.align(sizeInBytes,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += size
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let header = Header(atAddress: address)
        header.tag = .header
        header.sizeInBytes = size
        methodInstance.memoryAddress = address
        let addressString = String(format: "%16X",address)
        print("STARTING DUMP OF METHOD INSTANCE AT ADDRESS \(addressString)")
        MemoryPointer.dumpMemory(atAddress: address,count: 200)
        print("HEADER SIZE IN BYTES = \(header.sizeInBytes)")
        print("ALLOCATED \(size) BYTES AT \(address) FOR METHOD INSTANCE \(methodInstance.label)")
        }
        
    public func allocateObject(ofClass aClass: Class,sizeOfExtraBytesInBytes: Int) -> Address
        {
        let size = self.align(aClass.instanceSizeInBytes + sizeOfExtraBytesInBytes)
        let address = self.nextAddress
        self.nextAddress += size
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let objectPointer = ClassBasedPointer(address: address.cleanAddress,class: aClass)
        objectPointer.tag = .header
        objectPointer.setClass(aClass)
        objectPointer.hasBytes = sizeOfExtraBytesInBytes > 0
        objectPointer.flipCount = 0
        objectPointer.isForwarded = false
        objectPointer.sizeInBytes = size
        return(address)
        }
        
    public func allocateObject(ofClass type: Type,sizeOfExtraBytesInBytes: Int) -> Address
        {
        return(self.allocateObject(ofClass: type.classValue, sizeOfExtraBytesInBytes: sizeOfExtraBytesInBytes))
        }
        
    public func allocateModule(_ module: Module) -> Address
        {
        let sizeInBytes = self.align(module.sizeInBytes,to: self.alignment)
        let address = self.nextAddress
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        self.nextAddress += sizeInBytes
        if let objectPointer = ObjectPointer(dirtyAddress: address)
            {
            objectPointer.tag = .header
            objectPointer.magicNumber = (self.argonModule.lookup(label: "Module") as! Type).magicNumber
            objectPointer.hasBytes = false
            objectPointer.flipCount = 0
            objectPointer.isForwarded = false
            objectPointer.sizeInBytes = sizeInBytes
            }
        return(address)
        }
        
    public func allocateSymbol(_ string: String) -> Address
        {
        let stringType = self.argonModule.lookup(label: "Symbol") as! Type
        let sizeInBytes = self.align(stringType.instanceSizeInBytes,to: self.alignment)
        let count = string.utf16.count + 2
        let extraSize = self.align(count * 2 + (count / 3 + 1) * 2,to: self.alignment)
        let totalSizeInBytes = self.align(extraSize + sizeInBytes,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += Word(totalSizeInBytes)
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        if let stringPointer = StringPointer(dirtyAddress: address)
            {
            stringPointer.string = string
            }
        let objectPointer = ClassBasedPointer(address: address,type: stringType)
        objectPointer.tag = .header
        objectPointer.setClass(stringType)
        objectPointer.hasBytes = true
        objectPointer.sizeInBytes = totalSizeInBytes
        objectPointer.flipCount = 0
        objectPointer.objectType = .string
        objectPointer.tag = .header
        objectPointer.isPersistent = false
        objectPointer.isForwarded = false
        objectPointer.magicNumber = stringType.magicNumber
        return(address)
        }
        
    public func allocateEnumerationInstance(enumeration: Enumeration,caseIndex: Int,associatedValues: Words) -> Address
        {
        let instanceType = self.argonModule.lookup(label: "EnumerationInstance") as! Type
        let sizeInBytes = self.align(instanceType.instanceSizeInBytes,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += sizeInBytes
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let objectPointer = ClassBasedPointer(address: address,type: instanceType)
        objectPointer.tag = .header
        objectPointer.setClass(instanceType)
        objectPointer.hasBytes = false
        objectPointer.sizeInBytes = sizeInBytes
        objectPointer.flipCount = 0
        objectPointer.isPersistent = false
        objectPointer.isForwarded = false
        objectPointer.magicNumber = instanceType.magicNumber
        objectPointer.setAddress(enumeration.memoryAddress,atSlot: "enumeration")
        objectPointer.setInteger(caseIndex,atSlot: "caseIndex")
        let valuesAddress = self.allocateArray(size: associatedValues.count,elements: associatedValues)
        objectPointer.setAddress(valuesAddress,atSlot: "associatedValues")
        return(address)
        }
        
    public func allocateString(_ string: String) -> Address
        {
        let stringType = self.argonModule.lookup(label: "String") as! Type
        let sizeInBytes = self.align(stringType.instanceSizeInBytes,to: self.alignment)
        let count = string.utf16.count + 2
        let extraSize = self.align(count * 2 + (count / 3 + 1) * 2,to: self.alignment)
        let totalSizeInBytes = self.align(extraSize + sizeInBytes,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += Word(totalSizeInBytes)
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        if let stringPointer = StringPointer(dirtyAddress: address)
            {
            stringPointer.string = string
            }
        let objectPointer = ClassBasedPointer(address: address,type: stringType)
        objectPointer.tag = .header
        objectPointer.setClass(stringType)
        objectPointer.hasBytes = true
        objectPointer.sizeInBytes = totalSizeInBytes
        objectPointer.flipCount = 0
        objectPointer.objectType = .string
        objectPointer.tag = .header
        objectPointer.isPersistent = false
        objectPointer.isForwarded = false
        objectPointer.magicNumber = stringType.magicNumber
        return(address)
        }
        
//    public func allocateClass(class aClass: Class) -> Address
//        {
//
//        }
        
    public func allocateBootstrapSlot(name:String,offset:Int) -> Address
        {
        let slotType = self.argonModule.lookup(label: "Slot") as! Type
        let sizeInBytes = self.align(slotType.sizeInBytes,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += Word(sizeInBytes)
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        if let slotPointer = SlotPointer(dirtyAddress: address)
            {
            slotPointer.nameAddress = self.allocateString(name)
            slotPointer.offset = offset
            Self.pointersNeedingBackpatching.append(slotPointer)
            }
        Header(atAddress: address).tag = .header
        return(address)
        }
        
    public func allocateArray(size: Int) -> Address
        {
        return(self.allocateArray(size: size,elements: [] as Array<Address>))
        }
        
    public func allocateArray(size: Int,elements: Addresses) -> Address
        {
        assert(size >= elements.count,"Size of array must be >= elements.count")
        let arrayType = self.argonModule.lookup(label: "Array") as! Type
        let sizeInBytes = self.align(arrayType.sizeInBytes,to: self.alignment)
        let extraSize = self.align(size * Argon.kWordSizeInBytesInt,to: self.alignment)
        let totalSizeInBytes = self.align(extraSize + sizeInBytes,to: self.alignment)
        let address = self.nextAddress
        self.nextAddress += Word(totalSizeInBytes)
        if self.nextAddress > self.lastAddress
            {
            fatalError("Size allocation exceeded in segment \(self.segmentType).")
            }
        let arrayPointer = ClassBasedPointer(address: address,type: arrayType)
        arrayPointer.hasBytes = true
        arrayPointer.sizeInBytes = totalSizeInBytes
        arrayPointer.flipCount = 0
        arrayPointer.objectType = .array
        arrayPointer.tag = .header
        arrayPointer.isPersistent = false
        arrayPointer.isForwarded = false
        arrayPointer.setClass(arrayType)
        arrayPointer.setInteger(elements.count,atSlot: "count")
        arrayPointer.setInteger(size,atSlot: "size")
        let elementPointer = WordPointer(bitPattern: address + Word(16 * Argon.kWordSizeInBytesInt))
        var index = 0
        for element in elements
            {
            elementPointer[index] = element
            index += 1
            }
        Header(atAddress: address).tag = .header
        return(address)
        }
        
    public func allocateArray(size: Int,elements: Addressables) -> Address
        {
        let addresses = elements.map{$0.cleanAddress}
        return(self.allocateArray(size: size,elements: addresses))
        }
//
//    public func allocateBootstrapObject(ofType type: Type) -> Address
//        {
//        let objectSize = type.sizeInBytes
//        let offset = self.nextAddress - self.baseAddress
//
//        }
//
//    public func allocateString(_ string: String) -> Address
//        {
//        let stringLength = string.utf16.count + 1
//        let stringType = argonModule.lookup(label: "String") as! Type
//        let totalSize = stringType.sizeInBytes + stringLength
//        let address = self.allocateObject(ofType: stringType)
//        }
        
    public func display(indent: String,count: Int)
        {
        for index in 0..<count
            {
            let offset = String(format: "%06d",index)
            let data = String(format: "%012X",self.wordPointer[index])
            print("\(indent)[\(offset)] \(data) \(self.wordPointer[index])")
            }
        }
    }
