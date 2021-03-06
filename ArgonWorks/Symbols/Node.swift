//
//  Node.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import SwiftUI
    
public class Node:NSObject,NamingContext,Identifiable
    {
    public let index: UUID
    public let label: String
    public private(set) var parent: Parent = .none
    private var locations = NodeLocations()
    
    public var declarationLocation: Location
        {
        get
            {
            locations.declarationLocation
            }
        set
            {
            locations.append(.declaration(newValue))
            }
        }
        
    public var type: Type
        {
        fatalError("This should have been implemented in a class")
        }
        
    public init(label: String)
        {
        self.index = UUID.newUUID()
        self.label = label
        }
        
    public var name: Name
        {
        return(self.parent.name + self.label)
        }
        
    public static func ==(lhs:Node,rhs:Node) -> Bool
        {
        return(lhs.index == rhs.index)
        }

    public func setParent(_ node: Node)
        {
        self.parent = .node(node)
        }
        
    public func setParent(_ block: Block)
        {
        self.parent = .block(block)
        }
        
    public func setParent(_ aParent: Parent)
        {
        self.parent = aParent
        }
        
    public func setParent(_ context: Context)
        {
        switch(context)
            {
            case .block(let block):
                self.parent = .block(block)
            case .node(let node):
                self.parent = .node(node)
            }
        }
        
    public func realize(using realizer:Realizer)
        {
        }
        
    ///
    /// Support for being a NamingContext
    ///
    ///
    public var primaryContext: NamingContext
        {
        return(self.parent.primaryContext)
        }
        
    public var topModule: TopModule
        {
        return(self.parent.topModule)
        }
        
    public func lookup(name:Name) -> Symbol?
        {
        if name.isEmpty
            {
            return(nil)
            }
        if name.isRooted
            {
            if let context = self.primaryContext.lookup(label: name.first)
                {
                return(context.lookup(name: name.withoutFirst))
                }
            return(nil)
            }
        if name.count == 1,let symbol = self.lookup(label: name.first)
            {
            return(symbol)
            }
        if let context = self.lookup(label: name.first),let symbol = context.lookup(name: name.withoutFirst)
            {
            return(symbol)
            }
        return(self.parent.lookup(name:name))
        }
        
    public func lookup(label: Label) -> Symbol?
        {
        return(nil)
        }
        
    @discardableResult
    public func addSymbol(_ symbol:Symbol) -> Symbol
        {
        fatalError("Attempt to addSymbol to a \(Swift.type(of:self))")
        }
        
    public func setSymbol(_ symbol:Symbol,atName: Name)
        {
        fatalError("Attempt to addSymbol:AtName to a \(Swift.type(of:self))")
        }
    }
