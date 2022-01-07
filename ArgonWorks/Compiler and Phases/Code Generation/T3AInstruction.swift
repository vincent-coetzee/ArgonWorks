//
//  T3AInstruction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public protocol BitPattern
    {
    var bits: Word { get }
    var shift: Word { get }
    }
    
public typealias Opcode = Word

extension Opcode
    {
    public static let Mode64: Word          = 0b00000000_10000000_00000000_00000000
    public static let Mode16: Word          = 0b00000000_01000000_00000000_00000000
    public static let Mode8: Word           = 0b00000000_00100000_00000000_00000000
    public static let ModeAbsolute: Word    = 0b00000000_00010000_00000000_00000000
    public static let ModeRelative: Word    = 0b00000000_00001000_00000000_00000000
    public static let ConditionTrue: Word   = 0b00000000_00000100_00000000_00000000
    public static let ConditionFalse: Word  = 0b00000000_00000010_00000000_00000000
    public static let ModeInteger: Word     = 0b00000000_00000001_00000000_00000000
    public static let ModeFloat: Word       = 0b00000001_00000001_00000000_00000000
    
    public static let NOP: Word = 0
    public static let IADD64: Word = 1  | Mode64 | ModeInteger
    public static let ISUB64: Word = 2  | Mode64 | ModeInteger
    public static let IMUL64: Word = 3  | Mode64 | ModeInteger
    public static let IDIV64: Word = 4  | Mode64 | ModeInteger
    public static let IMOD64: Word = 5  | Mode64 | ModeInteger
    public static let IADD16: Word = 1  | Mode16 | ModeInteger
    public static let ISUB16: Word = 2  | Mode16 | ModeInteger
    public static let IMUL16: Word = 3  | Mode16 | ModeInteger
    public static let IDIV16: Word = 4  | Mode16 | ModeInteger
    public static let IMOD16: Word = 5  | Mode16 | ModeInteger
    public static let IADD8: Word = 1   | Mode8  | ModeInteger
    public static let ISUB8: Word = 2   | Mode8  | ModeInteger
    public static let IMUL8: Word = 3   | Mode8  | ModeInteger
    public static let IDIV8: Word = 4   | Mode8  | ModeInteger
    public static let IMOD8: Word = 5   | Mode8  | ModeInteger
    public static let FADD64: Word = 1  | Mode64 | ModeFloat
    public static let FSUB64: Word = 2  | Mode64 | ModeFloat
    public static let FMUL64: Word = 3  | Mode64 | ModeFloat
    public static let FDIV64: Word = 4  | Mode64 | ModeFloat
    public static let FMOD64: Word = 5 | Mode64 | ModeFloat
    public static let ADD: Word = 1
    public static let SUB: Word = 2
    public static let MUL: Word = 3
    public static let DIV: Word = 4
    public static let MOD: Word = 5
    public static let CALL: Word = 27       /// CALL, statically call the method located at the address in operand1
    public static let CALLD: Word = 28      /// CALL DYNAMIC, dynamically call the method whose name is in the string pointed to by the first operand
    public static let RET: Word = 29        /// RETURN, return to the calling method
    public static let ENTER: Word = 30      /// ENTER, enter the call frame
    public static let LEAVE: Word = 31      /// LEAVE, leave the call frame
    public static let LINE: Word = 32       /// SOURCE LINE, the integer in operand1 contains the line number in the current file of the currently executing code
    public static let FILE: Word = 33       /// SET FILE, the string at the address in operand1 is the file that contains the source code for the code currently executing
    public static let LDP: Word = 34        /// LDP, load from pointer, load the value in the address in operand1 and store it in the operand in result
    public static let STP: Word = 35        /// STP, store into pointer, move the value in the address in operand1 into the address in result
    public static let MOV: Word = 36        /// MOVE, move the value in operand1 into result
    public static let MOVP: Word = 37       /// MOVE POINTER, move the value at the address in operand1 into the address in result
    public static let IPOW64: Word = 38 | Mode64 | ModeInteger
    public static let IPOW16: Word = 38 | Mode16 | ModeInteger
    public static let IPOW8: Word = 38  | Mode8  | ModeInteger
    public static let FPOW64: Word = 38 | Mode64 | ModeFloat
    public static let IAND64: Word = 39 | Mode64 | ModeInteger
    public static let IXOR64: Word = 40 | Mode64 | ModeInteger
    public static let IOR64: Word = 41  | Mode64 | ModeInteger
    public static let IAND16: Word = 39 | Mode16 | ModeInteger
    public static let IXOR16: Word = 40 | Mode16 | ModeInteger
    public static let IAND8: Word = 39  | Mode8  | ModeInteger
    public static let IXOR8: Word = 40  | Mode8  | ModeInteger
    public static let IOR8: Word = 41   | Mode8  | ModeInteger
    public static let SADD: Word = 50
    public static let IOR16: Word = 41  | Mode16 | ModeInteger
    public static let CAST: Word = 52
    public static let ILT64: Word = 50  | Mode64 | ModeInteger
    public static let ILTE64: Word = 51 | Mode64 | ModeInteger
    public static let IEQ64: Word = 52  | Mode64 | ModeInteger
    public static let IGTE64: Word = 53 | Mode64 | ModeInteger
    public static let IGT64: Word = 54  | Mode64 | ModeInteger
    public static let INEQ64: Word = 55 | Mode64 | ModeInteger
    public static let FLT64: Word = 50  | Mode64 | ModeFloat
    public static let FLTE64: Word = 51 | Mode64 | ModeFloat
    public static let FEQ64: Word = 52  | Mode64 | ModeFloat
    public static let FGTE64: Word = 53 | Mode64 | ModeFloat
    public static let FGT64: Word = 54  | Mode64 | ModeFloat
    public static let FNEQ64: Word = 55 | Mode64 | ModeFloat
    public static let ILT16: Word = 50  | Mode16 | ModeInteger
    public static let ILTE16: Word = 51 | Mode16 | ModeInteger
    public static let IEQ16: Word = 52  | Mode16 | ModeInteger
    public static let IGTE16: Word = 53 | Mode16 | ModeInteger
    public static let IGT16: Word = 54  | Mode16 | ModeInteger
    public static let INEQ16: Word = 55 | Mode16 | ModeInteger
    public static let ILT8: Word = 50   | Mode8  | ModeInteger
    public static let ILTE8: Word = 51  | Mode8  | ModeInteger
    public static let IEQ8: Word = 52   | Mode8  | ModeInteger
    public static let IGTE8: Word = 53  | Mode8  | ModeInteger
    public static let IGT8: Word = 54   | Mode8  | ModeInteger
    public static let INEQ8: Word = 55  | Mode8  | ModeInteger
    public static let SLT: Word = 71
    public static let SLTE: Word = 72
    public static let SEQ: Word = 73
    public static let SGTE: Word = 74
    public static let SGT: Word = 75
    public static let SNEQ: Word = 76
    public static let PUSH: Word = 77
    public static let POP: Word = 78
    public static let LDI: Word = 79
    public static let POPN: Word = 80
    public static let STSD: Word = 81
    public static let INEG64: Word = 82  | Mode64  | ModeInteger
    public static let INEG16: Word = 82  | Mode16  | ModeInteger
    public static let INEG8: Word = 82   | Mode8   | ModeInteger
    public static let FNEG64: Word = 82  | Mode64  | ModeFloat
    public static let IBNOT64: Word = 86 | Mode64  | ModeInteger
    public static let NOT: Word = 87
    public static let MAKE: Word = 88
    public static let SIG: Word = 89
    public static let HAND: Word = 90
    public static let BRAT: Word = 91    | ModeAbsolute | ConditionTrue
    public static let BRRT: Word = 91    | ModeRelative | ConditionTrue
    public static let BRAF: Word = 91    | ModeAbsolute | ConditionFalse
    public static let BRRF: Word = 91    | ModeRelative | ConditionFalse
    public static let BRR: Word = 92     | ModeRelative
    public static let BRA: Word = 93     | ModeAbsolute
    public static let PRIM: Word = 94   
    }
    
public class T3AInstruction: NSObject,NSCoding
    {
    private struct RawBitPattern: BitPattern
        {
        public let bits: Word
        public let shift: Word
        }
    
    private static let InstructionField = RawBitPattern(bits: 0b11111111_11111111_11111111_11111111,shift: 32)
    private static let Operand1Field = RawBitPattern(bits: 0b11111111,shift: 0)
    private static let Operand2Field = RawBitPattern(bits: 0b11111111,shift: 8)
    private static let ResultField = RawBitPattern(bits: 0b11111111,shift: 16)
        
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
            
        public var wordValue: Word
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .returnValue:
                    return(0)
                case .temporary(let temporary):
                    return(Word(temporary))
                case .label(let label):
                    return(Word(label.index))
                case .address(let address):
                    return(address)
                case .integer(let integer):
                    return(Word(integer: integer))
                case .float(let float):
                    return(Word(float: float))
                case .frameOffset(let offset):
                    return(Word(offset))
                }
            }
            
        public var rawValue: Word
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
        return(labelString + "\(self.opcode)" + " " + string)
        }
        
    public var comment: String?
    public var offset: Int = 0
    public var label: T3ALabel?
    public let opcode: Opcode
    public var operand1: Operand = .none
    public var operand2: Operand = .none
    public var result: Operand = .none
    
    init(_ label: T3ALabel? = nil,_ opcode: Opcode,_ operand1: Operand,_ operand2: Operand,_ result: Operand)
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
        self.opcode = Word(coder.decodeInteger(forKey: "opcode"))
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
        4 * Argon.kWordSizeInBytesInt
        }
        
    public func install(intoPointer aPointer: WordPointer,context: ExecutionContext)
        {
        var pointer = aPointer
        var word:Word = 0
        word |= (self.opcode << Self.InstructionField.shift)
        word |= (self.operand1.rawValue & Self.Operand1Field.bits) << Self.Operand1Field.shift
        word |= (self.operand2.rawValue & Self.Operand2Field.bits) << Self.Operand2Field.shift
        word |= (self.result.rawValue & Self.ResultField.bits) << Self.ResultField.shift
        pointer.pointee = word
        pointer += 1
        pointer.pointee = self.operand1.wordValue
        pointer += 1
        pointer.pointee = self.operand2.wordValue
        pointer += 1
        pointer.pointee = self.result.wordValue
        }
    }

public typealias T3AInstructions = Array<T3AInstruction>
