//
//  StringPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public class StringPointer: ObjectPointer
    {
    public static func ==(lhs: StringPointer,rhs: String) -> Bool
        {
        return(lhs.string == rhs)
        }
        
    public override class func sizeInBytes() -> Int
        {
        64
        }
        
    public var count: Int
        {
        get
            {
            let count = Int(self.wordPointer[7])
            return(count)
            }
        set
            {
            self.wordPointer[7] = Word(newValue)
            }
        }
        
    public var string: String
        {
        get
            {
            return(self.loadString())
            }
        set
            {
            self.storeString(newValue)
            }
        }
        
    internal func storeString(_ string: String)
        {
        let sizeInBytes = Self.sizeInBytes()
        let bytesAddress = self._cleanAddress + Word(sizeInBytes)
        self.count = string.utf16.count
        let charPointer = UInt16Pointer(bitPattern: bytesAddress)
        var offset = 0
        for character in string.utf16
            {
            if offset % 4 == 3
                {
                charPointer[offset] = 0
                offset += 1
                charPointer[offset] = character
                }
            else
                {
                charPointer[offset] = character
                }
            offset += 1
            }
        charPointer[offset] = 0
        self.setWord(Word(integer: string.polynomialRollingHash),atIndex: 6)
        }
        
    internal func loadString() -> String
        {
        let sizeInBytes = Self.sizeInBytes()
        let bytesAddress = self._cleanAddress + Word(sizeInBytes)
        let charPointer = UInt16Pointer(bitPattern: bytesAddress)
        var offset = 0
        var number = 0
        var array = Array<UTF16.CodeUnit>()
        let theCount = self.count
        while number < theCount
            {
            if offset % 4 != 3
                {
                array.append(charPointer[offset])
                number += 1
                }
            offset += 1
            }
        let string = String(utf16CodeUnits: array,count: array.count)
        return(string)
        }
    }

