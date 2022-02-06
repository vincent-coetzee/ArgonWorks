//
//  SymbolFlags.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/1/22.
//

import Foundation

public struct TypeFlags: OptionSet
    {
    public static let kSystemTypeFlag = TypeFlags(rawValue: 1)
    public static let kRootTypeFlag = TypeFlags(rawValue: 1 << 1)
    public static let kPrimitiveTypeFlag = TypeFlags(rawValue: 1 << 2)
    public static let kMetaclassFlag = TypeFlags(rawValue: 1 << 3)
    public static let kArrayTypeFlag = TypeFlags(rawValue: 1 << 4)
    public static let kValueTypeFlag = TypeFlags(rawValue: 1 << 5)
    public static let kArcheTypeFlag = TypeFlags(rawValue: 1 << 6)
    public static let kStringTypeFlag = TypeFlags(rawValue: 1 << 7)
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16)
        {
        self.rawValue = rawValue
        }
    }
