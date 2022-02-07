//
//  Instruction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/2/22.
//

import Foundation

public class Instruction
    {
    public static var opcodeLabels: Array<String>
        {
        let indices = Opcode.allCases.map{$0.rawValue}
        var strings = Array<String>()
        for index in indices
            {
            strings.append("\(Opcode(rawValue: index)!)")
            }
        return(strings)
        }
        
    public var displayString: String
        {
        let opString = "\(self.opcode)"
        var modeString = "\(self.mode)"
        var strings = Array<String>()
        if self.operand1.isNotNone
            {
            strings.append(self.operand1.displayString)
            }
        if self.operand2.isNotNone
            {
            strings.append(self.operand2.displayString)
            }
        if self.operand3.isNotNone
            {
            strings.append(self.operand3.displayString)
            }
        let string = strings.joined(separator: ",")
        if modeString == "none"
            {
            modeString = ""
            }
        return("\(opString) \(modeString) \(string)")
        }
        
    public var sizeInWords: Int
        {
        4
        }
        
    public static var sizeInWords: Int
        {
        4
        }
        
    public struct Temporary
        {
        public let index: Int
        
        init(index: Int)
            {
            self.index = index
            }
        }
        
    public struct Label
        {
        public let index: Int
        
        init(index: Int)
            {
            self.index = index
            }
        }
        
    public enum Mode: Word,BitFieldType
        {
        public static let bitWidth: Int = 4
        case none = 0
        case i64 = 1
        case i16 = 2
        case i8  = 3
        case f64 = 4
        case s64 = 5
        case iu64 = 6
        case string = 7
        }
        
    public enum Opcode: Word,BitFieldType,CaseIterable
        {
        public static let bitWidth: Int = 10
            
        case NOP = 0  /// OInstruction
        case ADD = 1  /// ORRRInstruction           Opcode Register Register Register
        case SUB = 2
        case MUL = 3
        case DIV = 4
        case MOD = 5
        case NEG = 6
        case LAND = 7
        case LOR = 8
        case LXOR = 9
        case LT = 10
        case LTE = 11
        case EQ = 12
        case NEQ = 13
        case GTE = 14
        case GT = 15
        case MAKE = 16  /// OAInstruction           Opcoeee Address
        case PUSH = 17  /// ORInstruction or OI     Opcode Register or Opcode Immediate
        case POP = 18
        case POPN = 19  /// OIInstruction           Opcode Immediate
        case CALL = 20
        case SEND = 21  /// OQAR
//        case LCON = 22  // LOAD CONSTANT IN OPERAND1 INTO OPERAND3
        case CAST = 23  // CAST OBJECT IN ADDRESS1 TO CLASS ADDRESS2 AND PUT THE RESULT INTO OPERAND3 OAARInstruction   opcode Address Address Register
        case LOADP = 24 // LOAD [ADDRESS1 + INTEGER2] INTO OPERAND3 OAIR                                                Opcode Address Immediate Register
        case STOREP = 25// STORE OPERAND1 IN [ADDRESS2 + INTEGER3] ORAI                                                 Opcode Register Address Immediate
        case MOVE = 26 // MOVE VALUE IN OPERAND1 INTO OPERAND2                                                          Opcode Operand Operand
        case BRT = 27   // ORL                                                                                          Opcode Register Label
        case BRF = 28   // ORL
        case BR = 29    // OL                                                                                           Opcode Label
        case SAVE = 30  // O
        case REST = 31  // O
        case LINE = 32  // OI
        case FILE = 33  // OA
        case POW = 34   // RRR
        case AND = 35   // RRR
        case OR = 36    // RRR
        case CONVERT = 37 // RII -> RR = Opcode Register Immediate Immediate
        case CLASS = 38     // OA
        case DATECADD = 39  // ORAR
        case DATESUB = 40   // ORRR
        case DATECSUB = 41  // ORAR
        case TIMECADD = 42
        case TIMECSUB = 43
        case DTIMCADD = 44
        case DTIMCSUB = 45
        case TIMSUB = 46
        case DTIMSUB = 47
        case DDIFF = 48 // ORRR
        case TDIFF = 49
        case LOOKUP = 50 // OAIR
        case LNOT = 51
        case NOT = 52
        case HAND = 53 // OR
        case PRIM = 54 // OI
        case RET = 55
        case SIG = 56  // OI
        case SLOTR = 57
        case SLOTW = 58
        case COMM = 59
        case ADDRESS = 60 // ORR
        }
        
    public enum Register: Word
        {
        case NONE = 0
        case HP
        case BP
        case SP
        case CP
        case KP
        case IP
        case RR
        case GPR0,GPR1,GPR2,GPR3,GPR4,GPR5,GPR6,GPR7,GPR8,GPR9
        case GPR10,GPR11,GPR12,GPR13,GPR14,GPR15,GPR16,GPR17,GPR18,GPR19
        case GPR20,GPR21,GPR22,GPR23,GPR24,GPR25,GPR26,GPR27,GPR28,GPR29
        case GPR30,GPR31,GPR32,GPR33,GPR34,GPR35,GPR36,GPR37,GPR38,GPR39
        case GPR40,GPR41,GPR42,GPR43,GPR44,GPR45,GPR46,GPR47,GPR48,GPR49
        case GPR50,GPR51,GPR52,GPR53,GPR54,GPR55,GPR56,GPR57,GPR58,GPR59
        case GPR60,GPR61,GPR62,GPR63
        case FPR0,FPR1,FPR2,FPR3,FPR4,FPR5,FPR6,FPR7,FPR8,FPR9
        case FPR10,FPR11,FPR12,FPR13,FPR14,FPR15,FPR16,FPR17,FPR18,FPR19
        case FPR20,FPR21,FPR22,FPR23,FPR24,FPR25,FPR26,FPR27,FPR28,FPR29
        case FPR30,FPR31
        case SR0,SR1,SR2,SR3,SR4,SR5,SR6,SR7,SR8,SR9
        case SR10,SR11,SR12,SR13,SR14,SR15,SR16,SR17,SR18,SR19
        case SR20,SR21,SR22,SR23,SR24
        
        public var isSpecialRegister: Bool
            {
            self.rawValue > 0 && self.rawValue < Register.GPR0.rawValue
            }
            
        public var isIntegerRegister: Bool
            {
            self.rawValue > Register.GPR0.rawValue && self.rawValue <= Register.GPR63.rawValue
            }
            
        public var isFloatRegister: Bool
            {
            self.rawValue >= Register.FPR0.rawValue && self.rawValue <= Register.FPR31.rawValue
            }
            
        public var isStringRegister: Bool
            {
            self.rawValue >= Register.SR0.rawValue && self.rawValue <= Register.SR24.rawValue
            }
        }
        
    public enum Operand
        {
        public static func ==(lhs:Operand,rhs:OperandKind) -> Bool
            {
            switch(lhs)
                {
                case .none:
                    return(rhs == .none || rhs == .anything)
                case .address:
                    return(rhs == .address || rhs == .anything)
                case .register:
                    return(rhs == .register || rhs == .anything)
                case .temporary:
                    return(rhs == .temporary || rhs == .anything)
                case .integer:
                    return(rhs == .integer || rhs == .anything)
                case .float:
                    return(rhs == .float || rhs == .anything)
                case .frameOffset:
                    return(rhs == .frameOffset || rhs == .anything)
                case .label:
                    return(rhs == .label || rhs == .anything)
                case .byte:
                    return(rhs == .byte || rhs == .anything)
                case .character:
                    return(rhs == .character || rhs == .anything)
                case .boolean:
                    return(rhs == .boolean || rhs == .anything)
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
                    return("")
                case .address(let address):
                    return(String(format: "%llX",address))
                case .register(let register):
                    return("\(register)")
                case .temporary(let temp):
                    return("TEMP(\(temp))")
                case .integer(let value):
                    return("INTEGER(\(value))")
                case .float(let value):
                    return("FLOAT(\(value))")
                case .frameOffset(let offset):
                    return("FRAME(\(offset))")
                case .label(let label):
                    return("LABEL(\(label))")
                case .byte(let value):
                    return("BYTE(\(value))")
                case .character(let offset):
                    return("CHAR(\(offset))")
                case .boolean(let label):
                    return("BOOL(\(label))")
                }
            }
            
        public static let kTagShift:Word = 59
        public static let kTagMask:Word = 0b1111 << Operand.kTagShift
        
        case none
        case address(Word)
        case register(Register)
        case temporary(Int)
        case integer(Argon.Integer)
        case float(Argon.Float)
        case byte(Argon.Byte)
        case character(Argon.Character)
        case boolean(Argon.Boolean)
        case frameOffset(Int)
        case label(Int)
    
        public var addressValue: Word
            {
            switch(self)
                {
                case .address(let address):
                    return(address)
                default:
                    return(0)
                }
            }
            
        public var labelValue: Int
            {
            switch(self)
                {
                case .label(let label):
                    return(label)
                default:
                    fatalError()
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
            
        public var tag: Word
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .address:
                    return(1)
                case .register:
                    return(2)
                case .temporary:
                    return(3)
                case .integer:
                    return(4)
                case .float:
                    return(5)
                case .frameOffset:
                    return(6)
                case .label:
                    return(7)
                case .byte:
                    return(8)
                case .character:
                    return(9)
                case .boolean:
                    return(10)
                }
            }
            
        public var encodedOperand: Word
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .address(let address):
                    let value = address & ~Self.kTagMask
                    return((self.tag << Self.kTagShift) | value)
                case .register(let register):
                    let value = register.rawValue & ~Self.kTagMask
                    return((self.tag << Self.kTagShift) | value)
                case .temporary(let index):
                    return((self.tag << Self.kTagShift) | Word(index))
                case .integer(let integer):
                    let value = Word(bitPattern: integer) & ~Self.kTagMask
                    return((self.tag << Self.kTagShift) | value)
                case .float(let float):
                    let value = float.bitPattern & ~Self.kTagMask
                    return((self.tag << Self.kTagShift) | value)
                case .frameOffset(let offset):
                    let value = Word(bitPattern: offset) & ~Self.kTagMask
                    return((self.tag << Self.kTagShift) | value)
                case .label(let index):
                    return((self.tag << Self.kTagShift) | Word(index))
                case .byte(let byte):
                    let value = Word(byte & 255) & ~Self.kTagMask
                    return((self.tag << Self.kTagShift) | value)
                case .character(let offset):
                    let value = Word(offset & 65535) & ~Self.kTagMask
                    return((self.tag << Self.kTagShift) | value)
                case .boolean(let boolean):
                    let value = Word((boolean == .trueValue ? Word(1) : Word(0)) & Word(1))
                    return((self.tag << Self.kTagShift) | value)
                }
            }
            
        public init(encodedOperand word: Word)
            {
            let tag = (word & Self.kTagMask) >> Self.kTagShift
            switch(tag)
                {
                case(0):
                    self = .none
                case(1):
                    self = .address(word & ~Self.kTagMask)
                case(2):
                    self = .register(Register(rawValue: word & ~Self.kTagMask)!)
                case(3):
                    self = .temporary(Int(word & ~Self.kTagMask))
                case(4):
                    self = .integer(Argon.Integer(bitPattern: word & ~Self.kTagMask))
                case(5):
                    self = .float(Argon.Float(bitPattern: word & ~Self.kTagMask))
                case(6):
                    self = .frameOffset(Int(bitPattern: word & ~Self.kTagMask))
                case(7):
                    self = .label(Int(bitPattern: word & ~Self.kTagMask))
                case(8):
                    self = .byte(Argon.Byte((word & ~Self.kTagMask) >> Self.kTagShift))
                case(9):
                    self = .character(Argon.Character(word & ~Self.kTagMask))
                case(10):
                    self = .boolean(word & ~Self.kTagMask == 1 ? .trueValue : .falseValue)
                default:
                    fatalError()
                }
            }
        }
        
    public var labelValue: Int?
        {
        if self.operand1.isLabel
            {
            return(self.operand1.labelValue)
            }
        if self.operand2.isLabel
            {
            return(self.operand2.labelValue)
            }
        if self.operand3.isLabel
            {
            return(self.operand3.labelValue)
            }
        return(nil)
        }
        
    public var index: Int = 0
    public var label: Operand?
    public let opcode: Opcode
    private let mode: Mode
    public var operand1: Operand = .none
    public var operand2: Operand = .none
    public var operand3: Operand = .none
    
    public init(wordPointer: WordPointer)
        {
        let word = wordPointer[0]
        let modeIndex = word >> 10
        let opcodeIndex = word & 0b1111111111
        self.opcode = Opcode(rawValue: opcodeIndex)!
        self.mode = Mode(rawValue: modeIndex)!
        self.operand1 = Operand(encodedOperand: wordPointer[1])
        self.operand2 = Operand(encodedOperand: wordPointer[2])
        self.operand3 = Operand(encodedOperand: wordPointer[3])
        }
        
    public init(mode: Mode,opcode: Opcode)
        {
        self.mode = mode
        self.opcode = opcode
        }
        
    public init(_ mode: Mode = .i64,_ opcode: Opcode,register1: Register,register2: Register,register3: Register)
        {
        self.opcode = opcode
        self.mode = mode
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        }
        
    public init(_ mode: Mode = .i64,_ opcode: Opcode,_ op1:Operand,_ op2:Operand,_ op3:Operand)
        {
        self.opcode = opcode
        self.mode = mode
        self.operand1 = op1
        self.operand2 = op2
        self.operand3 = op3
        }
        
    public init(_ mode: Mode = .i64,_ opcode: Opcode,temporary1: Temporary,temporary2: Temporary,temporary3: Temporary)
        {
        self.opcode = opcode
        self.mode = mode
        self.operand1 = .temporary(temporary1.index)
        self.operand2 = .temporary(temporary2.index)
        self.operand3 = .temporary(temporary3.index)
        }
        
    public init(_ opcode: Opcode,address: Word)
        {
        if opcode == .CALL && address > 20000005320
            {
            print("halt")
            }
        self.mode = .none
        self.opcode = opcode
        self.operand1 = .address(address)
        self.operand2 = .none
        self.operand3 = .none
        }
        
    public init(_ opcode: Opcode,address: Word,register: Register)
        {
        self.mode = .none
        self.opcode = opcode
        self.operand1 = .address(address)
        self.operand2 = .none
        self.operand3 = .register(register)
        }
        
    public init(_ opcode: Opcode,address: Word,temporary: Temporary)
        {
        self.mode = .none
        self.opcode = opcode
        self.operand1 = .address(address)
        self.operand2 = .none
        self.operand3 = .temporary(temporary.index)
        }
        
    public init(_ opcode: Opcode,temporary: Temporary)
        {
        self.mode = .none
        self.opcode = opcode
        self.operand1 = .temporary(temporary.index)
        self.operand2 = .none
        self.operand3 = .none
        }
        
    public init(_ opcode: Opcode,integer: Int)
        {
        self.mode = .none
        self.opcode = opcode
        self.operand1 = .integer(Argon.Integer(integer))
        self.operand2 = .none
        self.operand3 = .none
        }
        
    public init(_ opcode: Opcode,address1: Word,address2: Word,register: Register)
        {
        self.mode = .none
        self.opcode = opcode
        self.operand1 = .address(address1)
        self.operand2 = .address(address2)
        self.operand3 = .register(register)
        }
        
    public init(_ opcode: Opcode,address1: Word,address2: Word,temporary: Temporary)
        {
        self.mode = .none
        self.opcode = opcode
        self.operand1 = .address(address1)
        self.operand2 = .address(address2)
        self.operand3 = .temporary(temporary.index)
        }
        
    ///
    /// LOADP [ ADDRESS + INTEGER] REGISTER
    ///
    public init(_ opcode: Opcode,address: Word,integer: Int,register: Register)
        {
        self.mode = .none
        self.opcode = opcode
        self.operand1 = .address(address)
        self.operand2 = .integer(Argon.Integer(integer))
        self.operand3 = .register(register)
        }
        
    ///
    /// STOREP REGISTER [ ADDRESS + INTEGER]
    ///
    public init(_ opcode: Opcode,register: Register,address: Word,integer: Int)
        {
        self.mode = .none
        self.opcode = opcode
        self.operand1 = .register(register)
        self.operand2 = .address(address)
        self.operand3 = .integer(Argon.Integer(integer))
        }
        
    public func install(intoPointer: WordPointer,context: ExecutionContext)
        {
        var pointer = intoPointer
        var word = self.opcode.rawValue
        word = mode.rawValue << 10 | word
        pointer.pointee = word
        pointer += 1
        pointer.pointee = self.operand1.encodedOperand
        pointer += 1
        pointer.pointee = self.operand2.encodedOperand
        pointer += 1
        pointer.pointee = self.operand3.encodedOperand
        }
        
    public func replaceLabel(withAddress: Word)
        {
        if self.operand1.isLabel
            {
            self.operand1 = .address(withAddress)
            return
            }
        if self.operand2.isLabel
            {
            self.operand2 = .address(withAddress)
            return
            }
        if self.operand3.isLabel
            {
            self.operand3 = .address(withAddress)
            return
            }
        }
    }

