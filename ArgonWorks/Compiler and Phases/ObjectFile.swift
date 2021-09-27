//
//  ObjectFile.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/9/21.
//

import Foundation

public typealias Instructions = Array<Instruction>

public class ObjectFile
    {
    public enum InstructionEntry
        {
        case method(UUID)
        case methodInstance(UUID)
        case instructions(Instructions)
        }
        
    private var entries: Array<InstructionEntry> = []
    private var literals: Array<Instruction.LiteralValue> = []
    
    public func addSymbol(_ symbol: Symbol)
        {
        
        }
        
    public func addMethod(_ method: Method)
        {
        self.entries.append(.method(method.index))
        for instance in method.instances
            {
            self.entries.append(.methodInstance(instance.index))
            let instructions = instance.buffer.instructions
            for instruction in instructions
                {
                if instruction.operand1.isRelocation,let relocationTarget = instruction.operand1.relocationTarget
                    {
                    literals.append(relocationTarget)
                    instruction.operand1 = .relocation(.relocation(literals.count - 1))
                    }
                if instruction.operand2.isRelocation,let relocationTarget = instruction.operand2.relocationTarget
                    {
                    literals.append(relocationTarget)
                    instruction.operand2 = .relocation(.relocation(literals.count - 1))
                    }
                if instruction.result.isRelocation,let relocationTarget = instruction.result.relocationTarget
                    {
                    literals.append(relocationTarget)
                    instruction.result = .relocation(.relocation(literals.count - 1))
                    }
                }
            self.entries.append(.instructions(instructions))
            }
        }
    }
