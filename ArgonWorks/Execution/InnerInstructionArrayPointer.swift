//
//  InnerInstructionPointer.swift
//  InnerInstructionPointer
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

//public class InnerInstructionArrayPointer:InnerArrayPointer
//    {
//    public static let samples = InnerInstructionArrayPointer.allocate(arraySize: 10*10, in: VirtualMachine.shared.managedSegment)
//        .append(.MAKE,operand1: .absolute(ArgonModule.argonModule.array.memoryAddress),operand2: .integer(1024),result: .register(.r0))
//        .append(.mov,operand1:.register(.r1),result: .register(.fp))
//        .append(.load,operand1:.integer(10),result:.register(.r4))
//        .append(.load,operand1: .integer(20), result:.register(.r5))
//        .append(.IADD,operand1: .register(.r4),operand2:.register(.r5),result: .register(.r6))
//        .append(.push,operand1: .register(.r6))
//        .append(.pop,result: .register(.r7))
//        
//    public struct InstructionLabel
//        {
//        let label:String
//        let index:Int
//        }
//        
//    typealias Element = Instruction
//    
//    public override class func allocate(arraySize:Int,in segment: Segment)  -> InnerInstructionArrayPointer
//        {
//        let pointer = super.allocate(arraySize: arraySize, in: segment)
//        let wrapper = InnerInstructionArrayPointer(address: pointer.address)
//        wrapper.headerTypeCode = .instructionArray
//        return(wrapper)
//        }
//        
//    public var allInstructions: Array<Instruction>
//        {
//        var array = Array<Instruction>()
//        self.rewind()
//        while self.instruction.isNotNil
//            {
//            array.append(self.instruction!)
//            self.next()
//            }
//        return(array)
//        }
//        
//    public func encode<T>(value: T, inWidth width: Int) where T : RawConvertible
//        {
//        print("halt")
//        }
//        
//    public override var startIndex: Int
//        {
//        0
//        }
//        
//    public override var endIndex: Int
//        {
//        self.count - 1
//        }
//        
//    public var instructionsPointer: Word
//        {
//        Word(bitPattern: Int(bitPattern: self.bytePointer))
//        }
//        
//    private var offset = 0
//    private var bytePointer:UnsafeMutableRawPointer
//    private var currentIndex = 0
//    
//    required init(address:Word)
//        {
//        self.bytePointer = UnsafeMutableRawPointer(bitPattern: UInt(address + Word(Self.kArraySizeInBytes)))!
//        super.init(address: address)
//        }
//        
//    @discardableResult
//    public func append(_ opcode:Instruction.Opcode,operand1:Instruction.Operand = .none,operand2:Instruction.Operand = .none,result:Instruction.Operand = .none) -> Self
//        {
//        let instruction = Instruction(opcode,operand1:operand1,operand2:operand2,result:result)
//        self.append(instruction)
//        return(self)
//        }
//        
//    @discardableResult
//    public func append(_ instruction:Instruction) -> Self
//        {
//        let encoder = BinaryEncoder()
//        let output = try! encoder.encode(instruction)
//        let array = InnerByteArrayPointer.with(output)
//        self[self.count] = array.address
//        self[self.count+1] = 0
//        self.count += 1
//        self.currentIndex += 1
//        return(self)
//        }
//        
//    public func instruction(at index:Int) -> Instruction
//        {
//        if index < 0 || index >= count
//            {
//            fatalError("BAD INDEX TO INSTRUCTIONS")
//            }
//        let bytes = InnerByteArrayPointer(address: self[index]).bytes
//        let decoder = BinaryDecoder()
//        let instruction = try! decoder.decode(Instruction.self, from: bytes)
//        return(instruction)
//        }
//        
//    @discardableResult
//    public func append(_ instructions:Array<Instruction>) -> Self
//        {
//        for instruction in instructions
//            {
//            self.append(instruction)
//            }
//        return(self)
//        }
//        
//    public func fromHere(_ with:String) -> InnerInstructionArrayPointer.InstructionLabel
//        {
//        return(InstructionLabel(label: with,index: self.currentIndex))
//        }
//        
//    public func toHere(_ from: InnerInstructionArrayPointer.InstructionLabel) -> Argon.Integer
//        {
//        return(Argon.Integer(from.index - self.currentIndex))
//        }
//        
//    public var instruction: Instruction?
//        {
//        if self.currentIndex < 0 || self.currentIndex >= self.count
//            {
//            return(nil)
//            }
//        let bytes = InnerByteArrayPointer(address: self[self.currentIndex]).bytes
//        let decoder = BinaryDecoder()
//        let instruction = try? decoder.decode(Instruction.self, from: bytes)
//        return(instruction)
//        }
//        
//    public var currentInstructionId: Int
//        {
//        return(self.instruction(at: self.currentIndex).id)
//        }
//        
//    public func singleStep(in context:ExecutionContext) throws
//        {
//        if self.currentIndex >= self.count
//            {
//            return
//            }
//        try self.instruction(at: self.currentIndex).execute(in: context)
//        self.currentIndex += 1
//        }
//        
//    @discardableResult
//    public func rewind() -> Self
//        {
//        self.currentIndex = 0
//        return(self)
//        }
//        
//    public func next()
//        {
//        self.currentIndex += 1
//        }
//    }
