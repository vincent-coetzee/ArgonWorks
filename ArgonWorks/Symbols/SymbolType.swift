//
//  TypeCode.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 6/3/21.
//

import Foundation

public enum SymbolType:Int
    {
    case none = 0
    case module = 1
    case `class` = 2
    case genericParameter = 3
    case function = 4
    case enumeration = 5
    case `import` = 6
    case method = 7
    case methodInstance = 8
    case constant = 9
    case slot = 10
    case localSlot = 11
    case parameter = 12
    case typeAlias = 13
    case library = 14
    case initializer = 15
    case enumerationCase = 16
    case symbol = 17
    case topModule = 18
    case mainModule = 20
    case project = 21
    case group = 22
    }
