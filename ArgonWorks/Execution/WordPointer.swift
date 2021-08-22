//
//  WordPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

public typealias WordPointer = UnsafeMutablePointer<Word>

extension WordPointer
    {
    public var address: Word
        {
        Word(bitPattern: Int(bitPattern: self))
        }
        
    public var header:Header
        {
        get
            {
            return(Header(self[0]))
            }
        set
            {
            self[0] = newValue
            }
        }
        
    public var classPointer:Word
        {
        get
            {
            return(self[1])
            }
        set
            {
            self[1] = newValue
            }
        }
        
    public var hash:Int
        {
        get
            {
            Int(bitPattern: UInt(self[2]))
            }
        set
            {
            self[2] = Word(bitPattern: Int64(newValue))
            }
        }
        
    init?(address:Int)
        {
        self.init(bitPattern: address)
        }
        
    init?(address:Word)
        {
        self.init(bitPattern: UInt(address))
        }
        
    public func word(atByteOffset:Int) -> Word
        {
        let offset = atByteOffset / 8
        return(self[offset])
        }
    }
