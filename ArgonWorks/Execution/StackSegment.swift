//
//  StackSegment.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

///
///
/// ARGON METHOD CALLING CONVENTION
///
/// --------------------
/// | ARGUMENT N       |
/// --------------------
/// | ARGUMENT N - 1   |
/// --------------------
///        \
///        \
/// --------------------
/// | ARGUMENT 1       | ARGUMENT 1 = [BP + 32]
/// --------------------
/// | ARGUMENT 0       | ARGUMENT 0 = [BP + 24]
/// --------------------
/// | CONTEXT ADDRESS  |
/// --------------------
/// | RETURN IP        |
/// --------------------
/// | OLD FRAME PTR=BP | <----- BP
/// --------------------
/// | LOCAL COUNT      |
/// --------------------
/// | LOCAL 0          | LOCAL 0 = [BP -  16]
/// --------------------
/// | LOCAL 1          | LOCAL 1 = [BP - 24]
/// --------------------
///         \
///         \
/// --------------------
/// | LOCAL N - 1      |
/// --------------------
/// | LOCAL N          | <----- SP
/// --------------------
///
///
public class StackSegment: Segment
    {
    public override class var segmentType: SegmentType
        {
        .stack
        }
        
    public static let kFirstTemporaryOffset = -2 * Argon.kWordSizeInBytesInt
    public static let kFirstArgumentOffset = 3 * Argon.kWordSizeInBytesInt
    
    internal private(set) var stackPointer: Word = 0
    internal private(set) var framePointer: Word = 0

    public override init(memorySize: MemorySize,argonModule: ArgonModule) throws
        {
        try super.init(memorySize: memorySize,argonModule: argonModule)
        self.stackPointer = self.lastAddress
        self.framePointer = self.stackPointer
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
//        struct Local
//            {
//            let offset: Int
//            }
//            
//        var arguments = Words()
//        for index in 0..<23
//            {
//            arguments.append(Word(index))
//            }
//        var locals = Array<Local>()
//        var offset = StackSegment.kFirstTemporaryOffset
//        for _ in 0..<8
//            {
//            locals.append(Local(offset: offset))
//            offset -= 8
//            }
//        let returnAddress:Word = 210674577
//        let stackSegment = StackSegment(memorySize: MemorySize(megabytes: 100),argonModule: ArgonModule())
//        stackSegment.enterFrame(arguments: arguments, localCount: locals.count, currentFrameAddress: returnAddress)
//        var index:Word = 0
//        for local in locals
//            {
//            stackSegment.setLocalSlot(index,atOffset: local.offset)
//            index += 1
//            }
//        stackSegment.display(indent: "",count: 50)
//        offset = StackSegment.kFirstArgumentOffset
//        for index in 0..<arguments.count
//            {
//            let value = stackSegment.argument(atOffset: offset)
//            assert(value == index,"Argument[\(offset)] != \(index) but is \(value)")
//            offset += 8
//            }
//        index = 0
//        for local in locals
//            {
//            let value = stackSegment.localSlot(atOffset: local.offset)
//            assert(value == index,"Local[\(local.offset)] != \(index) but is \(value)")
//            index += 1
//            }
//        let address = stackSegment.exitFrame()
//        assert(address == returnAddress,"Return address = \(address) and should == \(returnAddress)")
        }
        
    }
