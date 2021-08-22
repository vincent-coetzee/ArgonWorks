//
//  ExecutionContext.swift
//  ExecutionContext
//
//  Created by Vincent Coetzee on 1/8/21.
//

import Foundation
//
//fileprivate func max(_ array:Array<Int>) -> Int
//    {
//    var theMax = array.first!
//    for element in array
//        {
//        theMax = max(theMax,element)
//        }
//    return(theMax)
//    }
//    
//public class ExecutionContext:ObservableObject
//    {
//    @Published internal var registers = Array<Word>(repeating: 0, count: max(Instruction.Register.allCases.map{$0.rawValue}) + 1)
//    @Published private var _allRegisters = Instruction.Register.allCases
//    @Published var changedRegisters = Set<Instruction.Register>()
//    
//    private var instructionCache = Array<Instruction>()
//    public var managedSegment: Segment = VirtualMachine.shared.managedSegment
//    public var stackSegment: StackSegment
//    
//    public func register(atIndex:Instruction.Register) -> Word
//        {
//        return(self.registers[atIndex.rawValue])
//        }
//        
//    public func setRegister(_ word:Word,atIndex:Instruction.Register) 
//        {
//        self.changedRegisters = Set()
//        self.registers[atIndex.rawValue] = word
//        self.changedRegisters.insert(atIndex)
//        }
//        
//    public var bp:Word
//        {
//        get
//            {
//            return(self.registers[Instruction.Register.bp.rawValue])
//            }
//        set
//            {
//            self.registers[Instruction.Register.bp.rawValue] = newValue
//            }
//        }
//        
//    public var ip:Int
//        {
//        get
//            {
//            return(Int(self.registers[Instruction.Register.ip.rawValue]))
//            }
//        set
//            {
//            self.registers[Instruction.Register.ip.rawValue] = Word(bitPattern: newValue)
//            }
//        }
//
//    public init()
//        {
//        self.stackSegment = StackSegment(size: .bytes(1024 * 1024 * 10))
//        }
//
//    public func update()
//        {
//        for index in 0..<registers.count
//            {
//            self.registers[index] *= 1
//            }
//        }
//        
//    public var allRegisters: Array<Instruction.Register>
//        {
//        return(self._allRegisters)
//        }
//        
//    public subscript(_ index:Instruction.Register) -> Word
//        {
//        return(self.registers[index.rawValue])
//        }
//        
//    public func call(address:Word)
//        {
//        let pointer = InnerPackedInstructionArrayPointer(address: address)
//        self.setRegister(0, atIndex: .ip)
//        for index in 0..<pointer.count
//            {
//            self.instructionCache.append(pointer[index])
//            }
//        }
//        
////    public func singleStep() throws
////        {
////        let ip = self.registers[Instruction.Register.ip.rawValue]
////        try self.instructionCache[Int(ip)].execute(in: self)
////        self.registers[Instruction.Register.ip.rawValue] = ip + 1
////        }
//    }
