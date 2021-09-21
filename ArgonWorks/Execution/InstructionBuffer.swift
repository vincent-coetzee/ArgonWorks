//
//  InstructionBuffer.swift
//  InstructionBuffer
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class InstructionBuffer: Collection
    {
    public static func samples(in vm: VirtualMachine) -> InstructionBuffer
        {
        let buffer = InstructionBuffer()
        .append(.MAKE,.absolute(vm.topModule.argonModule.array.memoryAddress),.integer(1024),.register(.R0))
        .append(.MOV,.register(.r1),.none,.register(.FP))
        .append(.LOAD,.integer(10),.none,.register(.r4))
        .append(.LOAD,.integer(20),.none,.register(.r5))
        .append(.IADD,.register(.r4),.register(.r5),.register(.R6))
        .append(.PUSH,.register(.R6))
        .append(.POP,.none,.none,.register(.R7))
        return(buffer)
        }


    public var startIndex: Int
        {
        return(self.instructions.startIndex)
        }
        
    public var endIndex: Int
        {
        return(self.instructions.endIndex)
        }
        
    private var instructions: Array<Instruction> = []
    private var instructionIndex: Int = 0
    
    init?(coder: NSCoder)
        {
        self.instructions = coder.decodeObject(forKey: "instructions") as! Array<Instruction>
        self.instructionIndex = 0
        }
        
    init()
        {
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.instructions,forKey: "instructions")
        }
        
    public func triggerFromHere() -> Instruction.LabelMarker
        {
        return(Instruction.LabelMarker(from: self.instructions[self.instructionIndex - 1], useTrigger: true))
        }
        
    public func triggerToHere() -> Instruction.LabelMarker
        {
        return(Instruction.LabelMarker(to: self.instructions[self.instructionIndex - 1], useTrigger: true))
        }
        
    public func toHere() -> Instruction.LabelMarker
        {
        return(Instruction.LabelMarker(to: self.instructions[self.instructionIndex - 1], useTrigger: true))
        }
        
    public func fromHere() -> Instruction.LabelMarker
        {
        return(Instruction.LabelMarker(from: self.instructions[self.instructionIndex - 1], useTrigger: false))
        }
        
    @discardableResult
    public func fromHere(_ marker:Instruction.LabelMarker) throws -> Argon.Integer
        {
        return(try marker.trigger(origin: .from(self.instructionIndex - 1)))
        }
        
    @discardableResult
    public func toHere(_ marker:Instruction.LabelMarker) throws -> Argon.Integer
        {
        return(try marker.trigger(origin: .to(self.instructionIndex - 1)))
        }
        
    public func index(after:Int) -> Int
        {
        return(after + 1)
        }
        
    @discardableResult
    public func append(_ opcode:Instruction.Opcode,_ operand1:Instruction.Operand = .none,_ operand2:Instruction.Operand = .none,_ result:Instruction.Operand = .none) -> Self
        {
        let instruction = Instruction(opcode,operand1: operand1,operand2: operand2,result: result,lineNumber: self.instructionIndex)
        self.instructions.append(instruction)
        self.instructionIndex += 1
        return(self)
        }
        
    public subscript(_ index:Int) -> Instruction
        {
        return(self.instructions[index])
        }

    }
