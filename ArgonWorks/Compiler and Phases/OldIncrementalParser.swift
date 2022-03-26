//
//  IncrementalParser.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/3/22.
//

import Foundation

public enum SymbolValue
    {
    case nothing
    case `class`(TypeClass)
    case module(Module)
    case enumeration(TypeEnumeration,MethodInstance,MethodInstance)
    case moduleSlot(Slot)
    case typeAlias(TypeAlias)
    case primitive(MethodInstance)
    case methodInstance(MethodInstance)
    }
    
public class OldIncrementalParser: Parser
    {

    }
