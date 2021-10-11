//
//  BitEncoder.swift
//  BitEncoder
//
//  Created by Vincent Coetzee on 28/7/21.
//

import Foundation

public protocol BitEncoder
    {
    func encode<T:RawRepresentable>(value:T,inWidth width: Int) where T.RawValue == Int
//    func encode<T:RawConvertible>(value:T,inWidth width:Int)
    func encode(value:Word,inWidth width:Int)
    func encode(extraWord:Word) -> Int
    }
    
extension BitEncoder
    {
    public func encode<T>(value:T,inWidth:Int) where T:RawRepresentable,T.RawValue == Int
        {
        self.encode(value: value.rawValue,inWidth: inWidth)
        }

    public func encode(value:Int,inWidth width:Int)
        {
        self.encode(value: Word(bitPattern: value),inWidth: width)
        }
    }

public protocol BitDecoder
    {
    func shakeAndBake(offset:Word) -> (Word,Word)
    func value(atOffset:Word,inWidth:Word) -> Word
    func value(inWidth:Int) -> Word
    }
    
extension BitDecoder
    {
    public func shakeAndBake(offset:Word) -> (Word,Word)
        {
        let index = offset / 64
        let shift = offset - index * 64
        return(index,shift)
        }
    }
