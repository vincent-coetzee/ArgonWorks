//
//  RawInstructionArray.swift
//  RawInstructionArray
//
//  Created by Vincent Coetzee on 6/8/21.
//

import Foundation

public typealias ImmutableWordPointer = UnsafePointer<Word>

extension ImmutableWordPointer
    {
    init?(address:Word)
        {
        self.init(bitPattern: UInt(address))
        }
    }
    
public class InnerPackedInstructionArrayPointer: InnerPointer,Collection
    {
    public typealias Element = Instruction
    public typealias Index = Int
    
    private static let kInstructionSizeInWords = 4
    
    public static func allocate(numberOfInstructions: Int,in segment: ManagedSegment) -> InnerPackedInstructionArrayPointer
        {
        let bytesPerInstruction = 32
        let extraBytes = InnerPointer.kArraySizeInBytes + 8 + 8
        let totalBytes = numberOfInstructions * bytesPerInstruction + extraBytes
        let address = segment.allocateObject(sizeInBytes: totalBytes)
        let pointer = InnerPackedInstructionArrayPointer(address: address)
        pointer.count = 0
        pointer.size = numberOfInstructions
        return(pointer)
        }
        
    public var startIndex: Int
        {
        0
        }
        
    public var endIndex: Int
        {
        return(self.count)
        }
        
    public var count: Int
        {
        get
            {
            var offset = self.instructionPointer
            offset -= 8
            return(Int(offset[0]))
            }
        set
            {
            var offset = self.instructionPointer
            offset -= 8
            offset[0] = Word(newValue)
            }
        }
        
    public var size: Int
        {
        get
            {
            var offset = self.instructionPointer
            offset -= 4
            return(Int(offset[0]))
            }
        set
            {
            var offset = self.instructionPointer
            offset -= 4
            offset[0] = Word(newValue)
            }
        }
        
    public var rawInstructionPointer: ImmutableWordPointer
        {
        return(ImmutableWordPointer(address: self.instructionPointer.address)!)
        }
        
    required init(address: Word)
        {
        self.instructionPointer = WordPointer(address: address + Word(InnerPointer.kArraySizeInBytes + 8 + 8))!
        super.init(address: address)
        }
        
    public var instructions: Array<Instruction>
        {
        var instructions = Array<Instruction>()
        for index in 0..<self.count
            {
            instructions.append(self[index])
            }
        return(instructions)
        }
        
    private var instructionPointer: WordPointer = WordPointer(address: 1)!
    private var instructionIndex = 0
        
    public func index(after:Int) -> Int
        {
        return(after + 1)
        }
        
    @discardableResult
    public func append(_ opcode:Instruction.Opcode,operand1:Instruction.Operand = .none,operand2:Instruction.Operand = .none,result:Instruction.Operand = .none) -> Self
        {
//        self.append(Instruction(opcode,operand1:operand1,operand2:operand2,result:result))
        return(self)
        }
        
//    public func fromHere(_ with:String) -> InnerInstructionArrayPointer.InstructionLabel
//        {
//        return(InnerInstructionArrayPointer.InstructionLabel(label: with,index: self.instructionIndex))
//        }
//        
//    public func toHere(_ from: InnerInstructionArrayPointer.InstructionLabel) -> Argon.Integer
//        {
//        return(Argon.Integer(from.index - self.instructionIndex))
//        }
//        
//    @discardableResult
    public func append(_ instruction:Instruction) -> Self
        {
        let offset = self.count * Self.kInstructionSizeInWords
        instruction.lineNumber = self.count
        instruction.write(to: self.instructionPointer + offset)
        self.count += 1
        self.instructionIndex += 1
        return(self)
        }
        
    public subscript(_ index:Int) -> Instruction
        {
        get
            {
            let offset = index * Self.kInstructionSizeInWords
            let pointer = self.instructionPointer + offset
            return(Instruction(from: pointer))
            }
        set
            {
            newValue.lineNumber = index
            let offset = index * Self.kInstructionSizeInWords
            let pointer = self.instructionPointer + offset
            newValue.write(to: pointer)
            }
        }
    
    @discardableResult
    public func rewind() -> Self
        {
        self.instructionIndex = 0
        return(self)
        }
    }
