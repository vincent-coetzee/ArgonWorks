//
//  InstructionBuffer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/2/22.
//

import Foundation

public class InstructionBuffer
    {
    public var count: Int
        {
        self.instructions.count
        }
        
    public var nextTemporary: Instruction.Operand
        {
        let index = self.nextTemporaryIndex
        self.nextTemporaryIndex += 1
        return(.temporary(index))
        }
        
    public var nextLabel:Instruction.Operand
        {
        let index = self.nextLabelIndex
        self.nextLabelIndex += 1
        return(.label(index))
        }
        
    private var nextLabelIndex: Int = 1
    private var nextTemporaryIndex: Int = 1
    public private(set) var instructions = Array<Instruction>()
    public var pendingLabel: Instruction.Operand?
    private var labeledInstructions = Dictionary<Int,Instruction>()
    private var nextIndex = 0
        
    @discardableResult
    public func add(_ mode: Instruction.Mode = .i64,_ opcode: Instruction.Opcode,_ op1: Instruction.Operand = .none,_ op2: Instruction.Operand = .none,_ op3: Instruction.Operand = .none) -> Instruction
        {
        let instruction = Instruction(mode,opcode,op1,op2,op3)
        if self.pendingLabel.isNotNil
            {
            self.labeledInstructions[self.pendingLabel!.labelValue] = instruction
            self.pendingLabel = nil
            }
        self.addInstruction(instruction)
        return(instruction)
        }
        
    @discardableResult
    public func add(_ opcode: Instruction.Opcode,_ op1: Instruction.Operand = .none,_ op2: Instruction.Operand = .none,_ op3: Instruction.Operand = .none) -> Instruction
        {
        let instruction = Instruction(.none,opcode,op1,op2,op3)
        if self.pendingLabel.isNotNil
            {
            self.labeledInstructions[self.pendingLabel!.labelValue] = instruction
            self.pendingLabel = nil
            }
        self.addInstruction(instruction)
        return(instruction)
        }
        
    @discardableResult
    public func add(_ label: Instruction.Operand,_ opcode: Instruction.Opcode,_ op1: Instruction.Operand = .none,_ op2: Instruction.Operand = .none,_ op3: Instruction.Operand = .none) -> Instruction
        {
        let instruction = Instruction(.none,opcode,op1,op2,op3)
        instruction.label = label
        self.labeledInstructions[label.labelValue] = instruction
        self.addInstruction(instruction)
        return(instruction)
        }
        
    public func add(lineNumber: Int)
        {
        self.addInstruction(Instruction(.i64,.LINE,.integer(Argon.Integer(lineNumber)),.none,.none))
        }
        
    public func flattenLabels(atAddress: Address)
        {
        for instruction in self.instructions
            {
            if let index = instruction.labelValue
                {
                let offset = atAddress + Word(index * 4 * MemoryLayout<Word>.size)
                instruction.replaceLabel(withAddress: offset)
                }
            }
        }
        
    private func addInstruction(_ instruction: Instruction)
        {
        if instruction.opcode == .CALL && instruction.operand1.addressValue == 100000000000
            {
            print("halt")
            }
        instruction.index = self.nextIndex
        self.nextIndex += 1
        self.instructions.append(instruction)
        }
        
    public func display(indent: String)
        {
        print("\(indent)INSTRUCTION BUFFER")
        for instruction in self.instructions
            {
            let newIndent = indent + "\t"
            print("\(newIndent)\(instruction.displayString)")
            }
        }
    }
