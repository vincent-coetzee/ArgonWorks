//
//  Container.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/12/21.
//

import Foundation

//public enum Container: Scope
//    {
////    public var methodInstanceScope: MethodInstance?
////        {
////        switch(self)
////            {
////            case .symbol(let symbol):
////                return(symbol as? MethodInstance)
////            default:
////                return(nil)
////            }
////        }
////
////    public var moduleScope: Module?
////        {
////        switch(self)
////            {
////            case .symbol(let symbol):
////                return(symbol as? Module)
////            default:
////                return(nil)
////            }
////        }
//        
////    public func setContainer(_ scope: Scope?)
////        {
////        switch(self)
////            {
////            case .none:
////                fatalError()
////            case .symbol(let symbol):
////                return(symbol.setContainer(scope))
////            case .type(let type):
////                return(type.setContainer(scope))
////            case .block(let block):
////                return(block.setContainer(scope))
////            case .scope(let scope):
////                return(scope.setContainer(scope))
////            }
////        }
//    
//    public var asContainer: Container
//        {
//        self
//        }
//        
//    public var moduleScope: Module?
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module(let symbol):
//                return(symbol)
////            case .type(let type):
////                return(type.memoryAddress)
//            case .block:
//                return(nil)
//            case .methodInstance:
//                return(nil)
//            }
//        }
//        
//    public var memoryAddress: Address
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module(let symbol):
//                return(symbol.memoryAddress)
////            case .type(let type):
////                return(type.memoryAddress)
//            case .block:
//                fatalError()
//            case .methodInstance:
//                fatalError()
//            }
//        }
//        
//    public var fullName: Name
//        {
//        switch(self)
//            {
//            case .none:
//                return(Name("\\\\"))
//            case .module(let symbol):
//                return(symbol.fullName)
////            case .type(let type):
////                return(type.fullName)
//            case .block:
//                fatalError()
//            case .methodInstance:
//                fatalError()
//            }
//        }
//        
//    public var stringValue: String
//        {
//        switch(self)
//            {
//            case .none:
//                return("Container(.none)")
//            case .module(let symbol):
//                return("Container(.symbol(\(symbol.label)))")
////            case .type(let type):
////                return(type.fullName)
//            case .block(let aBlock):
//                return("Container(.block(\(aBlock.index.stringValue)))")
//            case .methodInstance(let instance):
//                return("Container(.methodInstance(\(instance.label),\(instance.index)))")
//            }
//        }
//        
//    public var container: Container
//        {
//        get
//            {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module(let symbol):
//                return(symbol.container)
////            case .type(let type):
////                return(type.container)
//            case .block(let block):
//                return(block.container)
//            case .methodInstance(let scope):
//                return(scope.parentScope as! Container)
//            }
//            }
//        set
//            {
//            fatalError()
//            }
//        }
//        
//    public var module: Module?
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module(let symbol):
//                return(symbol)
////            case .type(let type):
////                return(type.module)
//            case .block(let block):
//                return(block.container.module!)
//            case .methodInstance(let scope):
//                return(scope.module!)
//            }
//        }
//        
//    public var enclosingMethodInstance: MethodInstance
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module:
//                fatalError()
////            case .type(let type):
////                return(type.module)
//            case .block(let block):
//                return(block.enclosingMethodInstance)
//            case .methodInstance(let scope):
//                return(scope)
//            }
//        }
//        
//    public var parentScope: Scope?
//        {
//        get
//            {
//            switch(self)
//                {
//                case .none:
//                    return(nil)
//                case .module(let symbol):
//                    return(symbol.container)
//                case .methodInstance(let instance):
//                    return(instance.container)
//                case .block(let block):
//                    return(block.container)
////            case .scope(let scope):
////                return(scope.parentScope)
//                }
//            }
//        set
//            {
//            switch(self)
//                {
//                case .none:
//                    fatalError()
//                case .module(var symbol):
//                    symbol.setContainer(newValue)
////                case .type(let type):
////                    type.setContainer(newValue)
//                case .block(var block):
//                    block.setContainer(newValue)
//                case .methodInstance(var scope):
//                    scope.setContainer(newValue)
//                }
//            }
//        }
//    
//    case none
//    case module(Module)
//    case methodInstance(MethodInstance)
////    case symbol(Symbol)
////    case type(Type)
//    case block(Block)
////    case scope(Scope)
//    
//    public func addSymbol(_ symbol: Symbol)
//        {
////        switch(self)
////            {
////            case .none:
////                fatalError()
////            case .symbol(let symbol):
////                return(symbol.addSymbol(symbol))
////            case .type:
////                fatalError()
////            case .block(let block):
////                return(block.addSymbol(symbol))
////            case .scope(let scope):
////                return(scope.addSymbol(symbol))
////            }
//        fatalError()
//        }
//        
//
//    public func addLocalSlot(_ localSlot: LocalSlot)
//        {
////        switch(self)
////            {
////            case .none:
////                fatalError()
////            case .symbol(let symbol):
////                symbol.addLocalSlot(localSlot)
////            case .type:
////                fatalError()
////            case .block(let block):
////                block.addLocalSlot(localSlot)
////            case .scope:
////                fatalError()
////            }
//        fatalError()
//        }
//    
//    public func lookup(label: Label) -> Symbol?
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module(let symbol):
//                return(symbol.lookup(label: label))
////            case .type:
////                fatalError()
//            case .block(let block):
//                return(block.lookup(label: label))
//            case .methodInstance(let scope):
//                return(scope.lookup(label: label))
//            }
//        }
//        
//    public func lookup(name: Name) -> Symbol?
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module(let symbol):
//                return(symbol.lookup(name: name))
////            case .type:
////                fatalError()
//            case .block(let block):
//                return(block.lookup(name: name))
//            case .methodInstance(let scope):
//                return(scope.lookup(name: name))
//            }
//        }
//
//    public func lookupN(label: Label) -> Symbols?
//        {
//        switch(self)
//            {
//            case .none:
//                return(nil)
//            case .module(let symbol):
//                return(symbol.lookupN(label: label))
////            case .type:
////                fatalError()
//            case .block(let block):
//                return(block.lookupN(label: label))
//            case .methodInstance(let scope):
//                return(scope.lookupN(label: label))
//            }
//        }
//    
//    public func lookupN(name: Name) -> Symbols?
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module(let symbol):
//                return(symbol.lookupN(name: name))
////            case .type:
////                fatalError()
//            case .block(let block):
//                return(block.lookupN(name: name))
//            case .methodInstance(let scope):
//                return(scope.lookupN(name: name))
//            }
//        }
//    
//    public func appendIssue(at: Location, message: String)
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module(let symbol):
//                symbol.appendIssue(at: at,message: message)
////            case .type(let type):
////                type.appendIssue(at: at,message: message)
//            case .block(let block):
//                block.appendIssue(at: at,message: message)
//            case .methodInstance(let scope):
//                scope.appendIssue(at: at,message: message)
//            }
//        }
//        
//    public func appendWarningIssue(at: Location, message: String)
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError()
//            case .module(let symbol):
//                symbol.appendWarningIssue(at: at,message: message)
////            case .type(let type):
////                type.appendWarningIssue(at: at,message: message)
//            case .block(let block):
//                block.appendWarningIssue(at: at,message: message)
//            case .methodInstance(let scope):
//                scope.appendWarningIssue(at: at, message: message)
//            }
//        }
//    }
