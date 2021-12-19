//
//  WordPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public typealias WordPointer = UnsafeMutablePointer<Word>

extension WordPointer
    {
    public subscript(_ index: Word) -> Word
        {
        get
            {
            return(self[Int(index)])
            }
        set
            {
            self[Int(index)] = newValue
            }
        }
        
    public func display(indent: String,count: Int)
        {
        for index in 0..<count
            {
            let address = Int(bitPattern: self) + index
            let addressString = String(format: "%010X",address)
            let value:Word = self[index]
            let valueHexString = String(format: "%010X",value)
            let valueString = String(format: "% 10d",value)
            let bitString = value.bitString
            print("[\(addressString)] \(valueHexString) \(valueString) \(bitString)")
            }
        }
        
    public func header(atIndex: Int) -> Header
        {
        let headerAddress = UInt(bitPattern: self) + UInt(atIndex * Argon.kWordSizeInBytesInt)
        return(Header(atAddress: Word(headerAddress)))
        }
    }
    
