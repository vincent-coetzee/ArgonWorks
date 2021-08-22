//
//  InnerInstruction.swift
//  InnerInstruction
//
//  Created by Vincent Coetzee on 6/8/21.
//

import Foundation

public struct PackedField<T>
    {
    private let shift:Word
    private let width:Word
    private let mask:Word
    private let shiftedMask:Word
    
    init(offset:Int,width:Int)
        {
        self.shift = Word(offset)
        self.width = Word(width)
        self.mask = Word(1) << Word(width)  - 1
        self.shiftedMask = mask << Word(offset)
        }
        
    public func setValue(_ value:Word,in word:inout Word)
        {
        let bits = (value & self.mask) << self.shift
        word |= bits
        }
        
    public func setValue(_ value:T,in word:inout Word) where T:RawRepresentable,T.RawValue == Int
        {
        self.setValue(Word(value.rawValue),in:&word)
        }
        
    public func value(in word:Word) -> T where T:RawRepresentable,T.RawValue == Int
        {
        return(T(rawValue: Int(self.value(in: word)))!)
        }
        
    public func value(in word:Word) -> Word
        {
        return((word & self.shiftedMask) >> self.shift)
        }
    }

