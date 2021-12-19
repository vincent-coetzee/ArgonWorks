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
    case node(Symbol)
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
        
    public var enclosingScope: Scope
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .node(let node):
                if node is Scope
                    {
                    return(node as! Scope)
                    }
                else
                    {
                    return(node.parent.enclosingScope)
                    }
            case .expression(let expression):
                if expression is Scope
                    {
                    return(expression as! Scope)
                    }
                else
                    {
                    return(expression.parent.enclosingScope)
                    }
            case .block(let block):
                if block is Scope
                    {
                    return(block as! Scope)
                    }
                else
                    {
                    return(block.parent.enclosingScope)
                    }
            }
        }
        
    public var enclosingBlockContext: BlockContext
        {
        self.enclosingScope.enclosingBlockContext
        }
        
    public var block: Block?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .node:
                return(nil)
            case .expression:
                return(nil)
            case .block(let block):
                return(block)
            }
        }
        
    public var node: Node?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .node(let node):
                return(node)
            case .expression:
                return(nil)
            case .block:
                return(nil)
            }
        }
        
    public var parent: Parent
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .node(let node):
                return(node.parent)
            case .expression(let expression):
                return(expression.parent)
            case .block(let block):
                return(block.parent)
            }
        }
        
    public var fullName: Name
        {
        switch(self)
            {
            case .none:
                return(Name())
            case .expression:
                fatalError("This should not happen")
            case .node(let node):
                return(node.fullName)
            case .block:
                fatalError("This should not happen")
            }
        }
        
    public var type: Type?
        {
        switch(self)
            {
            case .none:
                fatalError("This should not happen")
            case .expression(let expression):
                return(expression.type)
            case .node(let node):
                return(node.type)
            case .block:
                fatalError("Block's do not have types")
            }
        }
        
    public var memoryAddress: Address
        {
        switch(self)
            {
            case .node(let node):
                return(node.memoryAddress)
            default:
                fatalError("Memory address invoked on something that does not have a memory address")
            }
        }
        
   public var segmentType: Segment.SegmentType
        {
        switch(self)
            {
            case .node(let node):
                return(node.segmentType)
            default:
                fatalError("Segment Type invoked on something that does not have a segment type")
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
        
    public func lookupN(label: Label) -> Symbols?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .node(let node):
                return(node.lookupN(label: label))
            case .expression(let expression):
                return(expression.parent.lookupN(label: label))
            case .block(let block):
                return(block.lookupN(label: label))
            }
        }
        
    public func lookupN(name: Name) -> Symbols?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .node(let node):
                return(node.lookupN(name: name))
            case .expression(let expression):
                return(expression.parent.lookupN(name: name))
            case .block(let block):
                return(block.lookupN(name: name))
            }
        }
        
    public var enclosingClass: Class?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .node(let node):
                return(node.enclosingClass)
            case .expression:
                return(nil)
            case .block(let block):
                return(block.enclosingClass)
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
        
//    public func addSymbol(_ symbol:Symbol)
//        {
//        switch(self)
//            {
//            case .none:
//                fatalError("Attempt to addSymbol to a .none parent")
//            case .node(let node):
//                node.addSymbol(symbol)
//            case .expression(let expression):
//                expression.parent.addSymbol(symbol)
//            case .block(let block):
//                block.addSymbol(symbol)
//            }
//        }
        
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
        
    public func printParentChain()
        {
        switch(self)
            {
            case .none:
                print("PARENT CHAIN ENDS WITH .none")
            case .node(let node):
                print("\(node)")
                return(node.printParentChain())
            case .expression(let expression):
                print("\(expression)")
                expression.printParentChain()
            case .block(let block):
                print("\(block)")
                block.printParentChain()
            }
        }
    }
