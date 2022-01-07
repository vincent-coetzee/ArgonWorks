//
//  Container.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/12/21.
//

import Foundation

public enum Container: Scope
    {
    public var isMethodInstanceScope: Bool
        {
        false
        }
        
    public func setContainer(_ scope: Scope?)
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                return(symbol.setContainer(scope))
            case .type(let type):
                return(type.setContainer(scope))
            case .block(let block):
                return(block.setContainer(scope))
            case .scope(let scope):
                return(scope.setContainer(scope))
            }
        }
    
    public var memoryAddress: Address
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                return(symbol.memoryAddress)
            case .type(let type):
                return(type.memoryAddress)
            case .block:
                fatalError()
            case .scope:
                fatalError()
            }
        }
        
    public var fullName: Name
        {
        switch(self)
            {
            case .none:
                return(Name("\\\\"))
            case .symbol(let symbol):
                return(symbol.fullName)
            case .type(let type):
                return(type.fullName)
            case .block:
                fatalError()
            case .scope:
                fatalError()
            }
        }
        
    public var container: Container
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                return(symbol.container)
            case .type(let type):
                return(type.container)
            case .block(let block):
                return(block.container)
            case .scope(let scope):
                return(scope.parentScope as! Container)
            }
        }
        
    public var module: Module!
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                return(symbol.module)
            case .type(let type):
                return(type.module)
            case .block(let block):
                return(block.module)
            case .scope(let scope):
                return(scope.module)
            }
        }
        
    public var parentScope: Scope?
        {
        get
            {
            switch(self)
                {
                case .none:
                    fatalError()
                case .symbol(let symbol):
                    return(symbol.container)
                case .type(let type):
                    return(type.container)
                case .block(let block):
                    return(block.container)
            case .scope(let scope):
                return(scope.parentScope)
                }
            }
        set
            {
            switch(self)
                {
                case .none:
                    fatalError()
                case .symbol(let symbol):
                    symbol.setContainer(newValue)
                case .type(let type):
                    type.setContainer(newValue)
                case .block(let block):
                    block.setContainer(newValue)
                case .scope(let scope):
                    scope.setContainer(newValue)
                }
            }
        }
    
    case none
    case symbol(Symbol)
    case type(Type)
    case block(Block)
    case scope(Scope)
    
    public func addSymbol(_ symbol: Symbol)
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                return(symbol.addSymbol(symbol))
            case .type:
                fatalError()
            case .block(let block):
                return(block.addSymbol(symbol))
            case .scope(let scope):
                return(scope.addSymbol(symbol))
            }
        }
        
    
    public func addLocalSlot(_ localSlot: LocalSlot)
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                symbol.addLocalSlot(localSlot)
            case .type:
                fatalError()
            case .block(let block):
                block.addLocalSlot(localSlot)
            case .scope:
                fatalError()
            }
        }
    
    public func lookup(label: Label) -> Symbol?
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                return(symbol.lookup(label: label))
            case .type:
                fatalError()
            case .block(let block):
                return(block.lookup(label: label))
            case .scope(let scope):
                return(scope.lookup(label: label))
            }
        }
        
    public func lookup(name: Name) -> Symbol?
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                return(symbol.lookup(name: name))
            case .type:
                fatalError()
            case .block(let block):
                return(block.lookup(name: name))
            case .scope(let scope):
                return(scope.lookup(name: name))
            }
        }

    public func lookupN(label: Label) -> Symbols?
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                return(symbol.lookupN(label: label))
            case .type:
                fatalError()
            case .block(let block):
                return(block.lookupN(label: label))
            case .scope(let scope):
                return(scope.lookupN(label: label))
            }
        }
    
    public func lookupN(name: Name) -> Symbols?
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                return(symbol.lookupN(name: name))
            case .type:
                fatalError()
            case .block(let block):
                return(block.lookupN(name: name))
            case .scope(let scope):
                return(scope.lookupN(name: name))
            }
        }
    
    public func appendIssue(at: Location, message: String)
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                symbol.appendIssue(at: at,message: message)
            case .type(let type):
                type.appendIssue(at: at,message: message)
            case .block(let block):
                block.appendIssue(at: at,message: message)
            case .scope(let scope):
                scope.appendIssue(at: at,message: message)
            }
        }
        
    public func appendWarningIssue(at: Location, message: String)
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                symbol.appendWarningIssue(at: at,message: message)
            case .type(let type):
                type.appendWarningIssue(at: at,message: message)
            case .block(let block):
                block.appendWarningIssue(at: at,message: message)
            case .scope(let scope):
                scope.appendWarningIssue(at: at, message: message)
            }
        }
    }
