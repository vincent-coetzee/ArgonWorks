//
//  Segment.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/12/21.
//

import Foundation

public class Segment
    {
    public enum SegmentType:UInt8
        {
        case empty = 0
        case stack = 1
        case data = 2
        case managed = 3
        case `static` = 4
        case pending = 5
        }
        
    public static let emptySegment = EmptySegment()
    
    public var isEmptySegment: Bool
        {
        false
        }
        
    public var segmentType: SegmentType
        {
        .empty
        }
        
    public let alignment = MemoryLayout<Word>.alignment

    private let basePointer: UnsafeMutableRawPointer
    internal let baseAddress: Word
    internal let lastAddress: Word
    internal let size: Word
    internal var nextAddress: Word
    internal var wordPointer: WordPointer
    internal let argonModule: ArgonModule
    
    public init(memorySize: MemorySize,argonModule: ArgonModule)
        {
        self.argonModule = argonModule
        let sizeInBytes = memorySize.inBytes
        self.basePointer = UnsafeMutableRawPointer.allocate(byteCount: sizeInBytes, alignment: MemoryLayout<Word>.alignment)
        self.baseAddress = Word(bitPattern: self.basePointer)
        self.lastAddress = self.baseAddress + Word(sizeInBytes)
        self.nextAddress = self.baseAddress
        self.wordPointer = WordPointer(bitPattern: self.baseAddress)
        self.size = Word(sizeInBytes)
        }
        
    internal func align(_ value: Int,to alignment: Int) -> Int
        {
        let mask = alignment - 1
        return(value + (-value & mask))
        }
        
    public func allocate(sizeInBytes: Int) -> Address
        {
        let offset = self.nextAddress
        let actualSize = self.align(sizeInBytes,to: self.alignment)
        self.nextAddress += Word(actualSize)
        return(offset)
        }
        
//    public func allocateBootstrapString(_ string: String) -> Address
//        {
//        let stringType = self.argonModule.lookup(label: "String") as! Type
//        let objectType = self.argonModule.lookup(label: "Object") as! Type
//        let sizeInBytes = self.align(stringType.sizeInBytes,to: self.alignment)
//        let count = string.utf16.count + 2
//        let extraSize = self.align(string.utf16.count + 1,to: self.alignment)
//        let totalSizeInBytes = self.align(extraSize + sizeInBytes,to: self.alignment)
//        let address = self.nextAddress
//        self.nextAddress += Word(totalSizeInBytes)
//        let bytesOffset = address + Word(sizeInBytes)
//        let pointer = WordPointer(bitPattern: address)
//        pointer[0] = 0
//        pointer[1] = Word(stringType.magicNumber)
//        pointer[3] = 0
//        pointer[4] = Word(objectType.magicNumber)
//        pointer[5] = 0
//        pointer[6] = Word(string.utf16.count)
//        for character in string.utf16
//            {
//            }
//        }
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

public class EmptySegment: Segment
    {
   public override var isEmptySegment: Bool
        {
        true
        }
        
    public init()
        {
        super.init(memorySize: .bytes(8),argonModule: ArgonModule())
        }
        
    public override func allocate(sizeInBytes: Int) -> Address
        {
        fatalError("This should not be called on an EmptySegment")
        }
    }
    
public class StackSegment: Segment
    {
    public override var segmentType: SegmentType
        {
        .stack
        }
        
    public static let kFirstTemporaryOffset = -2 * Argon.kWordSizeInBytesInt
    public static let kFirstArgumentOffset = 2 * Argon.kWordSizeInBytesInt
    
    internal private(set) var stackPointer: Word
    internal private(set) var framePointer: Word

    public override init(memorySize: MemorySize,argonModule: ArgonModule)
        {
        self.stackPointer = 0
        self.framePointer = 0
        super.init(memorySize: memorySize,argonModule: argonModule)
        self.stackPointer = self.lastAddress
        self.framePointer = self.stackPointer

        }
        
    public override func allocate(sizeInBytes: Int) -> Address
        {
        let actualSize = self.align(sizeInBytes,to: self.alignment)
        self.stackPointer -= Word(actualSize)
        self.nextAddress = self.stackPointer
        return(self.stackPointer)
        }
        
    public override func display(indent: String,count: Int)
        {
        var pointer = WordPointer(bitPattern: self.lastAddress - Argon.kWordSizeInBytesWord)
        for index in 0..<count
            {
            let address = Word(bitPattern: pointer)
            let addressString = String(format: "%012X",address)
            let offset = String(format: "%06d",index)
            let value = pointer[0]
            let data = String(format: "%012X",value)
            var extra = ""
            extra = address == self.stackPointer ? "<--SP" : ""
            extra = address == self.framePointer ? extra + "<--FP" : extra
            print("\(indent)\(addressString) [\(offset)] \(data) \(value) \(extra)")
            pointer -= 1
            }
        }
        
    @inline(__always)
    public func push(_ word: Word)
        {
        self.stackPointer -= Argon.kWordSizeInBytesWord
        self.wordPointer[Int(self.stackPointer - self.baseAddress) / Argon.kWordSizeInBytesInt] = word
        }
        
    @inline(__always)
    @discardableResult
    public func pop() -> Word
        {
        let value = self.wordPointer[Int(self.stackPointer - self.baseAddress) / Argon.kWordSizeInBytesInt]
        self.stackPointer += Argon.kWordSizeInBytesWord
        return(value)
        }
        
    @inline(__always)
    private func valueAt(base: Word,offset: Int) -> Word
        {
        let index = ((Int(base) + offset) - Int(self.baseAddress)) / Argon.kWordSizeInBytesInt
        return(self.wordPointer[index])
        }
        
    @inline(__always)
    private func setValue(_ value: Word,atBase: Word,offset: Int)
        {
        let index = ((Int(atBase) + offset) - Int(self.baseAddress)) / Argon.kWordSizeInBytesInt
        self.wordPointer[index] = value
        }
        
    @inline(__always)
    public func localSlot(atOffset: Int) -> Word
        {
        let index = ((Int(self.framePointer) + atOffset) - Int(self.baseAddress) - Argon.kWordSizeInBytesInt) / Argon.kWordSizeInBytesInt
        return(self.wordPointer[index])
        }
        
    @inline(__always)
    public func setLocalSlot(_ slotValue:Word,atOffset: Int)
        {
        let index = ((Int(self.framePointer) + atOffset) - Int(self.baseAddress) - Argon.kWordSizeInBytesInt) / Argon.kWordSizeInBytesInt
        self.wordPointer[index] = slotValue
        }
        
    @inline(__always)
    public func argument(atOffset: Int) -> Word
        {
        let index = ((Int(self.framePointer) + atOffset) - Int(self.baseAddress) - Argon.kWordSizeInBytesInt) / Argon.kWordSizeInBytesInt
        return(self.wordPointer[index])
        }
        
    public func enterFrame(arguments: Words,localCount: Int,currentFrameAddress: Word)
        {
        for argument in arguments.reversed()
            {
            self.push(argument)
            }
        self.push(self.framePointer)
        self.framePointer = self.stackPointer
        self.push(currentFrameAddress)
        self.push(Word(localCount))
        self.stackPointer -= Word(localCount) * Argon.kWordSizeInBytesWord
        }
        
    public func exitFrame() -> Word
        {
        let localCount = self.valueAt(base: self.framePointer,offset: -2 * Argon.kWordSizeInBytesInt)
        self.stackPointer += localCount * Argon.kWordSizeInBytesWord
        self.pop() /// GET RID OF LOCAL COUNT
        let returnAddress = self.pop()
        self.framePointer = self.pop()
        return(returnAddress)
        }
        
    public static func testStackSegment()
        {
        struct Local
            {
            let offset: Int
            }
            
        var arguments = Words()
        for index in 0..<23
            {
            arguments.append(Word(index))
            }
        var locals = Array<Local>()
        var offset = StackSegment.kFirstTemporaryOffset
        for _ in 0..<8
            {
            locals.append(Local(offset: offset))
            offset -= 8
            }
        let returnAddress:Word = 210674577
        let stackSegment = StackSegment(memorySize: MemorySize(megabytes: 100),argonModule: ArgonModule())
        stackSegment.enterFrame(arguments: arguments, localCount: locals.count, currentFrameAddress: returnAddress)
        var index:Word = 0
        for local in locals
            {
            stackSegment.setLocalSlot(index,atOffset: local.offset)
            index += 1
            }
        stackSegment.display(indent: "",count: 50)
        offset = StackSegment.kFirstArgumentOffset
        for index in 0..<arguments.count
            {
            let value = stackSegment.argument(atOffset: offset)
            assert(value == index,"Argument[\(offset)] != \(index) but is \(value)")
            offset += 8
            }
        index = 0
        for local in locals
            {
            let value = stackSegment.localSlot(atOffset: local.offset)
            assert(value == index,"Local[\(local.offset)] != \(index) but is \(value)")
            index += 1
            }
        let address = stackSegment.exitFrame()
        assert(address == returnAddress,"Return address = \(address) and should == \(returnAddress)")
        }
        
    }

public class StaticSegment: Segment
    {
    public override var segmentType: SegmentType
        {
        .static
        }
    }
    
public class DataSegment: Segment
    {
    public override var segmentType: SegmentType
        {
        .data
        }
    }

public class ManagedSegment: Segment
    {
    public override var segmentType: SegmentType
        {
        .managed
        }
    }
