//
//  T3ABuffer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public class T3ABuffer: NSObject,NSCoding,Collection
    {
    public var hasPendingLabel: Bool
        {
        self.pendingLabel.isNotNil
        }
        
    public var count: Int
        {
        return(self.instructions.count)
        }
        
    public var startIndex: Int
        {
        return(self.instructions.startIndex)
        }
        
    public var endIndex: Int
        {
        return(self.instructions.endIndex)
        }
        
    public var instructions = Array<T3AInstruction>()
    private var currentOffset = 0
    public var pendingLabel: T3ALabel?
    
    public override init()
        {
        super.init()
        }
        
    required public init(coder: NSCoder)
        {
//        print("START DECODE T3ABuffer")
        self.instructions = coder.decodeObject(forKey: "instructions") as! Array<T3AInstruction>
        self.currentOffset = coder.decodeInteger(forKey: "currentOffset")
        self.pendingLabel = nil
        super.init()
//        print("END DECODE T3ABuffer")
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.instructions,forKey: "instructions")
        coder.encode(self.currentOffset,forKey: "currentOffset")
        }
        
    public func nextTemporary() -> T3AInstruction.Operand
        {
        T3AInstruction.nextTemporary()
        }
        
    public func index(after index:Int) -> Int
        {
        return(index + 1)
        }
        
    public subscript(_ index:Int) -> T3AInstruction
        {
        return(self.instructions[index])
        }
        
    public func nextLabel() -> T3ALabel
        {
        T3ALabel()
        }
        
    public func append(comment: String)
        {
        let instruction = T3AInstruction(comment: comment)
        instruction.offset = currentOffset
        self.currentOffset += 1
        self.instructions.append(instruction)
        }
        
    public func append(lineNumber: Int)
        {
        guard self.currentOffset > 0 && !self.instructions[self.currentOffset - 1].operand1.isInteger(lineNumber) else
            {
            return
            }
        self.append(nil,"LINE",.literal(.integer(Argon.Integer(lineNumber))),.none,.none)
        }
        
    public func append(_ opcode: String,_ operand1: T3AInstruction.Operand = .none,_ operand2: T3AInstruction.Operand = .none,_ result: T3AInstruction.Operand = .none)
        {
        self.append(nil,opcode,operand1,operand2,result)
        }
        
    public func append(_ label: T3ALabel? = nil,_ opcode: String,_ operand1: T3AInstruction.Operand,_ operand2: T3AInstruction.Operand,_ result: T3AInstruction.Operand)
        {
        if opcode != "LINE" && opcode != "CMT"
            {
            if self.pendingLabel.isNotNil && label.isNotNil
                {
                fatalError("Clash of the labels - pending label is not nil and so is incoming label")
                }
            else if label.isNotNil
                {
                self.pendingLabel = label
                }
            }
        var instruction: T3AInstruction
        if opcode == "LINE" || opcode == "CMT"
            {
            instruction = T3AInstruction(nil,opcode,operand1,operand2,result)
            }
        else
            {
            instruction = T3AInstruction(self.pendingLabel,opcode,operand1,operand2,result)
            }
        instruction.offset = currentOffset
        self.currentOffset += 1
        self.instructions.append(instruction)
        if opcode != "LINE" && opcode != "CMT"
            {
            self.pendingLabel = nil
            }
        }
        
    public func appendEntry(temporaryCount: Int)
        {
        self.append("PUSH",.framePointer,.none,.none)
        self.append("MOV",.stackPointer,.none,.framePointer)
        self.append("SUB",.stackPointer,.literal(.integer(Argon.Integer(8*temporaryCount))),.stackPointer)
        }
        
    public func appendExit()
        {
        self.append("MOV",.framePointer,.stackPointer,.none)
        self.append("POP",.framePointer,.none,.none)
        }
    }
