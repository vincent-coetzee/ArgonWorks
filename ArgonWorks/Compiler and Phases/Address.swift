//
//  Address.swift
//  Address
//
//  Created by Vincent Coetzee on 14/8/21.
//

import Foundation

public enum Address
    {
    case none
    case register(Instruction.Register)
    case absolute(Word)
    case relative(Instruction.Register,Int)
    case stack(Instruction.Register,Int)
    case relocation(Instruction.LiteralValue)
    
    public var absoluteAddress: Word
        {
        return(0)
        }
        
    public var isMemoryAddress: Bool
        {
        switch(self)
            {
            case .absolute:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isRegisterAddress: Bool
        {
        switch(self)
            {
            case .register:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isStackAddress: Bool
        {
        switch(self)
            {
            case .stack:
                return(true)
            default:
                return(false)
            }
        }
        
    public var memoryAddress: Word
        {
        switch(self)
            {
            case .absolute(let word):
                return(word)
            default:
                fatalError("Attempt to access 'address' on a '\(self)'")
            }
        }
        
    public var registerAddress: Instruction.Register
        {
        switch(self)
            {
            case .register(let register):
                return(register)
            default:
                fatalError("Attempt to access 'register' on a '\(self)'")
            }
        }
        
    public var stackAddress: (Instruction.Register,Int)
        {
        switch(self)
            {
            case .stack(let register,let offset):
                return((register,offset))
            default:
                fatalError("Attempt to access 'stack' on a '\(self)'")
            }
        }
        
    public var operand: Instruction.Operand
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .register(let register):
                return(.register(register))
            case .absolute(let address):
                return(.absolute(address))
            case .stack(let register,let offset):
                return(.stack(register,Argon.Integer(offset)))
            case .relative(let register,let offset):
                return(.indirect(register,Word(bitPattern: Argon.Integer(offset))))
            case .relocation(let literal):
                return(.relocation(literal))
            }
        }
        
    public func isSameKind(as address: Address) -> Bool
        {
        switch(self,address)
            {
            case (.none,.none):
                return(true)
            case (.register,.register):
                return(true)
            case (.absolute,.absolute):
                return(true)
            case (.stack,.stack):
                return(true)
            default:
                return(false)
            }
        }
    }
    
public struct Addresses
    {
    public var memoryAddress: Address?
        {
        for descriptor in self.addresses
            {
            if descriptor.isMemoryAddress
                {
                return(descriptor)
                }
            }
        return(nil)
        }
        
    public var stackAddress: Address?
        {
        for descriptor in self.addresses
            {
            if descriptor.isStackAddress
                {
                return(descriptor)
                }
            }
        return(nil)
        }
        
    public var registerAddress: Address?
        {
        for descriptor in self.addresses
            {
            if descriptor.isRegisterAddress
                {
                return(descriptor)
                }
            }
        return(nil)
        }
        
    public var addressCount: Int
        {
        return(self.addresses.count)
        }
        
    public var valueIsDuplicated: Bool
        {
        return(self.addresses.count > 1)
        }
        
    public var mostEfficientAddress: Address
        {
        if self.registerAddress.isNotNil
            {
            return(self.registerAddress!)
            }
        else if self.stackAddress.isNotNil
            {
            return(self.stackAddress!)
            }
        else
            {
            return(self.memoryAddress!)
            }
        }
        
    private var addresses = Array<Address>()
    
    public mutating func append(_ address:Address)
        {
        let count = self.addresses.count
        for index in 0..<count
            {
            let anAddress = self.addresses[index]
            if anAddress.isSameKind(as: address)
                {
                self.addresses.remove(at: index)
                break
                }
            }
        self.addresses.append(address)
        }
    }
    
