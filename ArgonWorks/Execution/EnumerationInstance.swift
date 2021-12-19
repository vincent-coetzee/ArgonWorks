//
//  EnumerationInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/12/21.
//

import Foundation

public class EnumerationInstance
    {
    private static let kPointerShift: Word = 28
    private static let kPointerBits: Word = 0b11111_11111111_11111111_11111111_11111111_11111111
    private static let kPointerBitMask: Word =  EnumerationInstance.kPointerBits << EnumerationInstance.kPointerShift
    private static let kCaseIndexBits: Word = 0b11_11111111
    private static let kCaseIndexBitMask: Word = EnumerationInstance.kCaseIndexBits << EnumerationInstance.kCaseIndexShift
    private static let kCaseIndexShift: Word = 5
    private static let kValueCountBits: Word = 0b11111
    private static let kValueCountBitMask: Word = EnumerationInstance.kValueCountBits <<  EnumerationInstance.kValueCountShift
    private static let kValueCountShift: Word = 0
    
    public var pointer: Address
        {
        get
            {
            return(Address((self.bytes & Self.kPointerBitMask) >> Self.kPointerShift))
            }
        set
            {
            let value = (newValue & Self.kPointerBits) << Self.kPointerShift
            self.bytes = self.bytes | value
            }
        }
        
    public var caseIndex: Int
        {
        get
            {
            return(Int((self.bytes & Self.kCaseIndexBitMask) >> Self.kCaseIndexShift))
            }
        set
            {
            let wordValue = (Word(newValue) & Self.kCaseIndexBits) << Self.kCaseIndexShift
            self.bytes = self.bytes | wordValue
            }
        }
        
    public var valueCount: Int
        {
        get
            {
            return(Int((self.bytes & Self.kValueCountBitMask) >> Self.kCaseIndexShift))
            }
        set
            {
            let wordValue = (Word(newValue) & Self.kValueCountBits) << Self.kValueCountShift
            self.bytes = self.bytes | wordValue
            }
        }
        
    public var bytes: Word
        {
        get
            {
            self.wordPointer.pointee
            }
        set
            {
            self.wordPointer.pointee = newValue
            }
        }
        
    private let wordPointer: UnsafeMutablePointer<Word>
    private let wasAllocated: Bool
    
    init(atAddress: Address)
        {
        self.wordPointer = UnsafeMutablePointer(bitPattern: atAddress.cleanAddress)
        self.wasAllocated = false
        }
        
    init(word: Word)
        {
        self.wordPointer = UnsafeMutablePointer.allocate(capacity: 1)
        self.wordPointer.pointee = word
        self.wasAllocated = true
        }
        
    deinit
        {
        if self.wasAllocated
            {
            self.wordPointer.deallocate()
            }
        }
    }
