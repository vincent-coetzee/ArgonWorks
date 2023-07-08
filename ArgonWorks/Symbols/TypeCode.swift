//
//  TypeCode.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

public enum TypeCode:Int,Storable
    {
    public func write(output: OutputFile) throws
        {
        try output.write(self)
        }
    
    public var isScalarValue: Bool
        {
        switch(self)
            {
            case .integer:
                fallthrough
            case .uInteger:
                fallthrough
            case .boolean:
                fallthrough
            case .byte:
                fallthrough
            case .character:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isPrimitiveType: Bool
        {
        switch(self)
            {
            case .integer:
                fallthrough
            case .uInteger:
                fallthrough
            case .boolean:
                fallthrough
            case .byte:
                fallthrough
            case .character:
                return(true)
            case .date:
                return(true)
            case .time:
                return(true)
            case .dateTime:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isEnumeratedType: Bool
        {
        switch(self)
            {
            case .enumeration:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isStringType: Bool
        {
        switch(self)
            {
            case .string:
                return(true)
            default:
                return(false)
            }
        }
        
    case none = 0
    case integer = 1
    case uInteger = 2
    case float = 4
    case character = 8
    case boolean = 16
    case byte = 32
    case string = 64
    case symbol = 128
    case enumeration = 256
    case method = 512
    case methodInstance = 1024
    case function = 2048
    case `class` = 4096
    case slot = 8192
    case tuple = 16384
    case type = 32768
    case array = 65536
    case void = 131072
    case stream = 262144
    case metaclass = 524288
    case module = 1048576
    case pointer = 2097152
    case other = 4194304
    case mutableString = 8388608
    case constant = 16777216
    case enumerationCase = 33554432
    case initializer = 67108864
    case localSlot = 134217728
    case argonModule = 268435456
    case topModule = 536870912
    case libraryModule = 1073741824
    case systemModule = 2147483648
    case mainModule = 4294967296
    case parameter = 8589934592
    case virtualSlot = 17179869184
    case typeAlias = 34359738368
    case interceptor = 68719476736
    case block = 137438953472
    case closure = 274877906944
    case byteArray = 549755813888
    case instruction = 1099511627776
    case instructionArray = 2199023255552
    case dictionary = 4398046511104
    case dictionaryBucket = 8796093022208
    case date = 17592186044416
    case time = 35184372088832
    case dateTime = 70368744177664
    }

