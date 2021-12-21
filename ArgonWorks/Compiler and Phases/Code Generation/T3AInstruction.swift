//
//  T3AInstruction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public class T3AInstruction: NSObject,NSCoding
    {
    public static let sizeInBytes: Int = 12 * Argon.kWordSizeInBytesInt
    
    public let sizeInWords: Int = 12
    
    private static var nextTemp = 1
    
    public static func nextTemporary() -> Operand
        {
        let index = Self.nextTemp
        T3AInstruction.nextTemp += 1
        return(.temporary(index))
        }
        
    public indirect enum Operand
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
                case .returnValue:
                    return("RV")
                case .temporary(let integer):
                    return("TEMP_\(integer)")
                case .label(let label):
                    return(label.displayString)
                case .address(let address):
                    return("ADDRESS(\(address))")
                case .frameOffset(let offset):
                    return("FRAME(\(offset))")
                case .integer(let integer):
                    return("INT(\(integer))")
                case .float(let float):
                    return("FLOAT(\(float))")
                }
            }
            
        public var rawValue: Int
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .returnValue:
                    return(1)
                case .temporary:
                    return(2)
                case .label:
                    return(3)
                case .address:
                    return(4)
                case .integer:
                    return(5)
                case .float:
                    return(6)
                case .frameOffset:
                    return(7)
                }
            }
            
        case none
        case returnValue
        case temporary(Int)
        case label(T3ALabel)
        case address(Address)
        case frameOffset(Int)
        case integer(Argon.Integer)
        case float(Argon.Float)
        
        public func isInteger(_ integer:Int) -> Bool
            {
            switch(self)
                {
                case .integer:
                    return(true)
                default:
                    return(false)
                }
            }
            
        public func install(intoPointer: WordPointer,context: ExecutionContext)
            {
            var pointer = intoPointer
            switch(self)
                {
                case .none:
                    pointer.pointee = Word(integer: self.rawValue)
                case .returnValue:
                    pointer.pointee = Word(integer: self.rawValue)
                case .integer(let integer):
                    pointer.pointee = Word(integer: self.rawValue)
                    pointer += 1
                    pointer.pointee = Word(integer: integer)
                    pointer += 1
                case .address(let address):
                    pointer.pointee = Word(integer: self.rawValue)
                    pointer += 1
                    pointer.pointee = address
                    pointer += 1
                case .temporary(let index):
                    pointer.pointee = Word(integer: self.rawValue)
                    pointer += 1
                    pointer.pointee = Word(integer: index)
                case .label(let label):
                    pointer.pointee = Word(integer: self.rawValue)
                    pointer += 1
                    pointer.pointee = Word(integer: label.index)
                    pointer += 1
                case .frameOffset(let integer):
                    pointer.pointee = Word(integer: self.rawValue)
                    pointer += 1
                    pointer.pointee = Word(integer: integer)
                    pointer += 1
                case .float(let float):
                    pointer.pointee = Word(integer: self.rawValue)
                    pointer += 1
                    pointer.pointee = Word(float: float)
                    pointer += 1
                }
            }
        }
        
    public var displayString: String
        {
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
        
    public var comment: String?
    public var offset: Int = 0
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
//        print("START DECODE T3AInstruction")
        self.offset = coder.decodeInteger(forKey: "offset")
        self.comment = coder.decodeObject(forKey: "comment") as? String
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
        coder.encode(self.comment,forKey: "comment")
        coder.encode(self.offset,forKey: "offset")
        coder.encode(self.label,forKey: "label")
        coder.encode(self.opcode,forKey: "opcode")
        coder.encodeOperand(self.operand1,forKey: "operand1")
        coder.encodeOperand(self.operand2,forKey: "operand2")
        coder.encodeOperand(self.result,forKey: "result")
        }
        
    public var sizeInBytes: Int
        {
        12 * Argon.kWordSizeInBytesInt
        }
        
    public func install(intoPointer aPointer: WordPointer,context: ExecutionContext)
        {
        var pointer = aPointer
        pointer.pointee = Word(integer: self.offset)
        pointer += 1
        pointer.pointee = Word(integer: self.label?.index ?? 0)
        pointer += 1
        pointer.pointee = context.symbolTable.registerSymbol("#" + self.opcode)
        pointer += 1
        self.operand1.install(intoPointer: pointer,context: context)
        pointer += 3
        self.operand2.install(intoPointer: pointer,context: context)
        pointer += 3
        self.result.install(intoPointer: pointer,context: context)
        }
    }

public typealias T3AInstructions = Array<T3AInstruction>
