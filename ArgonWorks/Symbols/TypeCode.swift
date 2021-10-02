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
    case float = 3
    case character = 4
    case boolean = 5
    case byte = 6
    case string = 7
    case symbol = 8
    case enumeration = 9
    case method = 10
    case methodInstance = 11
    case function = 12
    case `class` = 13
    case slot = 14
    case tuple = 15
    case type = 16
    case array = 17
    case void = 18
    case stream = 19
    case metaclass = 20
    case module = 21
    case pointer = 22
    case other = 23
    case mutableString = 24
    case constant = 25
    case enumerationCase = 26
    case initializer = 27
    case localSlot = 28
    case argonModule = 29
    case topModule = 30
    case libraryModule = 31
    case systemModule = 32
    case mainModule = 33
    case parameter = 34
    case virtualSlot = 35
    case typeAlias = 36
    case interceptor = 37
    case block = 38
    case closure = 39
    case byteArray = 40
    case instruction = 41
    case instructionArray = 42
    case dictionary = 43
    case dictionaryBucket = 44
    case date = 45
    case time = 46
    case dateTime = 47
    }
