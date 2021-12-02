//
//  VirtualMachine.swift
//  VirtualMachine
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class VirtualMachine
    {
    public static let tiny = VirtualMachine(tiny: true)
    public static let small = VirtualMachine(small: true)
    public static let standard = VirtualMachine()
    
    private static let kStandardStackSegmentSize = MemorySize.bytes(10 * 1024 * 1024)
    private static let kStandardStaticSegmentSize = MemorySize.bytes(20 * 1024 * 1024)
    private static let kStandardDataSegmentSize = MemorySize.bytes(40 * 1024 * 1024)
    private static let kStandardManagedSegmentSize = MemorySize.bytes(150 * 1024 * 1024)
    
    private static let kSmallStackSegmentSize = MemorySize.bytes(5 * 1024 * 1024)
    private static let kSmallStaticSegmentSize = MemorySize.bytes(10 * 1024 * 1024)
    private static let kSmallDataSegmentSize = MemorySize.bytes(10 * 1024 * 1024)
    private static let kSmallManagedSegmentSize = MemorySize.bytes(20 * 1024 * 1024)
    
    private static let kTinyStackSegmentSize = MemorySize.bytes(1 * 1024 * 1024)
    private static let kTinyStaticSegmentSize = MemorySize.bytes(2 * 1024 * 1024)
    private static let kTinyDataSegmentSize = MemorySize.bytes(2 * 1024 * 1024)
    private static let kTinyManagedSegmentSize = MemorySize.bytes(5 * 1024 * 1024)
    
    public private(set) var managedSegment = ManagedSegment(size: MemorySize.bytes(100))
    public private(set) var stackSegment = StackSegment(size: MemorySize.bytes(10))
    public private(set) var dataSegment = DataSegment(size: MemorySize.bytes(10))
    public private(set) var staticSegment = StaticSegment(size: MemorySize.bytes(10))
    
//    public var registers: Array<Word> = Array(repeating: 0, count: Instruction.Register.allCases.count + 1)
    public var topModule: TopModule
        {
        fatalError()
        }
        
    public let pageServer: PageServer!
    public var symbolTable: SymbolTable!
    public let index = UUID()
    
    public var argonModule: ArgonModule
        {
        fatalError()
        }
        
    public var ip: Int = 0
//        {
//        get
//            {
//            return(Int(bitPattern: UInt(self.registers[Instruction.Register.IP.rawValue])))
//            }
//        set
//            {
//            self.registers[Instruction.Register.IP.rawValue] = Word(bitPattern: Int64(newValue))
//            }
//        }
        
    private init()
        {
        self.pageServer = nil
        self.symbolTable = nil
        self.managedSegment = ManagedSegment(size: Self.kStandardManagedSegmentSize)
        self.staticSegment = StaticSegment(size: Self.kStandardStaticSegmentSize)
        self.stackSegment = StackSegment(size: Self.kStandardStackSegmentSize)
        self.dataSegment = DataSegment(size: Self.kStandardDataSegmentSize)
//        self.topModule = TopModule()
        self.managedSegment.virtualMachine = self
        self.stackSegment.virtualMachine = self
        self.staticSegment.virtualMachine = self
        self.dataSegment.virtualMachine = self
        self.symbolTable = SymbolTable(virtualMachine: self)
        }
        
    private init(small:Bool)
        {
        self.pageServer = nil
        self.symbolTable = nil
        self.managedSegment = ManagedSegment(size: Self.kSmallManagedSegmentSize)
        self.staticSegment = StaticSegment(size: Self.kSmallStaticSegmentSize)
        self.stackSegment = StackSegment(size: Self.kSmallStackSegmentSize)
        self.dataSegment = DataSegment(size: Self.kSmallDataSegmentSize)
//        self.topModule = TopModule()
        self.managedSegment.virtualMachine = self
        self.stackSegment.virtualMachine = self
        self.staticSegment.virtualMachine = self
        self.dataSegment.virtualMachine = self
        self.symbolTable = SymbolTable(virtualMachine: self)
        }
        
    private init(tiny:Bool)
        {
        self.pageServer = nil
        self.symbolTable = nil
        self.managedSegment = ManagedSegment(size: Self.kTinyManagedSegmentSize)
        self.staticSegment = StaticSegment(size: Self.kTinyStaticSegmentSize)
        self.stackSegment = StackSegment(size: Self.kTinyStackSegmentSize)
        self.dataSegment = DataSegment(size: Self.kTinyDataSegmentSize)
//        self.topModule = TopModule()
        self.managedSegment.virtualMachine = self
        self.stackSegment.virtualMachine = self
        self.staticSegment.virtualMachine = self
        self.dataSegment.virtualMachine = self
        self.symbolTable = SymbolTable(virtualMachine: self)
        }
        
//    @inlinable
//    public func setValue(_ value:Word,atRegister: Instruction.Register)
//        {
//        self.registers[atRegister.rawValue] = value
//        }
//    
//    @inlinable
//    public func setValue(_ value:Argon.Float,atRegister: Instruction.Register)
//        {
//        self.registers[atRegister.rawValue] = value.bitPattern
//        }
//        
//    @inlinable
//    public func setValue(_ value:Int,atRegister: Instruction.Register)
//        {
//        self.registers[atRegister.rawValue] = Word(bitPattern: Int64(value))
//        }
//        
//    @inlinable
//    public func value(atRegister: Instruction.Register) -> Word
//        {
//        return(self.registers[atRegister.rawValue])
//        }
//    
//    @inlinable
//    public func intValue(atRegister: Instruction.Register) -> Int
//        {
//        return(Int(bitPattern: UInt(self.registers[atRegister.rawValue])))
//        }
//    
//    @inlinable
//    public func floatValue(atRegister: Instruction.Register) -> Argon.Float
//        {
//        return(Argon.Float(bitPattern: self.registers[atRegister.rawValue]))
//        }
//        
//    public func resetVM()
//        {
//        for register in Instruction.Register.allCases
//            {
//            self.registers[register.rawValue] = 0
//            }
//        }
//        
//    public func executeInstruction(_ instruction: Instruction)
//        {
//        }
//        
//    @inlinable
//    public func register(atIndex: Instruction.Register) -> Word
//        {
//        return(self.registers[atIndex.rawValue])
//        }
//        
//    @inlinable
//    public func setRegister(_ word:Word,atIndex: Instruction.Register)
//        {
//        self.registers[atIndex.rawValue] = word
//        }
    }
    
public typealias SymbolHandle = Word

public class SymbolTable
    {
    private static let kSymbolTablePrime = 10007
    
    private var table: Array<String?>
    
    init(virtualMachine: VirtualMachine)
        {
        self.table = Array<String?>(repeating: nil, count: Self.kSymbolTablePrime)
        }
        
    public func registerSymbol(_ string: String) -> Int
        {
        let hash = string.polynomialRollingHash
        let index = hash % Self.kSymbolTablePrime
        if self.table[index].isNotNil
            {
            fatalError("Symbol Table Failure")
            }
        return(index)
        }
    }
