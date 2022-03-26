//
//  SpaceTuple.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/3/22.
//

import Foundation

public indirect enum TupleType
    {
    case integer(Argon.Integer)
    case float(Argon.Float)
    case boolean(Argon.Boolean)
    case string(Argon.String)
    case symbol(Argon.Symbol)
    case character(Argon.Character)
    case byte(Argon.Byte)
    case array(Array<TupleType>)
    case object(Word)
    case enumeration(Word)
    case tuple(Tuple)
    }

public typealias TupleTypes = Array<TupleType>

public class Tuple
    {
    public var elements: TupleTypes = []
    
    public init(_ elements: TupleTypes)
        {
        self.elements = elements
        }
        
    public init()
        {
        }
        
    public func append(_ element: TupleType)
        {
        self.elements.append(element)
        }
    }
