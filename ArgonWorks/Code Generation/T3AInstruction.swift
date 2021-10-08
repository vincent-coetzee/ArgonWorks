//
//  T3AInstruction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public class T3AInstruction: NSObject,NSCoding
    {
    private static var nextTemp = 1
    
    public static func nextTemporary() -> Operand
        {
        let index = Self.nextTemp
        T3AInstruction.nextTemp += 1
        return(.temporary(index))
        }
        
    public enum Operand: Equatable
        {
        public var isNone: Bool
            {
            switch(self)
                {
                case .none:
                    return(true)
                default:
                    return(false)
                }
            }
            
        public var isNotNone: Bool
            {
            switch(self)
                {
                case .none:
                    return(false)
                default:
                    return(true)
                }
            }
            
        public var displayString: String
            {
            switch(self)
                {
                case .none:
                    return("NONE")
                case .returnRegister:
                    return("RET")
                case .local(let slot):
                    return("LOCAL(\(slot.label))")
                case .temporary(let integer):
                    return("TEMP_\(integer)")
                case .label(let label):
                    return(label.displayString)
                case .integer(let integer):
                    return("\(integer)")
                case .float(let integer):
                    return("\(integer)")
                case .string(let integer):
                    return("\"\(integer)\"")
                case .literal(let literal):
                    return("\(literal)")
                case .boolean(let boolean):
                    return("\(boolean)")
                }
            }
            
        case none
        case returnRegister
        case temporary(Int)
        case local(Slot)
        case label(T3ALabel)
        case integer(Int)
        case float(Double)
        case string(String)
        case boolean(Bool)
        case literal(Instruction.LiteralValue)
        }
        
    public var displayString: String
        {
        if self.opcode == "MOVINDIRECT"
            {
            print("helt")
            }
        let labelString = self.label.isNil ? "       " : self.label!.displayString
        var columns:Array<String> = []
        if operand1.isNotNone
            {
            columns.append(self.operand1.displayString)
            }
        if operand2.isNotNone
            {
            columns.append(self.operand2.displayString)
            }
        if result.isNotNone
            {
            columns.append(self.result.displayString)
            }
        let string = columns.joined(separator: ",")
        return(labelString + self.opcode + " " + string)
        }
        
    public var offset: Int?
    public var label: T3ALabel?
    public let opcode: String
    public var operand1: Operand = .none
    public var operand2: Operand = .none
    public var result: Operand = .none
    
    init(_ label: T3ALabel? = nil,_ opcode: String,_ operand1: Operand,_ operand2: Operand,_ result: Operand)
        {
        self.label = label
        self.opcode = opcode
        self.operand1 = operand1
        self.operand2 = operand2
        self.result = result
        }
        
    required public init(coder: NSCoder)
        {
        self.offset = coder.decodeInteger(forKey: "offset")
        self.label = coder.decodeObject(forKey: "label") as? T3ALabel
        self.opcode = coder.decodeObject(forKey: "opcode") as! String
        self.operand1 = coder.decodeT3AOperand(forKey: "operand1")
        self.operand2 = coder.decodeT3AOperand(forKey: "operand2")
        self.result = coder.decodeT3AOperand(forKey: "result")
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.offset,forKey: "offset")
        coder.encode(self.label,forKey: "label")
        coder.encode(self.opcode,forKey: "opcode")
        coder.encode(self.operand1,forKey: "operand1")
        coder.encode(self.operand2,forKey: "operand2")
        coder.encode(self.result,forKey: "result")
        }
    }
