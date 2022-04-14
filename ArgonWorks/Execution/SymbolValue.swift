//
//  SymbolValue.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 31/3/22.
//

import Foundation

public enum SymbolKind: Int
    {
    case none
    case `class`
    case module
    case enumeration
    case moduleSlot
    case slot
    case typeAlias
    case primitive
    case method
    case methodInstance
    }
    
public enum SymbolValue
    {
    case error(CompilerIssues)
    case `class`(TypeClass)
    case module(Module)
    case enumeration(TypeEnumeration)
    case moduleSlot(Slot)
    case typeAlias(TypeAlias)
    case primitive(MethodInstance)
    case methodInstance(MethodInstance)
    
    public var symbolKind: SymbolKind
        {
        switch(self)
            {
            case .class:
                return(.class)
            case .module:
                return(.module)
            case .enumeration:
                return(.enumeration)
            case .typeAlias:
                return(.typeAlias)
            case .primitive:
                return(.primitive)
            case .methodInstance:
                return(.methodInstance)
            default:
                return(.none)
            }
        }
        
    public var symbol: Symbol
        {
        switch(self)
            {
            case .error:
                fatalError()
            case .class(let aClass):
                return(aClass)
            case .module(let module):
                return(module)
            case .enumeration(let enumeration):
                return(enumeration)
            case .typeAlias(let alias):
                return(alias)
            case .primitive(let primitive):
                return(primitive)
            case .methodInstance(let instance):
                return(instance)
            default:
                fatalError()
            }
        }
        
    public var hasIssues: Bool
        {
        switch(self)
            {
            case .error(let issues):
                return(!issues.isEmpty)
            case .class(let aClass):
                return(!aClass.issues.isEmpty)
            case .module(let module):
                return(!module.issues.isEmpty)
            case .enumeration(let enumeration):
                return(!enumeration.issues.isEmpty)
            case .typeAlias(let alias):
                return(!alias.issues.isEmpty)
            case .primitive(let primitive):
                return(!primitive.issues.isEmpty)
            case .methodInstance(let instance):
                return(!instance.issues.isEmpty)
            default:
                return(false)
            }
        }
        
    public var issues: CompilerIssues
        {
        switch(self)
            {
            case .error(let issues):
                return(issues)
            case .class(let aClass):
                return(aClass.issues)
            case .module(let module):
                return(module.issues)
            case .enumeration(let enumeration):
                return(enumeration.issues)
            case .typeAlias(let alias):
                return(alias.issues)
            case .primitive(let primitive):
                return(primitive.issues)
            case .methodInstance(let instance):
                return(instance.issues)
            default:
                return([])
            }
        }
    }
    
