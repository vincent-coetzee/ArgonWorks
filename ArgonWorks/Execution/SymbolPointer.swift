//
//  SymbolPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/1/22.
//

import Foundation

public class SymbolPointer: StringPointer
    {
    public static func ==(lhs: SymbolPointer,rhs: String) -> Bool
        {
        return(lhs.string == rhs)
        }
        
    public override class func sizeInBytes(argonModule: ArgonModule) -> Int
        {
        (argonModule.symbol as! TypeClass).instanceSizeInBytes
        }
        
    internal override func storeString(_ string: String)
        {
        let sizeInBytes = Word(Self.sizeInBytes(argonModule: self.argonModule) + 1)
        let bytesAddress = self.someAddress + sizeInBytes
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
        }
        
    internal override func loadString() -> String
        {
        let sizeInBytes = Word(Self.sizeInBytes(argonModule: self.argonModule) + 1)
        let bytesAddress = self.someAddress + sizeInBytes
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
