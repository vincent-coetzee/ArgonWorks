//
//  T3ABuffer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public class T3ABuffer: NSObject,NSCoding,Collection
    {
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
        self.append(nil,"LINE",.literal(.integer(Argon.Integer(lineNumber))),.none,.none)
        }
        
    public func append(_ opcode: String,_ operand1: T3AInstruction.Operand,_ operand2: T3AInstruction.Operand,_ result: T3AInstruction.Operand)
        {
        self.append(nil,opcode,operand1,operand2,result)
        }
        
    public func append(_ label: T3ALabel? = nil,_ opcode: String,_ operand1: T3AInstruction.Operand,_ operand2: T3AInstruction.Operand,_ result: T3AInstruction.Operand)
        {
        if self.pendingLabel.isNotNil && label.isNotNil
            {
            fatalError("Clash of the labels - pending label is not nil and so is incoming label")
            }
        else if label.isNotNil
            {
            self.pendingLabel = label
            }
        let instruction = T3AInstruction(self.pendingLabel,opcode,operand1,operand2,result)
        instruction.offset = currentOffset
        self.currentOffset += 1
        self.instructions.append(instruction)
        self.pendingLabel = nil
        }
    }
