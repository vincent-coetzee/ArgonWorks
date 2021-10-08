//
//  Instruction.swift
//  Instruction
//
//  Created by Vincent Coetzee on 28/7/21.
//

import Foundation
import Interpreter
import SwiftUI
    
fileprivate var contextStack = Stack<Array<Word>>()

public struct ExecutionError:Error
    {
//    public let context:ExecutionContext
    public let errorType:ExecutionErrorType
    }
    
public enum ExecutionErrorType:Error
    {
    case invalidIntegerOperand
    case invalidFloatOperand
    case invalidWordOperand
    case invalidRegister
    }
    
public protocol RawConvertible
    {
    var rawValue: Int { get }
    }
    
public protocol BitCodable
    {
    func encode(in:BitEncoder)
    }
    
public class Instruction:Identifiable
    {
    public static let opcodeField = PackedField<Instruction.Opcode>(offset: 0, width: 8)
    public static let operand1KindField = PackedField<Word>(offset:8,width:4)
    public static let operand1RegisterField = PackedField<Instruction.Register>(offset:12,width:8)
    public static let operand2KindField = PackedField<Word>(offset:20,width:4)
    public static let operand2RegisterField = PackedField<Instruction.Register>(offset:24,width:8)
    public static let resultKindField = PackedField<Word>(offset:32,width:4)
    public static let resultRegisterField = PackedField<Instruction.Register>(offset:36,width:8)
    public static let lineNumberField = PackedField<Word>(offset:44,width:19)
    
    public static func ==(lhs:Instruction,rhs:Instruction) -> Bool
        {
        if lhs.opcode != rhs.opcode
            {
            return(false)
            }
        if lhs.operand1 != rhs.operand1 || lhs.operand2 != rhs.operand2 || lhs.result != rhs.result
            {
            return(false)
            }
        return(true)
        }
        
    public class LabelMarker
        {
        public enum Origin
            {
            case to(Int)
            case from(Int)
            
            public var isTo: Bool
                {
                switch(self)
                    {
                    case .to:
                        return(true)
                    default:
                        return(false)
                    }
                }
                
            public var isFrom: Bool
                {
                switch(self)
                    {
                    case .from:
                        return(true)
                    default:
                        return(false)
                    }
                }
                
            public var index: Int
                {
                switch(self)
                    {
                    case .to(let index):
                        return(index)
                    case .from(let index):
                        return(index)
                    }
                }
            }
            
        private let origin: Origin
        private var trigger: LabelTrigger?
        
        init(to instruction: Instruction,useTrigger: Bool)
            {
            self.origin = .to(instruction.lineNumber)
            if useTrigger
                {
                self.trigger = LabelTrigger(instruction: instruction)
                }
            }
            
        init(from instruction: Instruction,useTrigger: Bool)
            {
            self.origin = .from(instruction.lineNumber)
            if useTrigger
                {
                self.trigger = LabelTrigger(instruction: instruction)
                }
            }
            
        public func trigger(origin: Origin) throws -> Argon.Integer
            {
            if self.origin.isTo && origin.isFrom
                {
                let delta = self.origin.index - origin.index
                self.trigger?.trigger(delta: delta)
                return(Argon.Integer(delta))
                }
            if self.origin.isFrom && origin.isTo
                {
                let delta = origin.index - self.origin.index
                self.trigger?.trigger(delta: delta)
                return(Argon.Integer(delta))
                }
            throw(NSError(domain: "argon", code: 1000, userInfo: [:]))
            }
        }
        
    public class LabelTrigger
        {
        private let instruction: Instruction
        
        init(instruction: Instruction)
            {
            self.instruction = instruction
            }
            
        public func trigger(delta: Int)
            {
            instruction.result = .label(Argon.Integer(delta))
            }
        }
        
    public enum Register:Int,Comparable,CaseIterable,Identifiable,Equatable
        {
        public static var generalPurposeRegisters = [Self.R0,Self.R1,Self.R2,Self.R3,Self.R4,Self.R5,Self.R6,Self.R7,Self.R8,Self.R9,Self.R10,Self.R11,Self.R12,Self.R13,Self.R14,Self.R15]
        
        public static let bitWidth = 8
        
        public static func <(lhs:Register,rhs:Register) -> Bool
            {
            return(lhs.rawValue < rhs.rawValue)
            }
            
        case MI = 0     /// This points to the current method instance, ip is realtive to the instruction sequence in this method
        case SS         /// Points to the current stack segment
        case STS        /// Points to the fixed or static segment, we could not call it static because static is a reserved word
        case MS         /// Points to the current managed segment
        case DS         /// Points to the current data segment
        case CP         /// The code pointer points to the current method instance being executed
        case IP         /// the ip points to the sequence of instructions being executed
        case II         /// the instruction index, is an index into the sequence of instructions being executed
        case SP         /// the sp points to the top of the stack
        case BP         /// the bp points to the base of the current stack frame
        case FP         /// the fp points to the next available slot in the fixed segment
        case MP         /// the mp points to the next avaialble slot in the managed segmeng
        case EP
        case RET
        case R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15
        case FR0,FR1,FR2,FR3,FR4,FR5,FR6,FR7,FR8,FR9,FR10,FR11,FR12,FR13,FR14,FR15
        
        public var displayString: String
            {
            return("\(self)".uppercased())
            }
            
        public var isFloatingPoint: Bool
            {
            return(self >= .FR0 && self <= .FR15)
            }
            
        public var id:Int
            {
            return(self.rawValue)
            }
        }
        
    public enum LiteralValue:Equatable
        {
        case `nil`
        case string(String)
        case symbol(String)
        case `class`(Class)
        case module(Module)
        case enumeration(Enumeration)
        case enumerationCase(EnumerationCase)
        case method(Method)
        case constant(Constant)
        case relocation(Int)
        case `self`
        case `Self`
        case `super`
        case DSNextAddress
        case MAKE
        }
        
    public enum Opcode:Int
        {
        public static let bitWidth = 8
        
        case NOP = 0
        case IADD,ISUB,IMUL,IDIV,IMOD,IPOW,INEG
        case FADD,FSUB,FMUL,FDIV,FMOD,FPOW,FNEG
        case IBITAND,IBITOR,IBITXOR,IBITNOT
        case AND,OR,NOT
        case LOAD,STORE,MOV
        case BR,BREQ,BRNEQ,BRT,BRF
        case INC,DEC
        case MAKE
        case CALL,RET, DISP, NEXT
        case PUSH,POP,ENTER,LEAVE,SAVE,REST
        case LOOPEQ,LOOPNEQ,LOOPNZ,LOOPZ
        case SCAT,SREV,SCMP,SCNT,SCPY
        case REIN
        case SIG,HAND
        case ZERO
        case CMPW, CMPO
        
        public var displayString: String
            {
            return("\(self)".uppercased())
            }
        }
        
    public enum Operand:Equatable
        {
        ///
        ///
        /// .none is self explanatory
        ///
        ///
        case none
        ///
        ///
        /// A relocation reference contains an item which must be relocated. This item will
        /// be written out to the literals section of the object file when the object
        /// file containing this instruction is written out.
        ///
        ///
        case relocation(LiteralValue)
        ///
        ///
        /// A register is a register is a register
        ///
        ///
        case register(Register)
        ///
        ///
        /// The operand contains an encoded float
        ///
        ///
        case float(Argon.Float)
        ///
        ///
        /// The operand contains an encoded integer
        ///
        ///
        case integer(Argon.Integer)
        ///
        ///
        /// The operand contains an absolute address, this is
        /// effectively a word which will get loaded into the
        /// given place. If you want the contents of the address
        /// in the operand, then use the .indirect operand.
        /// Absolute operands are used to load abolute addresses
        /// into registers for use with indirect operands.
        ///
        ///
        case absolute(Word)
        ///
        ///
        /// An indirect operand contains a register and an offset,
        /// the offset is added to the value in the register
        /// and that value is used to index memory, i.e.
        ///
        /// absolute address = address in register + offset
        ///
        /// from that indexed position the word there is
        /// taken and becomes the value of the operand. So if you
        /// want to work with addresses that point to things
        /// ( such as an object pointer ) use an indirect operand
        /// rather than an absolute operand.
        case indirect(Register,Word)
        ///
        ///
        /// The stack operand contains a register which is a stack
        /// register, i.e. SP or BP and an offset ( negative or positive )
        /// from that register. This operand can be used to access LOCALs
        /// or PARAMETERS on the stack as well as other ALLOCED objects.
        ///
        ///
        case stack(Register,Argon.Integer)
        ///
        ///
        /// A label contains an offset negative or positive that is
        /// used as an offset in a branch instruction. A label must
        /// always be stored in a result result slot of an instruction.
        ///
        /// 
        case label(Argon.Integer)
        
        init(label: Int)
            {
            self = .label(Argon.Integer(label))
            }
            
        init(integer: Int)
            {
            self = .integer(Argon.Integer(integer))
            }
            
        init(stack: Register,_ offset: Int)
            {
            self = .stack(stack,Argon.Integer(offset))
            }
            
        public var isRelocation: Bool
            {
            switch(self)
                {
                case .relocation:
                    return(true)
                default:
                    return(false)
                }
            }
            
        public var relocationTarget: LiteralValue?
            {
            switch(self)
                {
                case .relocation(let literal):
                    return(literal)
                default:
                    return(nil)
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
            
        public var isAbsolute: Bool
            {
            switch(self)
                {
                case .absolute:
                    return(true)
                default:
                    return(false)
                }
            }
            
        public var wordValue:Word
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .relocation:
                    return(0)
                case .register:
                    return(0)
                case .float(let float):
                    return(float.bitPattern)
                case .integer(let integer):
                    return(Word(bitPattern: Int64(integer)))
                case .absolute(let word):
                    return(word)
                case .stack(_,let integer):
                    return(Word(bitPattern: Int64(integer)))
                case .indirect(_,let word):
                    return(word)
                case .label(let integer):
                    return(Word(bitPattern: Int64(integer)))
                }
            }
            
        public var registerValue:Int
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .relocation:
                    return(0)
                case .register(let register):
                    return(register.rawValue)
                case .float:
                    return(0)
                case .integer:
                    return(0)
                case .absolute:
                    return(0)
                case .stack(let register,_):
                    return(register.rawValue)
                case .indirect(let register,_):
                    return(register.rawValue)
                case .label:
                    return(0)
                }
            }
            
        public var rawValue:Int
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .register:
                    return(1)
                case .float:
                    return(3)
                case .integer:
                    return(4)
                case .absolute:
                    return(5)
                case .stack:
                    return(6)
                case .indirect:
                    return(7)
                case .label:
                    return(8)
                case .relocation:
                    return(9)
                }
            }
            
    public var address: Word
        {
        switch(self)
            {
            case .absolute(let word):
                return(word)
            default:
                fatalError("Error")
            }
        }
            
        public var text: String
            {
            switch(self)
                {
                case .none:
                    return("")
                case .register(let register):
                    return(register.displayString)
                case .float(let float):
                    return("\(float)")
                case .integer(let register):
                    return("\(register)")
                case .absolute(let register):
                    return("0x\(register.addressString)")
                case .stack(let register,let offset):
                    let signed = offset < 0 ? "\(offset)" : "+\(offset)"
                    return("SS:[\(register.displayString)\(signed)]")
                case .indirect(let register,let offset):
                    return("[\(register.displayString)+\(offset)]")
                case .label(let integer):
                    let label = integer >= 0 ? "+" : ""
                    return("IP \(label) \(integer)")
                case .relocation(let value):
                    return("REL \(value)")
                }
            }
            
        public func floatValue(in vm: VirtualMachine) throws -> Argon.Float
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .relocation:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .register(let register):
                    if !register.isFloatingPoint
                        {
                        throw(ExecutionErrorType.invalidRegister)
                        }
                    return(Argon.Float(bitPattern: vm.registers[register.rawValue].withoutTag))
                case .float(let float):
                    return(float)
                case .integer:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .absolute:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .stack(let register,let offset):
                    let registerValue = Int64(vm.register(atIndex: register))
                    let actualOffset = Word(registerValue + offset)
                    return(FloatAtAddressAtOffset(vm.stackSegment.baseAddress,actualOffset))
                case .indirect(let object,let offset):
                    let value = vm.registers[object.rawValue]
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value + offset))
                    return(Argon.Float(bitPattern: pointer?.pointee.withoutTag ?? 0))
                case .label:
                    return(0)
                }
            }
            
        public func wordValue(in vm: VirtualMachine) throws -> Word
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .relocation:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .register(let register):
                    return(vm.registers[register.rawValue].withoutTag)
                case .float:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .integer(let integer):
                    return(Word(bitPattern: integer))
                case .absolute(let word1):
                    return(word1)
                case .stack(let register,let offset):
                    let registerValue = Int64(vm.register(atIndex: register))
                    let actualOffset = Word(registerValue + offset)
                    return(WordAtAddressAtOffset(vm.stackSegment.baseAddress,actualOffset))
                case .indirect(let object,let offset):
                    let value = vm.registers[object.rawValue]
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value + offset))
                    return(pointer?.pointee.withoutTag ?? 0)
                case .label(let integer):
                    return(Word(bitPattern: integer))

                }
            }
            
        public func value(in vm: VirtualMachine) throws -> Word
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .relocation:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .register(let register):
                    return(vm.registers[register.rawValue].withoutTag)
                case .float(let float):
                    return(float.bitPattern.tagged(with:.float))
                case .integer(let integer):
                    return(Word(bitPattern: integer))
                case .absolute(let word1):
                    return(word1)
                case .stack(let register,let offset):
                    let registerValue = Int64(vm.register(atIndex: register))
                    let actualOffset = Word(registerValue + offset)
                    return(WordAtAddressAtOffset(vm.stackSegment.baseAddress,actualOffset))
                case .indirect(let object,let offset):
                    let value = vm.registers[object.rawValue]
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value + offset))
                    return(pointer?.pointee.withoutTag ?? 0)
                case .label(let integer):
                    return(Word(bitPattern: integer))
                }
            }
            
        public func intValue(in vm: VirtualMachine) throws -> Argon.Integer
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .relocation:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .register(let register):
                    return(Int64(bitPattern: UInt64(vm.registers[register.rawValue])))
                case .float:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .integer(let integer):
                    return(Int64(integer))
                case .absolute(let word1):
                    return(Int64(word1))
                case .stack(let register,let offset):
                    let registerValue = Int64(vm.register(atIndex: register))
                    let actualOffset = Word(registerValue + offset)
                    return(IntegerAtAddressAtOffset(vm.stackSegment.baseAddress,actualOffset))
                case .indirect(let object,let offset):
                    let value = vm.registers[object.rawValue]
                    let pointer = UnsafePointer<Int64>(bitPattern: UInt(value + offset))
                    return(pointer?.pointee ?? 0)
                case .label(let integer):
                    return(Argon.Integer(integer))
                }
            }
            
        public func setIntValue(_ value:Int64,in vm: VirtualMachine) throws
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .relocation:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .register(let register):
                    vm.registers[register.rawValue] = UInt64(bitPattern: value)
                case .float:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .integer:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .absolute:
                    break
                case .stack(let register,let offset):
                    let registerValue = Int64(vm.register(atIndex: register))
                    let actualOffset = Word(registerValue + offset)
                    return(SetIntegerAtAddressAtOffset(value,vm.stackSegment.baseAddress,actualOffset))
                case .indirect(let object,let offset):
                    let inner = vm.registers[object.rawValue]
                    let pointer = UnsafeMutablePointer<Int64>(bitPattern: UInt(inner + offset))
                    pointer?.pointee = value
                case .label:
                    break
                }
            }
            
        public func setValue(_ value:Word,in vm: VirtualMachine) throws
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .relocation:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .register(let register):
                    vm.setRegister(value,atIndex: register)
                case .float:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .integer:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .absolute:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .stack(let register,let offset):
                    let registerValue = Int64(vm.register(atIndex: register))
                    let actualOffset = Word(registerValue + offset)
                    return(SetWordAtAddressAtOffset(value,vm.stackSegment.baseAddress,actualOffset))
                case .indirect(let object,let offset):
                    let inner = vm.registers[object.rawValue]
                    let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(inner + offset))
                    pointer?.pointee = value
                case .label:
                    break
                }
            }
            
        public func setFloatValue(_ value:Argon.Float,in vm: VirtualMachine) throws
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .relocation:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .register(let register):
                    if !register.isFloatingPoint
                        {
                        throw(ExecutionErrorType.invalidFloatOperand)
                        }
                    vm.registers[register.rawValue] = value.bitPattern
                case .float:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .integer:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .absolute:
                    break
                case .stack(let register,let offset):
                    let registerValue = Int64(vm.register(atIndex: register))
                    let actualOffset = Word(registerValue + offset)
                    return(SetFloatAtAddressAtOffset(value,vm.stackSegment.baseAddress,actualOffset))
                case .indirect(let object,let offset):
                    let inner = vm.registers[object.rawValue]
                    let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(inner + offset))
                    pointer?.pointee = value.bitPattern.tagged(with: .float)
                case .label:
                    break
                }
            }
        }

    public var displayString: String
        {
        return("\(self.opcode.displayString) \(self.operandText)")
        }
        
    public var operandText: String
        {
        var text = Array<String>()
        if self.operand1.isNotNone
            {
            text.append(self.operand1.text)
            }
        if self.operand2.isNotNone
            {
            text.append(self.operand2.text)
            }
        if self.result.isNotNone
            {
            text.append(self.result.text)
            }
        return(text.joined(separator: ","))
        }
        
    public var id:Int
        {
        return(self.lineNumber)
        }
        
    public var opcode:Opcode
    public var operand1:Operand
    public var operand2:Operand
    public var result:Operand
    public var lineNumber:Int
    
    public init(_ opcode:Opcode,operand1:Operand = .none,operand2:Operand = .none,result:Operand = .none,lineNumber:Int = 0)
        {
        self.opcode = opcode
        self.operand1 = operand1
        self.operand2 = operand2
        self.result = result
        self.lineNumber = lineNumber
        }

    public init(from pointer:WordPointer)
        {
        self.opcode = .NOP
        self.operand1 = .none
        self.operand2 = .none
        self.result = .none
        
        var words = Array<Word>()
        words.append(pointer[0])
        words.append(pointer[1])
        words.append(pointer[2])
        words.append(pointer[3])
        self.opcode = Self.opcodeField.value(in: words[0])
        self.operand1 = Self.operand(kindField: Self.operand1KindField, registerField: Self.operand1RegisterField,index: 1,words: words)
        self.operand2 = Self.operand(kindField: Self.operand2KindField, registerField: Self.operand2RegisterField,index: 2,words: words)
        self.result = Self.operand(kindField: Self.resultKindField, registerField: Self.resultRegisterField,index: 3,words: words)
        self.lineNumber = Int(Self.lineNumberField.value(in: words[0]))
        }
        
    public init?(coder: NSCoder)
        {
        self.opcode = Opcode(rawValue: coder.decodeInteger(forKey: "opcode"))!
        self.operand1 = coder.decodeOperand(forKey: "operand1")!
        self.operand2 = coder.decodeOperand(forKey: "operand2")!
        self.result = coder.decodeOperand(forKey: "result")!
        self.lineNumber = coder.decodeInteger(forKey: "lineNumber")
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.opcode.rawValue,forKey: "opcode")
        coder.encode(self.operand1,forKey: "operand1")
        coder.encode(self.operand2,forKey: "operand2")
        coder.encode(self.result,forKey: "result")
        coder.encode(self.lineNumber,forKey: "lineNumber")
        }
        
    private static func operand(kindField: PackedField<Word>,registerField: PackedField<Register>,index:Int,words:[Word]) -> Operand
        {
        let kind = kindField.value(in: words[0])
        let register = registerField.value(in: words[0])
        switch(kind)
            {
            case 0:
                return(.none)
            case 1:
                return(.register(register))
            case 3:
                return(.float(Argon.Float(bitPattern: words[index])))
            case 4:
                return(.integer(Argon.Integer(bitPattern: words[index])))
            case 5:
                return(.absolute(words[index]))
            case 6:
                return(.stack(register,Argon.Integer(bitPattern: words[index])))
            case 7:
                return(.indirect(register,words[index]))
            case 8:
                return(.label(Argon.Integer(bitPattern: words[index])))
            default:
                fatalError("Invalid kind received")
            }
        }
        
    public func write(to pointer:WordPointer)
        {
        var word:Word = 0
        
        Self.opcodeField.setValue(self.opcode,in: &word)
        Self.operand1KindField.setValue(Word(self.operand1.rawValue),in: &word)
        Self.operand1RegisterField.setValue(Word(self.operand1.registerValue),in: &word)
        Self.operand2KindField.setValue(Word(self.operand2.rawValue),in: &word)
        Self.operand2RegisterField.setValue(Word(self.operand2.registerValue),in: &word)
        Self.resultKindField.setValue(Word(self.result.rawValue),in: &word)
        Self.resultRegisterField.setValue(Word(self.result.registerValue),in: &word)
        Self.lineNumberField.setValue(Word(self.lineNumber),in: &word)
        pointer[0] = word
        pointer[1] = self.operand1.wordValue
        pointer[2] = self.operand2.wordValue
        pointer[3] = self.result.wordValue
        }
        
    public func execute(in vm: VirtualMachine) throws
        {
        switch(self.opcode)
            {
            ///
            ///
            /// INTEGER ARITHMETIC OPERATIIONS
            ///
            ///
            case .NOP:
                break
            case .IADD:
                try self.result.setIntValue(self.operand1.intValue(in: vm) + self.operand2.intValue(in: vm),in: vm)
            case .ISUB:
                try self.result.setIntValue(self.operand1.intValue(in: vm) - self.operand2.intValue(in: vm),in: vm)
            case .IMUL:
                try self.result.setIntValue(self.operand1.intValue(in: vm) * self.operand2.intValue(in: vm),in: vm)
            case .IDIV:
                try self.result.setIntValue(self.operand1.intValue(in: vm) / self.operand2.intValue(in: vm),in: vm)
            case .IMOD:
                try self.result.setIntValue(self.operand1.intValue(in: vm) % self.operand2.intValue(in: vm),in: vm)
            case .LOAD:
                try self.result.setValue(self.operand1.value(in: vm),in: vm)
            case .STORE:
                try self.result.setValue(self.operand1.value(in: vm),in: vm)
            case .IPOW:
                var value = try self.operand1.intValue(in: vm)
                let mul = value
                var power = try self.operand2.intValue(in: vm)
                while power > 0
                    {
                    value *= mul
                    power -= 1
                    }
                try self.result.setIntValue(value,in: vm)
            ///
            ///
            /// FLOATING POINT ARITHMETIC
            ///
            ///
            case .FADD:
                try self.result.setFloatValue(self.operand1.floatValue(in: vm) + self.operand2.floatValue(in: vm),in: vm)
            case .FSUB:
                try self.result.setFloatValue(self.operand1.floatValue(in: vm) - self.operand2.floatValue(in: vm),in: vm)
            case .FMUL:
                try self.result.setFloatValue(self.operand1.floatValue(in: vm) * self.operand2.floatValue(in: vm),in: vm)
            case .FDIV:
                try self.result.setFloatValue(self.operand1.floatValue(in: vm) / self.operand2.floatValue(in: vm),in: vm)
            case .FMOD:
            try self.result.setFloatValue(self.operand1.floatValue(in: vm).truncatingRemainder(dividingBy: self.operand2.floatValue(in: vm)),in: vm)
            case .FPOW:
                try self.result.setFloatValue(pow(self.operand1.floatValue(in: vm),self.operand2.floatValue(in: vm)),in: vm)
            ///
            ///
            /// MAKE AN OBJECT FROM A CLASS
            ///
            ///
            case .MAKE:
                    break
//                let targetClassPointer = InnerClassPointer(address: self.operand1.address)
//                let extraBytes = try self.operand2.intValue(in: vm)
//                let address = vm.managedSegment.allocateObject(sizeInBytes: targetClassPointer.sizeInBytes + Int(extraBytes))
//                let pointer = InnerInstancePointer(address: address)
//                pointer.classPointer = targetClassPointer
//                pointer.magicNumber = targetClassPointer.magicNumber
//                try self.result.setValue(pointer.address,in:context)
            ///
            ///
            /// PUSH AND POP ITEMS ONTO/OFF THE STACK
            ///
            ///
            case .PUSH:
                vm.stackSegment.push(try self.operand1.value(in: vm))
            case .POP:
                try self.result.setValue(vm.stackSegment.pop(),in: vm)
            case .ENTER:
                break
            case .LEAVE:
                break
            case .SAVE:
                contextStack.push(vm.registers)
            case .REST:
                vm.registers = contextStack.pop()
            case .LOOPEQ:
                let value = try self.operand1.value(in: vm)
                if value == 1
                    {
                    let offset = try self.operand2.intValue(in: vm)
                    vm.ip = vm.ip + Int(offset)
                    }
            case .INC:
                try  self.result.setIntValue(self.result.intValue(in: vm) + 1,in: vm)
            case .DEC:
                try  self.result.setIntValue(self.result.intValue(in: vm) - 1,in: vm)
            ///
            ///
            /// CONCATENATE TWO STRINS
            ///
            ///
            case .SCAT:
                let address1 = try self.operand1.value(in: vm)
                let address2 = try self.operand2.value(in: vm)
                let pointer1 = InnerStringPointer(address: address1)
                let pointer2 = InnerStringPointer(address: address2)
                let string1 = pointer1.string
                let string2 = pointer2.string
                let newPointer = InnerStringPointer.allocateString(string1+string2, in: vm)
                try self.result.setValue(newPointer.address,in: vm)
            ///
            ///
            /// COPY STRING1 INTO STRING2
            ///
            ///
            case .SCPY:
                let address1 = try self.operand1.value(in: vm)
                let pointer1 = InnerStringPointer(address: address1)
                let string1 = pointer1.string
                let newPointer = InnerStringPointer.allocateString(string1, in: vm)
                try self.result.setValue(newPointer.address,in: vm)
            ///
            ///
            /// COMPARE TWO STRINGS AND PUT THE RESULT OF THE COMPARISON INTO THE RESULT
            ///
            ///
            case .SCMP:
                let address1 = try self.operand1.value(in: vm)
                let string1 = InnerStringPointer(address: address1).string
                let address2 = try self.operand2.value(in: vm)
                let string2 = InnerStringPointer(address: address2).string
                let result = string1.compare(string2)
                try self.result.setIntValue(Int64(result.rawValue),in: vm)
            ///
            ///
            /// ESTABLISH A HANDLER ON THE STACK, THE EP REGISTER POINTS TO
            /// THE TOP CURRENTLY ACTIVE HANDLER. PUSH THE NEW ONE ON AND
            /// SET EP UP TO POINT TO THE NEW ONE
            ///
            ///
            case .HAND:
                let current = vm.registers[Instruction.Register.EP.rawValue]
                vm.stackSegment.push(current)
                vm.stackSegment.push(try self.operand1.value(in: vm))
                vm.stackSegment.push(try self.operand2.value(in: vm))
                vm.registers[Instruction.Register.EP.rawValue] = vm.stackSegment.stackPointer
            case .REIN:
                break
            case .ZERO:
                try self.result.setValue(0,in: vm)
            default:
                fatalError("Unhandled instruction opcode \(self.opcode)")
            }
        }

    private func encodeNilable<T>(_ value:T?,in encoder:BitEncoder)
        {
        if value.isNil
            {
            encoder.encode(value: 0,inWidth:1)
            }
        else
            {
            encoder.encode(value: 1,inWidth:2)
            }
        }
    }

