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
    
    public var displayString: String
        {
        switch(self)
            {
            case .NOP:
                return("NOP")
            case .IADD64:
                return("IADD64")
            case .IADD16:
                return("IADD16")
            case .IADD8:
                return("IADD8")
            case .FADD64:
                return("FADD64")
            case .ISUB64:
                return("ISUB64")
            case .ISUB16:
                return("ISUB16")
            case .ISUB8:
                return("ISUB8")
            case .FSUB64:
                return("FSUB64")
            case .IDIV64:
                return("IDIV64")
            case .IDIV16:
                return("IDIV16")
            case .IDIV8:
                return("IDIV8")
            case .FDIV64:
                return("FDIV64")
            case .IMUL64:
                return("IMUL64")
            case .IMUL16:
                return("IMUL16")
            case .IMUL8:
                return("IMUL8")
            case .FMUL64:
                return("FMUL64")
            case .IMOD64:
                return("IMOD64")
            case .IMOD16:
                return("IMOD16")
            case .IMOD8:
                return("IMOD8")
            case .FMOD64:
                return("FMOD64")
            case .ADD:
                return("ADD")
            case .MUL:
                return("MUL")
            case .DIV:
                return("DIV")
            case .SUB:
                return("SUB")
            case .MOD:
                return("MOD")
            case .CALL:
                return("CALL")
            case .CALLD:
                return("CALLD")
            case .RET:
                return("RET")
            case .ENTER:
                return("ENTER")
            case .LEAVE:
                return("LEAVE")
            case .PUSH:
                return("PUSH")
            case .POP:
                return("POP")
            case .POPN:
                return("POPN")
            case .CAST:
                return("CAST")
            case .IPOW64:
                return("IPOW64")
            case .IPOW16:
                return("IPOW16")
            case .IPOW8:
                return("IPOW8")
            case .FPOW64:
                return("FPOW64")
            case .INEG64:
                return("INEG64")
            case .INEG16:
                return("INEG16")
            case .INEG8:
                return("INEG8")
            case .FNEG64:
                return("FNEG64")
            case .IAND64:
                return("IAND64")
            case .IAND16:
                return("IAND16")
            case .IAND8:
                return("IAND8")
            case .IOR64:
                return("IOR64")
            case .IOR16:
                return("IOR16")
            case .IOR8:
                return("IOR8")
            case .IXOR64:
                return("IXOR64")
            case .IXOR16:
                return("IXOR16")
            case .IXOR8:
                return("IXOR8")
            case .LINE:
                return("LINE")
            case .FILE:
                return("FILE")
            case .SOAO:
                return("SOAO")
            case .LRAO:
                return("LRAO")
            case .SADD:
                return("SADD")
            case .SLT:
                return("SLT")
            case .SLTE:
                return("SLTE")
            case .SEQ:
                return("SEQ")
            case .SGT:
                return("SGT")
            case .SGTE:
                return("SGTE")
            case .FLT64:
                return("FLT64")
            case .FLTE64:
                return("FLTE64")
            case .FEQ64:
                return("FEQ64")
            case .FGT64:
                return("FGT64")
            case .FGTE64:
                return("FGTE64")
            case .ILT64:
                return("ILT64")
            case .ILTE64:
                return("ILTE64")
            case .IEQ64:
                return("IEQ64")
            case .IGT64:
                return("IGT64")
            case .IGTE64:
                return("IGTE64")
            case .ILT16:
                return("ILT16")
            case .ILTE16:
                return("ILTE16")
            case .IEQ16:
                return("IEQ16")
            case .IGT16:
                return("IGT16")
            case .IGTE16:
                return("IGTE16")
            case .ILT8:
                return("ILT8")
            case .ILTE8:
                return("ILTE8")
            case .IEQ8:
                return("IEQ8")
            case .IGT8:
                return("IGT8")
            case .IGTE8:
                return("IGTE8")
            case .NOT:
                return("NOT")
            case .MAKE:
                return("MAKE")
            case .SIG:
                return("SIG")
            case .HAND:
                return("HAND")
            case .PRIM:
                return("PRIM")
            case .OEQ:
                return("OEQ")
            case .ONEQ:
                return("ONEQ")
            case .LDI:
                return("LDI")
            case .MOV:
                return("MOV")
            case .DADD:
                return("DADD")
            case .DSUB:
                return("DSUB")
            case .DMUL:
                return("DMUL")
            case .DPOW:
                return("DPOW")
            case .DDIV:
                return("DDIV")
            case .DAND:
                return("DAND")
            case .DOR:
                return("DOR")
            case .DXOR:
                return("DXOR")
            case .DLT:
                return("DLT")
            case .DLTE:
                return("DLTE")
            case .DEQ:
                return("DEQ")
            case .DNEQ:
                return("DNEQ")
            case .DGT:
                return("DGT")
            case .DGTE:
                return("DGTE")
            case .SLOTR:
                return("SLOTR")
            case .SLOTW:
                return("SLOTW")
            case .CLASS:
                return("CLASS")
            case .CONVERT:
                return("CONVERT")
            case .DATECADD:
                return("DATECADD")
            case .DATECSUB:
                return("DATECSUB")
            case .TIMECADD:
                return("TIMECADD")
            case .TIMECSUB:
                return("TIMECSUB")
            case .DTIMCADD:
                return("DTIMCADD")
            case .DTIMCSUB:
                return("DTIMCSUB")
            case .DATESUB:
                return("DATESUB")
            case .TIMESUB:
                return("TIMESUB")
            case .DTIMSUB:
                return("DTIMSUB")
            case .DDIFF:
                return("DDIFF")
            case .TDIFF:
                return("TDIFF")
            case .LOOKUP:
                return("LOOKUP")
            case .STP:
                return("STP")
            case .MRKFRM:
                return("MRKFRM")
            case .UNDFRM:
                return("UNDFRM")
            case .SEND:
                return("SEND")
            default:
                return("\(self) UNKNOWN")
            }
        }
        
    public static let NOP: Word = 0
    public static let IADD64: Word = 1
    public static let ISUB64: Word = 2
    public static let IMUL64: Word = 3
    public static let IDIV64: Word = 4
    public static let IMOD64: Word = 5
    public static let IADD16: Word = 6
    public static let ISUB16: Word = 7
    public static let IMUL16: Word = 8
    public static let IDIV16: Word = 9
    public static let IMOD16: Word = 10
    public static let IADD8: Word = 11
    public static let ISUB8: Word = 12
    public static let IMUL8: Word = 13
    public static let IDIV8: Word = 14
    public static let IMOD8: Word = 15
    public static let FADD64: Word = 16
    public static let FSUB64: Word = 17
    public static let FMUL64: Word = 18
    public static let FDIV64: Word = 19
    public static let FMOD64: Word = 20
    public static let ADD: Word = 21
    public static let SUB: Word = 22
    public static let MUL: Word = 23
    public static let DIV: Word = 24
    public static let MOD: Word = 25
    public static let CALL: Word = 26       /// CALL, statically call the method located at the address in operand1
    public static let CALLD: Word = 27      /// CALL DYNAMIC, dynamically call the method whose name is in the string pointed to by the first operand
    public static let RET: Word = 28        /// RETURN, return to the calling method
    public static let ENTER: Word = 29      /// ENTER, enter the call frame
    public static let LEAVE: Word = 30      /// LEAVE, leave the call frame
    public static let LINE: Word = 31       /// SOURCE LINE, the integer in operand1 contains the line number in the current file of the currently executing code
    public static let FILE: Word = 32       /// SET FILE, the string at the address in operand1 is the file that contains the source code for the code currently executing
    public static let LRAO: Word = 33       /// LOAD RESULT FROM CONTENTS OF ADDRESS + OFFSET
    public static let SOAO: Word = 34       /// STORE OPERAND1 INTO CONTENTS OF ADDRESS + OFFSET
    public static let MOV: Word = 35        /// MOVE, move the value in operand1 into result
    public static let MOVP: Word = 36       /// MOVE POINTER, move the value at the address in operand1 into the address in result
    public static let IPOW64: Word = 37
    public static let IPOW16: Word = 38
    public static let IPOW8: Word = 39
    public static let FPOW64: Word = 40
    public static let IAND64: Word = 41
    public static let IXOR64: Word = 42
    public static let IOR64: Word = 43
    public static let IAND16: Word = 44
    public static let IXOR16: Word = 45
    public static let IAND8: Word = 46
    public static let IXOR8: Word = 47
    public static let IOR8: Word = 48
    public static let SADD: Word = 49
    public static let IOR16: Word = 50
    public static let CAST: Word = 51
    public static let ILT64: Word = 52
    public static let ILTE64: Word = 53
    public static let IEQ64: Word = 54
    public static let IGTE64: Word = 55
    public static let IGT64: Word = 56
    public static let INEQ64: Word = 57
    public static let FLT64: Word = 58
    public static let FLTE64: Word = 59
    public static let FEQ64: Word = 60
    public static let FGTE64: Word = 61
    public static let FGT64: Word = 62
    public static let FNEQ64: Word = 63
    public static let ILT16: Word = 64
    public static let ILTE16: Word = 65
    public static let IEQ16: Word = 66
    public static let IGTE16: Word = 67
    public static let IGT16: Word = 68
    public static let INEQ16: Word = 69
    public static let ILT8: Word = 70
    public static let ILTE8: Word = 71
    public static let IEQ8: Word = 72
    public static let IGTE8: Word = 73
    public static let IGT8: Word = 74
    public static let INEQ8: Word = 75
    public static let SLT: Word = 76
    public static let SLTE: Word = 77
    public static let SEQ: Word = 78
    public static let SGTE: Word = 79
    public static let SGT: Word = 80
    public static let SNEQ: Word = 81
    public static let PUSH: Word = 82
    public static let POP: Word = 83
    public static let LDI: Word = 84
    public static let POPN: Word = 85
    public static let INEG64: Word = 86
    public static let INEG16: Word = 87
    public static let INEG8: Word = 88
    public static let FNEG64: Word = 89
    public static let IBNOT64: Word = 90
    public static let NOT: Word = 91
    public static let MAKE: Word = 92
    public static let SIG: Word = 93
    public static let HAND: Word = 94
    public static let BRT: Word = 95
    public static let BRF: Word = 96
    public static let BR: Word = 97
    public static let PRIM: Word = 98
    public static let OEQ: Word = 99
    public static let ONEQ: Word = 100
    public static let DADD: Word = 101
    public static let DSUB: Word = 102
    public static let DMUL: Word = 103
    public static let DDIV: Word = 104
    public static let DMOD: Word = 105
    public static let DOR: Word = 106
    public static let DAND: Word = 107
    public static let DXOR: Word = 108
    public static let DPOW: Word = 109
    public static let DLT: Word = 110
    public static let DLTE: Word = 111
    public static let DEQ: Word = 112
    public static let DNEQ: Word = 113
    public static let DGT: Word = 114
    public static let DGTE: Word = 115
    public static let SLOTR: Word = 116
    public static let SLOTW: Word = 117
    public static let CLASS: Word = 118
    public static let CONVERT: Word = 119
    public static let DATECADD: Word = 120
    public static let DATECSUB: Word = 121
    public static let TIMECADD: Word = 122
    public static let TIMECSUB: Word = 123
    public static let DTIMCADD: Word = 124
    public static let DTIMCSUB: Word = 125
    public static let DATESUB: Word = 126
    public static let TIMESUB: Word = 127
    public static let DTIMSUB: Word = 128
    public static let DDIFF: Word = 129
    public static let TDIFF: Word = 130
    public static let LOOKUP: Word = 131
    public static let STP: Word = 132
    public static let LDP: Word = 133
    public static let SAVE: Word = 134
    public static let RESTORE: Word = 135
    public static let MRKFRM: Word = 136
    public static let UNDFRM: Word = 137
    public static let SEND: Word = 138
    }
    
public class T3AInstruction: NSObject,NSCoding
    {
    private struct RawBitPattern: BitPattern
        {
        public let bits: Word
        public let shift: Word
        
        public var mask: Word
            {
            self.bits << self.shift
            }
            
        public var notMask: Word
            {
            ~self.mask
            }
        }
    
    private static let InstructionField = RawBitPattern(bits: 0b11111111_11111111_11111111_11111111,shift: 32)
    private static let Operand1Field = RawBitPattern(bits: 0b11111111,shift: 0)
    private static let Operand2Field = RawBitPattern(bits: 0b11111111,shift: 8)
    private static let ResultField = RawBitPattern(bits: 0b11111111,shift: 16)
        
    public static let sizeInBytes: Int = 4 * Argon.kWordSizeInBytesInt
    
    public let sizeInWords: Int = 4
    
    private static var nextTemp = 1
    
    public static func nextTemporary() -> Operand
        {
        let index = Self.nextTemp
        T3AInstruction.nextTemp += 1
        return(.temporary(index))
        }
        
    public indirect enum Operand
        {
        public var label: T3ALabel
            {
            switch(self)
                {
                case .label(let label):
                    return(label)
                default:
                    fatalError("You should not ask an operand of this type for a label")
                }
            }
            
        public var isLabel: Bool
            {
            switch(self)
                {
                case .label:
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
                    return(Word(integer: offset))
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
        
    public var operandCount: Int
        {
        var count = 0
        if self.operand1.isNotNone
            {
            count += 1
            }
        if self.operand2.isNotNone
            {
            count += 1
            }
        if self.result.isNotNone
            {
            count += 1
            }
        return(count)
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
        if self.opcode == .FDIV64 && self.operandCount == 2
            {
            fatalError()
            }
        return(labelString + "\(self.opcode.displayString)" + " " + string)
        }
        
    public typealias Operands = Array<Operand>
        
    public var comment: String?
    public var offset: Int = 0
    public var label: T3ALabel?
    public let opcode: Opcode
    public var operand1: Operand = .none
    public var operand2: Operand = .none
    public var result: Operand = .none
    
    init(opcode: Opcode)
        {
        self.opcode = opcode
        }
        
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
        self.opcode = Word(bitPattern: coder.decodeInteger(forKey: "opcode"))
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
        coder.encode(Int(bitPattern: self.opcode),forKey: "opcode")
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
        var word = (self.opcode << Self.InstructionField.shift)
        word |= (self.operand1.rawValue & Self.Operand1Field.bits) << Self.Operand1Field.shift
        word |= (self.operand2.rawValue & Self.Operand2Field.bits) << Self.Operand2Field.shift
        word |= (self.result.rawValue & Self.ResultField.bits) << Self.ResultField.shift
        aPointer[0] = word
        aPointer[1] = self.operand1.wordValue
        aPointer[2] = self.operand2.wordValue
        aPointer[3] = self.result.wordValue
        }
        
    public func mutateLabelsIntoAddresses()
        {
        if self.operand1.isLabel
            {
            let label = self.operand1.label
            if label.address == 0
                {
                fatalError("Address of label is not valid.")
                }
            self.operand1 = .address(label.address)
            }
        if self.operand2.isLabel
            {
            let label = self.operand2.label
            if label.address == 0
                {
                fatalError("Address of label is not valid.")
                }
            self.operand2 = .address(label.address)
            }
        if self.result.isLabel
            {
            let label = self.result.label
            if label.address == 0
                {
                fatalError("Address of label is not valid.")
                }
            self.result = .address(label.address)
            }
        }
        
    public func write(on bitSet: BitSet)
        {
        
        }
    }

public typealias T3AInstructions = Array<T3AInstruction>
