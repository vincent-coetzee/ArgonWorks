//
//  VirtualMachine.swift
//  VirtualMachine
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class VirtualMachine
    {        
    private static let kStandardStackSegmentSize = MemorySize.bytes(10 * 1024 * 1024)
    private static let kStandardStaticSegmentSize = MemorySize.bytes(20 * 1024 * 1024)
    private static let kStandardDataSegmentSize = MemorySize.bytes(40 * 1024 * 1024)
    private static let kStandardManagedSegmentSize = MemorySize.bytes(150 * 1024 * 1024)
    
    private static let kSmallStackSegmentSize = MemorySize.bytes(5 * 1024 * 1024)
    private static let kSmallStaticSegmentSize = MemorySize.bytes(10 * 1024 * 1024)
    private static let kSmallDataSegmentSize = MemorySize.bytes(10 * 1024 * 1024)
    private static let kSmallManagedSegmentSize = MemorySize.bytes(20 * 1024 * 1024)
    
    public private(set) var managedSegment = ManagedSegment(size: MemorySize.bytes(100))
    public private(set) var stackSegment = StackSegment(size: MemorySize.bytes(10))
    public private(set) var dataSegment = DataSegment(size: MemorySize.bytes(10))
    public private(set) var staticSegment = StaticSegment(size: MemorySize.bytes(10))
    
    public var registers: Array<Word> = Array(repeating: 0, count: Instruction.Register.allCases.count + 1)
    public var topModule: TopModule!
    
    public var argonModule: ArgonModule
        {
        self.topModule.argonModule
        }
        
    public var ip: Int
        {
        get
            {
            return(Int(bitPattern: UInt(self.registers[Instruction.Register.ip.rawValue])))
            }
        set
            {
            self.registers[Instruction.Register.ip.rawValue] = Word(bitPattern: Int64(newValue))
            }
        }
        
    init()
        {
        self.managedSegment = ManagedSegment(size: Self.kStandardManagedSegmentSize)
        self.staticSegment = StaticSegment(size: Self.kStandardStaticSegmentSize)
        self.stackSegment = StackSegment(size: Self.kStandardStackSegmentSize)
        self.dataSegment = DataSegment(size: Self.kStandardDataSegmentSize)
        self.topModule = TopModule(virtualMachine: self)
        self.managedSegment.virtualMachine = self
        self.stackSegment.virtualMachine = self
        self.staticSegment.virtualMachine = self
        self.dataSegment.virtualMachine = self
        self.topModule = TopModule(virtualMachine: self)
        self.topModule.argonModule.resolve(in: self)
        }
        
    init(small:Bool)
        {
        self.managedSegment = ManagedSegment(size: Self.kSmallManagedSegmentSize)
        self.staticSegment = StaticSegment(size: Self.kSmallStaticSegmentSize)
        self.stackSegment = StackSegment(size: Self.kSmallStackSegmentSize)
        self.dataSegment = DataSegment(size: Self.kSmallDataSegmentSize)
        self.topModule = TopModule(virtualMachine: self)
        self.managedSegment.virtualMachine = self
        self.stackSegment.virtualMachine = self
        self.staticSegment.virtualMachine = self
        self.dataSegment.virtualMachine = self
        self.topModule = TopModule(virtualMachine: self)
        self.topModule.argonModule.resolve(in: self)
        }
        
    @inlinable
    public func setValue(_ value:Word,atRegister: Instruction.Register)
        {
        self.registers[atRegister.rawValue] = value
        }
    
    @inlinable
    public func setValue(_ value:Argon.Float,atRegister: Instruction.Register)
        {
        self.registers[atRegister.rawValue] = value.bitPattern
        }
        
    @inlinable
    public func setValue(_ value:Int,atRegister: Instruction.Register)
        {
        self.registers[atRegister.rawValue] = Word(bitPattern: Int64(value))
        }
        
    @inlinable
    public func value(atRegister: Instruction.Register) -> Word
        {
        return(self.registers[atRegister.rawValue])
        }
    
    @inlinable
    public func intValue(atRegister: Instruction.Register) -> Int
        {
        return(Int(bitPattern: UInt(self.registers[atRegister.rawValue])))
        }
    
    @inlinable
    public func floatValue(atRegister: Instruction.Register) -> Argon.Float
        {
        return(Argon.Float(bitPattern: self.registers[atRegister.rawValue]))
        }
        
    public func resetVM()
        {
        for register in Instruction.Register.allCases
            {
            self.registers[register.rawValue] = 0
            }
        }
        
    public func executeInstruction(_ instruction: Instruction)
        {
        }
        
    @inlinable
    public func register(atIndex: Instruction.Register) -> Word
        {
        return(self.registers[atIndex.rawValue])
        }
        
    @inlinable
    public func setRegister(_ word:Word,atIndex: Instruction.Register)
        {
        self.registers[atIndex.rawValue] = word
        }
    }
