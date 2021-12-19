//
//  SystemScope.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/12/21.
//

import Foundation

fileprivate var currentContainer: Container = .top(TopModule(instanceNumber: 1))

public enum Container
    {
    public static var current: Container
        {
        return(currentContainer)
        }
     
    public var container: Container?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .symbol(let symbol):
                return(symbol.container)
            case .top:
                return(nil)
            case .block(let block):
                return(block.container)
            case .expression(let expression):
                return(expression.container)
            }
        }
        
    case none
    case symbol(ContainerSymbol)
    case top(TopModule)
    case block(Block)
    case expression(Expression)
    
    public func lookup(label: Label) -> Symbol?
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .symbol(let symbol):
                for aSymbol in symbol.symbols
                    {
                    if aSymbol.label == label
                        {
                        return(aSymbol)
                        }
                    }
                if symbol is ArgonModule
                    {
                    return(nil)
                    }
                return(symbol.container?.lookup(label: label))
            case .block(let block):
                for symbol in block.localSymbols
                    {
                    if symbol.label == label
                        {
                        return(symbol)
                        }
                    }
                return(block.container?.lookup(label: label))
            case .expression(let expression):
                return(expression.container?.lookup(label: label))
            case .top(let topModule):
                for symbol in topModule.symbols
                    {
                    if symbol.label == label
                        {
                        return(symbol)
                        }
                    }
                return(topModule.argonModule.lookup(label: label))
            }
        }
    }
