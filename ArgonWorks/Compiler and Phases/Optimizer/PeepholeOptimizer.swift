//
//  PeepholeOptimizer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/2/22.
//

import Foundation

public enum OperandKind
    {
    case anything
    case none
    case integer
    case address
    case label
    case float
    case byte
    case character
    case boolean
    case frameOffset
    case register
    case temporary
    }
    
fileprivate enum CapturedElement
    {
    case opcode(String,Instruction.Opcode)
    case operand(String,Int,Instruction.Operand)
    }
    
fileprivate class InstructionElement
    {
    public let mustCapture: Bool
    public let mustMatch: Bool
    public let key: String
    public var capturedElement: CapturedElement?
    
    init(mustCapture: Bool = false,mustMatch: Bool = false,key: String)
        {
        self.mustCapture = mustCapture
        self.mustMatch = mustMatch
        self.key = key
        }
        
    public func match(instruction: Instruction) -> Bool
        {
        if self.mustCapture && !self.mustMatch
            {
            return(self.capture(instruction: instruction))
            }
        else if self.mustMatch && !self.mustCapture
            {
            return(self.internalMatch(instruction: instruction))
            }
        else
            {
            self.capture(instruction: instruction)
            return(self.internalMatch(instruction: instruction))
            }
        }
        
    @discardableResult
    public func capture(instruction: Instruction) -> Bool
        {
        return(true)
        }
        
    public func internalMatch(instruction: Instruction) -> Bool
        {
        return(false)
        }
    }
    
fileprivate class InstructionElementOpcode: InstructionElement
    {
    private let opcode: Instruction.Opcode
    
    init(mustCapture: Bool = false,mustMatch: Bool = false,key: String,opcode: Instruction.Opcode)
        {
        self.opcode = opcode
        super.init(mustCapture: mustCapture,mustMatch: mustMatch,key: key)
        }
        
    @discardableResult
    public override func capture(instruction: Instruction) -> Bool
        {
        self.capturedElement = .opcode(self.key,instruction.opcode)
        return(true)
        }
        
    public override func internalMatch(instruction: Instruction) -> Bool
        {
        return(self.opcode == instruction.opcode)
        }
    }
    
fileprivate class InstructionElementOperand: InstructionElement
    {
    private func operandAtIndex(instruction: Instruction) -> Instruction.Operand
        {
        if self.operandIndex == 1
            {
            return(instruction.operand1)
            }
        else if self.operandIndex == 2
            {
            return(instruction.operand2)
            }
        else
            {
            return(instruction.operand3)
            }
        }
        
    private let operandKind: OperandKind
    private let operandIndex: Int
    
    init(mustCapture: Bool = false,mustMatch: Bool = false,key: String,operandIndex: Int,operandKind: OperandKind)
        {
        self.operandKind = operandKind
        self.operandIndex = operandIndex
        super.init(mustCapture: mustCapture,mustMatch: mustMatch,key: key)
        }
        
    @discardableResult
    public override func capture(instruction: Instruction) -> Bool
        {
        let operand = self.operandAtIndex(instruction: instruction)
        self.capturedElement = .operand(self.key,self.operandIndex,operand)
        return(true)
        }
        
    public override func internalMatch(instruction: Instruction) -> Bool
        {
        let operand = self.operandAtIndex(instruction: instruction)
        return(operand == self.operandKind)
        }
    }
    
fileprivate struct InstructionLine
    {
    public let opcode: InstructionElementOpcode
    public let operand1: InstructionElementOperand
    public let operand2: InstructionElementOperand
    public let operand3: InstructionElementOperand
    
    init(opcode: InstructionElementOpcode,operand1: InstructionElementOperand,operand2: InstructionElementOperand,operand3: InstructionElementOperand)
        {
        self.opcode = opcode
        self.operand1 = operand1
        self.operand2 = operand2
        self.operand3 = operand3
        }
        
    public func match(instruction: Instruction) -> Bool
        {
        return(self.opcode.match(instruction: instruction) && self.operand1.match(instruction: instruction) && self.operand2.match(instruction: instruction) && self.operand3.match(instruction: instruction))
        }
    }
    
public class PeepholeOptimizer
    {
    public func optimize(instructionBuffer: InstructionBuffer) -> InstructionBuffer
        {
        return(instructionBuffer)
        }
    }
