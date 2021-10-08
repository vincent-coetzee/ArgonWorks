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
    }
