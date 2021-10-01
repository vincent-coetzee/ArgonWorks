//
//  InstructionBuffer.swift
//  InstructionBuffer
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public protocol InstructionBuffer
    {
    var count: Int { get }
    var instructions: Array<Instruction> { get }
    @discardableResult
    func append(line:Int,_ opcode:Instruction.Opcode,_ operand1:Instruction.Operand,_ operand2:Instruction.Operand,_ result:Instruction.Operand) -> Self
    @discardableResult
    func append(_ opcode:Instruction.Opcode,_ operand1:Instruction.Operand,_ operand2:Instruction.Operand,_ result:Instruction.Operand) -> Self
    func fromHere(_ marker:Instruction.LabelMarker) throws -> Argon.Integer
    func fromHere() -> Instruction.LabelMarker
    func toHere() -> Instruction.LabelMarker
    @discardableResult
    func toHere(_ marker:Instruction.LabelMarker) throws -> Argon.Integer
    func triggerFromHere() -> Instruction.LabelMarker
    func triggerToHere() -> Instruction.LabelMarker
    }
    
public class InstructionHoldingBuffer: Collection,InstructionBuffer
    {
    public static func samples(in vm: VirtualMachine) -> InstructionBuffer
        {
        let buffer = InstructionHoldingBuffer()
        .append(.MAKE,.absolute(vm.topModule.argonModule.array.memoryAddress),.integer(1024),.register(.R0))
        .append(.MOV,.register(.R1),.none,.register(.FP))
        .append(.LOAD,.integer(10),.none,.register(.R4))
        .append(.LOAD,.integer(20),.none,.register(.R5))
        .append(.IADD,.register(.R4),.register(.R5),.register(.R6))
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
        
    public var instructions: Array<Instruction> = []
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
        instruction.lineNumber = 0
        self.instructions.append(instruction)
        self.instructionIndex += 1
        return(self)
        }
        
    @discardableResult
    public func append(line:Int,_ opcode:Instruction.Opcode,_ operand1:Instruction.Operand = .none,_ operand2:Instruction.Operand = .none,_ result:Instruction.Operand = .none) -> Self
        {
        let instruction = Instruction(opcode,operand1: operand1,operand2: operand2,result: result,lineNumber: self.instructionIndex)
        instruction.lineNumber = line
        self.instructions.append(instruction)
        self.instructionIndex += 1
        return(self)
        }
        
    public subscript(_ index:Int) -> Instruction
        {
        return(self.instructions[index])
        }

    }
