//
//  T3AInstruction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public class T3AInstruction: NSObject,NSCoding
    {
    public static let sizeInBytes: Int = 6 * Argon.kWordSizeInBytesInt
    
    private static var nextTemp = 1
    
    public static func nextTemporary() -> Operand
        {
        let index = Self.nextTemp
        T3AInstruction.nextTemp += 1
        return(.temporary(index))
        }

    public enum RelocatableValue
        {
        public var displayString: String
            {
            switch(self)
                {
                case .self:
                    return("self")
                case .Self:
                    return("Self")
                case .super:
                    return("super")
                case .slot(let slot):
                    return(slot.label)
                case .function(let slot):
                    return(slot.invocationLabel)
//                case .method(let slot):
//                    return(slot.label)
                case .module(let slot):
                    return(slot.fullName.displayString)
                case .class(let slot):
                    return(slot.fullName.displayString)
                case .enumeration(let slot):
                    return(slot.label)
                case .enumerationCase(let slot):
                    return(slot.label)
                case .constant(let slot):
                    return(slot.label)
                case .segmentDS:
                    return("DS")
                case .relocatableIndex(let slot):
                    return("\(slot)")
                case .methodInstance(let slot):
                    return(slot.invocationLabel)
                case .string(let string):
                    return(string.string)
                case .context(let method,let ip):
                    return("\(method.invocationLabel):\(ip)")
                case .type(let slot):
                    return("Type(\(slot.label))")
                case .closure(let buffer):
                    let count = buffer.count
                    return("Closure(\(count) instructions)")
                case .address(let address):
                    return("\(String(format:"%010X",address))")
                }
            }
            
        public var symbol: Symbol?
            {
            switch(self)
                {
                case .slot(let symbol):
                    return(symbol)
                case .function(let symbol):
                    return(symbol)
//                case .method(let symbol):
//                    return(symbol)
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
//        case method(Method)
        case module(Module)
        case `class`(Class)
        case enumeration(Enumeration)
        case enumerationCase(EnumerationCase)
        case constant(Constant)
        case segmentDS
        case relocatableIndex(Int)
        case methodInstance(MethodInstance)
        case closure(T3ABuffer)
        case context(MethodInstance,Int)
        case string(StaticString)
        case type(Type)
        case address(Address)
        }

    public indirect enum Operand
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
                    return("RR")
                case .temporary(let integer):
                    return("TEMP_\(integer)")
                case .label(let label):
                    return(label.displayString)
                case .relocatable(let relocatable):
                    return(relocatable.displayString)
                case .literal(let literal):
                    return("\(literal)")
                case .framePointer:
                    return("FRAME")
                case .managedPointer:
                    return("MANAGED")
                case .stackPointer:
                    return("STACK")
                case .dataPointer:
                    return("DATA")
                case .staticPointer:
                    return("STATIC")
                case .indirect(let base,let offset):
                    let string = offset == 0 ? "" : (offset > 0 ? "+\(offset)" : "\(offset)")
                    return("[\(base.displayString)\(string)]")
                }
            }
            
        case none
        case indirect(Operand,Int)
        case returnRegister
        case framePointer
        case stackPointer
        case dataPointer
        case staticPointer
        case managedPointer
        case temporary(Int)
        case label(T3ALabel)
        case relocatable(RelocatableValue)
        case literal(Literal)
        
        public func isInteger(_ integer:Int) -> Bool
            {
            switch(self)
                {
                case .literal(let literal):
                    switch(literal)
                        {
                        case .integer(let anInt):
                            return(Int(anInt) == integer)
                        default:
                            break
                        }
                default:
                    break
                }
            return(false)
            }
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
        let labelString = self.label.isNil ? "       " : (self.label!.displayString + ":")
        var columns:Array<String> = []
        if self.operand1.isNotNone
            {
            columns.append(self.operand1.displayString)
            }
        if self.operand2.isNotNone
            {
            columns.append(self.operand2.displayString)
            }
        if self.result.isNotNone
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
        self.operand1 = .literal(.string(StaticString(string: comment)))
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
