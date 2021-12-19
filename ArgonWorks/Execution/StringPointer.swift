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
            let count = Int(self.wordPointer[6])
            return(count)
            }
        set
            {
            self.wordPointer[6] = Word(newValue)
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
        
    private func storeString(_ string: String)
        {
        let sizeInBytes = self.align(Self.sizeInBytes(),to: Self.alignment)
        let bytesOffset = self._cleanAddress + Word(sizeInBytes)
        self.count = string.utf16.count
        let charPointer = UInt16Pointer(bitPattern: bytesOffset)
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
        }
        
    public func loadString() -> String
        {
        let sizeInBytes = self.align(Self.sizeInBytes(),to: Self.alignment)
        let bytesOffset = self._cleanAddress + Word(sizeInBytes)
        let charPointer = UInt16Pointer(bitPattern: bytesOffset)
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

