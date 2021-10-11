//
//  Parent.swift
//  Parent
//
//  Created by Vincent Coetzee on 21/8/21.
//

import Foundation

public enum Parent:Storable
    {
    case none
    case node(Node)
    case block(Block)
    case expression(Expression)

    public init()
        {
        self = .none
        }

    public init(input: InputFile) throws
        {
        fatalError()
        }
    
    public func write(output: OutputFile) throws
        {
        try output.write(self)
        }
        
    public var block: Block
        {
        switch(self)
            {
            case .none:
                fatalError("This should not happen")
            case .node:
                fatalError("This should not happen")
            case .expression:
                fatalError("This should not happen")
            case .block(let block):
                return(block)
            }
        }
        
    public var name: Name
        {
        switch(self)
            {
            case .none:
                return(Name())
            case .expression:
                fatalError("This should not happen")
            case .node(let node):
                return(node.name)
            case .block:
                fatalError("This should not happen")
            }
        }
        
        
    public var topModule: TopModule
        {
        switch(self)
            {
            case .none:
                fatalError("This should not happen")
            case .expression(let expression):
                print(expression)
                return(expression.parent.topModule)
            case .node(let node):
                return(node.topModule)
            case .block(let block):
                return(block.topModule)
            }
        }
        
    public func lookup(name: Name) -> Symbol?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .node(let node):
                return(node.lookup(name: name))
            case .expression(let expression):
                return(expression.parent.lookup(name: name))
            case .block(let block):
                return(block.lookup(name: name))
            }
        }
        
    public var firstInitializer: Initializer?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .node(let node):
                return(node.firstInitializer)
            case .expression:
                return(nil)
            case .block(let block):
                return(block.firstInitializer)
            }
        }
        
    public func lookup(label: Label) -> Symbol?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .node(let node):
                return(node.lookup(label: label))
            case .expression(let expression):
                return(expression.parent.lookup(label: label))
            case .block(let block):
                return(block.lookup(label: label))
            }
        }
        
    public func addSymbol(_ symbol:Symbol)
        {
        switch(self)
            {
            case .none:
                fatalError("Attempt to addSymbol to a .none parent")
            case .node(let node):
                node.addSymbol(symbol)
            case .expression(let expression):
                expression.parent.addSymbol(symbol)
            case .block(let block):
                block.addSymbol(symbol)
            }
        }
        
    public var primaryContext: NamingContext
        {
        switch(self)
            {
            case .none:
                fatalError("This should not happen")
            case .node(let node):
                return(node.primaryContext)
            case .expression(let expression):
                return(expression.parent.primaryContext)
            case .block(let block):
                return(block.primaryContext)
            }
        }
        
    public func setSymbol(_ symbol: Symbol,atName: Name)
        {
        switch(self)
            {
            case .none:
                fatalError("This should not happen")
            case .node(let node):
                return(node.setSymbol(symbol,atName: atName))
            case .expression(let expression):
                return(expression.parent.primaryContext.setSymbol(symbol,atName: atName))
            case .block(let block):
                return(block.parent.setSymbol(symbol,atName: atName))
            }
        }
    }
