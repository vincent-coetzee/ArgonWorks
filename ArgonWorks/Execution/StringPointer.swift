//
//  StringPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public class StringPointer: ClassBasedPointer
    {
    public static func ==(lhs: StringPointer,rhs: String) -> Bool
        {
        return(lhs.string == rhs)
        }
        
    public class func sizeInBytes() -> Int
        {
        (ArgonModule.shared.string as! TypeClass).instanceSizeInBytes
        }
        
    public var count: Int
        {
        get
            {
            self.integer(atSlot: "count")
            }
        set
            {
            self.setInteger(newValue,atSlot: "count")
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
        
    public init(address: Address)
        {
        super.init(address: address,class: ArgonModule.shared.string as! TypeClass)
        }
        
    internal func storeString(_ string: String)
        {
        let bytesAddress = self.address(atSlot: "block").cleanAddress + Word(ArgonModule.shared.block.instanceSizeInBytes)
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
        self.setWord(Word(integer: string.polynomialRollingHash),atSlot: "hash")
        }
        
    internal func loadString() -> String
        {
        let bytesAddress = self.address(atSlot: "block")! + Word(ArgonModule.shared.block.instanceSizeInBytes)
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
        
    public static func test(inSegment segment: Segment)
        {
        let string = "This is a test string which has a few number of characters in it."
        let stringAddress = segment.allocateString(string)
        let stringPointer = StringPointer(address: stringAddress)
        let count = string.count
        assert(stringPointer.count == count)
        assert(stringPointer.string == string)
        }
    }

