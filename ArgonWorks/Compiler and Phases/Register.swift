//
//  Register.swift
//  Register
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class Register:Equatable
    {
    public static func ==(lhs:Register,rhs:Register) -> Bool
        {
        return(lhs.register == rhs.register)
        }
        
    private var isEmpty = true
    internal let register: Instruction.Register
    internal var slots: Slots = []
    
    public var contentsAreDuplicatedElsewhere: Bool
        {
        for slot in self.slots
            {
            if slot.addresses.addressCount > 1
                {
                return(true)
                }
            }
        return(false)
        }
        
    init(register:Instruction.Register)
        {
        self.register = register
        }
    }

public class RegisterFile
    {
//    public static let shared = RegisterFile()
//    
    private var file: Array<Register>
    private var available: Array<Register>
    private var unavailable: Array<Register>
    
    init()
        {
        self.unavailable = []
        self.file = []
        self.available = []
        for register in Instruction.Register.generalPurposeRegisters
            {
            self.file.append(Register(register: register))
            }
        self.available = file
        }
        
    public func findRegister(forSlot slot:Slot?,inBuffer: InstructionBuffer) -> Instruction.Register
        {
        if slot.isNotNil
            {
            for register in self.file
                {
                if register.slots.contains(slot!)
                    {
                    return(register.register)
                    }
                }
            }
        if !self.available.isEmpty
            {
            let register = self.available.remove(at: 0)
            self.unavailable.append(register)
            if slot.isNotNil
                {
                register.slots.append(slot!)
                }
            return(register.register)
            }
        for register in self.unavailable
            {
            if register.contentsAreDuplicatedElsewhere
                {
                if slot.isNotNil
                    {
                    register.slots.append(slot!)
                    }
                return(register.register)
                }
            }
        let register = self.unavailable[Int.random(in: 0..<self.unavailable.count)]
        return(self.spillRegister(register, inBuffer: inBuffer))
        }
        
    private func spillRegister(_ register:Register,inBuffer: InstructionBuffer) -> Instruction.Register
        {
        let address = Address.absolute(0)
        for slot in register.slots
            {
            slot.addresses.append(address)
            }
        inBuffer.append(.STORE,.register(register.register),.none,address.operand)
        return(register.register)
        }
    }
