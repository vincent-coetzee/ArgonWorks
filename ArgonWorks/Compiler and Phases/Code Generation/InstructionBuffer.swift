//
//  InstructionBuffer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/2/22.
//

import Foundation

public class InstructionBuffer
    {
    public struct Label:Hashable
        {
        internal let index: Int
        
        public var operand: Instruction.Operand
            {
            .label(index)
            }
        }
        
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
        
    public var nextLabel:Label
        {
        let index = self.nextLabelIndex
        self.nextLabelIndex += 1
        return(Label(index: index))
        }
        
    private var nextLabelIndex: Int = 1
    private var nextTemporaryIndex: Int = 1
    public private(set) var instructions = Array<Instruction>()
    public var pendingLabel: Label?
    private var indexedInstructions = Dictionary<Int,Instruction>()
    private var nextIndex = 0
        
    @discardableResult
    public func add(_ mode: Instruction.Mode = .i64,_ opcode: Instruction.Opcode,_ op1: Instruction.Operand = .none,_ op2: Instruction.Operand = .none,_ op3: Instruction.Operand = .none,tail: String? = nil) -> Instruction
        {
        let instruction = Instruction(mode,opcode,op1,op2,op3)
        instruction.tail = tail
        if self.pendingLabel.isNotNil
            {
            self.indexedInstructions[self.pendingLabel!.index] = instruction
            self.pendingLabel = nil
            }
        self.addInstruction(instruction)
        return(instruction)
        }
        
    @discardableResult
    public func add(_ opcode: Instruction.Opcode,_ op1: Instruction.Operand = .none,_ op2: Instruction.Operand = .none,_ op3: Instruction.Operand = .none,tail: String? = nil) -> Instruction
        {
        let instruction = Instruction(.none,opcode,op1,op2,op3)
        instruction.tail = tail
        if self.pendingLabel.isNotNil
            {
            self.indexedInstructions[self.pendingLabel!.index] = instruction
            self.pendingLabel = nil
            }
        self.addInstruction(instruction)
        return(instruction)
        }
        
    @discardableResult
    public func add(_ label: Label,_ opcode: Instruction.Opcode,_ op1: Instruction.Operand = .none,_ op2: Instruction.Operand = .none,_ op3: Instruction.Operand = .none,tail: String? = nil) -> Instruction
        {
        let instruction = Instruction(.none,opcode,op1,op2,op3)
        instruction.tail = tail
        instruction.label = label
        self.indexedInstructions[label.index] = instruction
        self.addInstruction(instruction)
        return(instruction)
        }
        
    public func add(lineNumber: Int)
        {
        if lineNumber == 0
            {
//            print("halt")
            }
        self.addInstruction(Instruction(.i64,.LINE,.integer(Argon.Integer(lineNumber)),.none,.none))
        }
        
    public func flattenLabels(atAddress: Address)
        {
        self.instructions[0].addressLabel = atAddress
        for instruction in self.instructions
            {
            if instruction.hasLabelOperand
                {
                let targetIndex = instruction.labelOperandIndex
                let targetInstruction = indexedInstructions[targetIndex]!
                let instructionIndex = targetInstruction.index
                let address = atAddress + Word(instructionIndex * MemoryLayout<Word>.size)
                instruction.replaceLabel(withAddress: address)
                targetInstruction.addressLabel = address
                }
            }
        }
        
    private func addInstruction(_ instruction: Instruction)
        {
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
