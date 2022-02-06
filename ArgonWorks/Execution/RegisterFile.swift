//
//  RegisterFile.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/1/22.
//

import Foundation

public class RegisterFile
    {
    private static let kFirstIntegerIndex:Word = 20
    private static let kLastIntegerIndex: Word = 83
    private static let kFirstFloatIndex:Word = 100
    private static let kLastFloatIndex: Word = 163
    private static let kFirstStringIndex:Word = 164
    private static let kLastStringIndex: Word = 183
    
    private var integerRegisters = Array<Register>()
    private var floatingPointRegisters = Array<Register>()
    private var stringRegisters = Array<Register>()
    
    private var freeIntegerRegisters = Array<Register>()
    private var freeFloatingPointRegisters = Array<Register>()
    private var freeStringRegisters = Array<Register>()
    
    init()
        {
        for registerIndex in Self.kFirstIntegerIndex...Self.kLastIntegerIndex
            {
            self.integerRegisters.append(Register(index: RegisterIndex(rawValue: registerIndex)!,word: Word(registerIndex)))
            }
        for registerIndex in Self.kFirstFloatIndex...Self.kLastFloatIndex
            {
            self.floatingPointRegisters.append(Register(index: RegisterIndex(rawValue: registerIndex)!,word: Word(registerIndex)))
            }
        for registerIndex in Self.kFirstStringIndex...Self.kLastStringIndex
            {
            self.stringRegisters.append(Register(index: RegisterIndex(rawValue: registerIndex)!,word: Word(registerIndex)))
            }
        self.resetRegisters()
        for register in self.integerRegisters
            {
            register.registerFile = self
            }
        for register in self.floatingPointRegisters
            {
            register.registerFile = self
            }
        for register in self.stringRegisters
            {
            register.registerFile = self
            }
        }
        
    public func resetRegisters()
        {
        for register in self.integerRegisters
            {
            register.contents = .none
            }
        for register in self.floatingPointRegisters
            {
            register.contents = .none
            }
        for register in self.stringRegisters
            {
            register.contents = .none
            }
        self.freeIntegerRegisters = self.integerRegisters
        self.freeFloatingPointRegisters = self.floatingPointRegisters
        self.freeStringRegisters = self.stringRegisters
        }
        
    public func allocateIntegerRegister() -> Register
        {
        if !self.freeIntegerRegisters.isEmpty
            {
            let register = self.freeIntegerRegisters.first!
            self.freeIntegerRegisters.remove(register)
            register.isLocked = true
            return(register)
            }
        var count = 0
        repeat
            {
            let index = Int.random(in: 0..<self.integerRegisters.count)
            let selected = self.integerRegisters[index]
            if !selected.isLocked
                {
                self.spillRegister(selected)
                return(selected)
                }
            count += 1
            }
        while count < 20
        fatalError("Unabled to allocate register.")
        }
        
    public func allocateFloatRegister() -> Register
        {
        if !self.freeFloatingPointRegisters.isEmpty
            {
            let register = self.freeIntegerRegisters.first!
            self.freeFloatingPointRegisters.remove(register)
            register.isLocked = true
            return(register)
            }
        var count = 0
        repeat
            {
            let index = Int.random(in: 0..<self.floatingPointRegisters.count)
            let selected = self.floatingPointRegisters[index]
            if !selected.isLocked
                {
                self.spillRegister(selected)
                return(selected)
                }
            count += 1
            }
        while count < 20
        fatalError("Unabled to allocate register.")
        }
        
    public func allocateStringRegister() -> Register
        {
        if !self.freeStringRegisters.isEmpty
            {
            let register = self.freeStringRegisters.first!
            self.freeStringRegisters.remove(register)
            register.isLocked = true
            return(register)
            }
        var count = 0
        repeat
            {
            let index = Int.random(in: 0..<self.stringRegisters.count)
            let selected = self.stringRegisters[index]
            if !selected.isLocked
                {
                self.spillRegister(selected)
                return(selected)
                }
            count += 1
            }
        while count < 20
        fatalError("Unabled to allocate register.")
        }
        
    public func deallocateRegister(_ register: Register)
        {
        register.contents = .none
        register.isLocked = false
        if register.isIntegerRegister
            {
            self.freeIntegerRegisters.append(register)
            }
        else if register.isFloatingPointRegister
            {
            self.freeFloatingPointRegisters.append(register)
            }
        else if register.isStringRegister
            {
            self.freeStringRegisters.append(register)
            }
        }
        
    private func spillRegister(_ register: Register)
        {
        register.contents = .none
        register.isLocked = false
        }
    }

extension Array where Element:Equatable
    {
    public mutating func remove(_ element: Element)
        {
        self.removeAll(where: {$0 == element})
        }
    }
