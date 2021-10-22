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
        
    public enum LiteralValue
        {
        case `nil`
        case string(String)
        case symbol(String)
        case integer(Argon.Integer)
        case float(Argon.Float)
        case boolean(Argon.Boolean)
        case character(Argon.Character)
        case byte(Argon.Byte)
        case array([LiteralValue])
        }

    public enum RelocatableValue
        {
        public var symbol: Symbol?
            {
            switch(self)
                {
                case .slot(let symbol):
                    return(symbol)
                case .function(let symbol):
                    return(symbol)
                case .method(let symbol):
                    return(symbol)
                case .methodInstance(let symbol):
                    return(symbol)
                case .module(let symbol):
                    return(symbol)
                case .class(let symbol):
                    return(symbol)
                case .enumeration(let symbol):
                    return(symbol)
                case .enumerationCase(let symbol):
                    return(symbol)
                case .constant(let symbol):
                    return(symbol)
                default:
                    return(nil)
                }
            }
            
        case `self`
        case `Self`
        case `super`
        case slot(Slot)
        case function(Function)
        case method(Method)
        case module(Module)
        case `class`(Class)
        case enumeration(Enumeration)
        case enumerationCase(EnumerationCase)
        case constant(Constant)
        case segmentDS
        case relocatableIndex(Int)
        case methodInstance(MethodInstance)
        }

    public enum Operand
        {
        public var relocatableValue: RelocatableValue
            {
            switch(self)
                {
                case .relocatable(let value):
                    return(value)
                default:
                    fatalError("This should not be asked of this value.")
                }
            }
            
        public var isRelocatable: Bool
            {
            switch(self)
                {
                case .relocatable:
                    return(true)
                default:
                    return(false)
                }
            }
            
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
                case .temporary(let integer):
                    return("TEMP_\(integer)")
                case .label(let label):
                    return(label.displayString)
                case .relocatable(let relocatable):
                    return("\(relocatable)")
                case .literal(let literal):
                    return("\(literal)")
                }
            }
            
        case none
        case returnRegister
        case temporary(Int)
        case label(T3ALabel)
        case relocatable(RelocatableValue)
        case literal(LiteralValue)
        }
        
    public var displayString: String
        {
        if self.opcode == "CMT"
            {
            switch(self.operand1)
                {
                case .literal(let literal):
                    switch(literal)
                        {
                        case .string(let string):
                            return(";;  \(string)")
                        default:
                            return("")
                        }
                default:
                    return("")
                }
            }
        if self.opcode == "LINE"
            {
            switch(self.operand1)
                {
                case .literal(let literal):
                    switch(literal)
                        {
                        case .integer(let integer):
                            return(";;  LINE \(integer)")
                        default:
                            return("")
                        }
                default:
                    return("")
                }
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
        
    public var offset: Int = 0
    public var label: T3ALabel?
    public let opcode: String
    public var operand1: Operand = .none
    public var operand2: Operand = .none
    public var result: Operand = .none
    
    init(lineNumber: Int)
        {
        self.opcode = "LINE"
        self.operand1 = .literal(.integer(Argon.Integer(lineNumber)))
        }
        
    init(comment: String)
        {
        self.opcode = "COMMENT"
        self.operand1 = .literal(.string(comment))
        }
        
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
//        print("START DECODE T3AInstruction")
        self.offset = coder.decodeInteger(forKey: "offset")
        self.label = coder.decodeObject(forKey: "label") as? T3ALabel
        self.opcode = coder.decodeObject(forKey: "opcode") as! String
        self.operand1 = coder.decodeOperand(forKey: "operand1")
        self.operand2 = coder.decodeOperand(forKey: "operand2")
        self.result = coder.decodeOperand(forKey: "result")
//        print("END DECODE T3AInstruction")
        }
        
    public func copy() -> Self
        {
        return(T3AInstruction(self.label,self.opcode,self.operand1,self.operand2,self.result) as! Self)
        }
        
    public func encode(with coder: NSCoder)
        {
//        print("ENCODE \(Swift.type(of: self)) OFFSET \(offset)")
        coder.encode(self.offset,forKey: "offset")
        coder.encode(self.label,forKey: "label")
        coder.encode(self.opcode,forKey: "opcode")
        coder.encodeOperand(self.operand1,forKey: "operand1")
        coder.encodeOperand(self.operand2,forKey: "operand2")
        coder.encodeOperand(self.result,forKey: "result")
        }
    }

public typealias T3AInstructions = Array<T3AInstruction>
