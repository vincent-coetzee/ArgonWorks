//
//  Node.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import SwiftUI
    
public class Node:NSObject,NamingContext,Identifiable,NSCoding
    {
    public var enclosingScope: Scope
        {
        return(self.parent.enclosingScope)
        }
        
    public private(set) var index: UUID
    public private(set) var label: String
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
        
    public required init(label: String)
        {
        self.index = UUID()
        self.label = label
        }
        
    public init(label: Label,index: UUID)
        {
        self.label = label
        self.index = index
        }
        
    required public init?(coder: NSCoder)
        {
        self.index = coder.decodeObject(forKey: "index") as! UUID
        self.label = coder.decodeObject(forKey: "label") as! Label
        self.parent = coder.decodeParent(forKey: "parent")!
        self.locations = coder.decodeNodeLocations(forKey: "locations")
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.index,forKey: "index")
        coder.encode(self.label,forKey: "label")
        coder.encodeParent(self.parent,forKey: "parent")
        coder.encodeNodeLocations(self.locations,forKey: "locations")
        }

    public func setLabel(_ label: Label)
        {
        self.label = label
        }
        
    public func setIndex(_ index:UUID)
        {
        self.index = index
        }
        
    public var enclosingClass: Class?
        {
        return(self.parent.enclosingClass)
        }
        
    public var fullName: Name
        {
        return(self.parent.fullName + self.label)
        }
        
    public static func ==(lhs:Node,rhs:Node) -> Bool
        {
        return(lhs.index == rhs.index)
        }

    public func setParent(_ node: Symbol)
        {
        self.parent = .node(node)
        }
        
    public func setParent(_ expression: Expression)
        {
        self.parent = .expression(expression)
        }
        
    public func setParent(_ block: Block)
        {
        self.parent = .block(block)
        }
        
    public func setParent(_ aParent: Parent)
        {
        self.parent = aParent
        switch(parent)
            {
            case .none:
                print("halt")
            default:
                break
            }
        }
        
    public func setParent(_ context: Context)
        {
        switch(context)
            {
            case .none:
                break
            case .block(let block):
                self.parent = .block(block)
            case .node(let node):
                self.parent = .node(node)
            }
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
        
    public func lookup(name: Name) -> Symbol?
        {
        if name.isEmpty
            {
            return(nil)
            }
        else if name.isRooted
            {
            if name.count == 1
                {
                return(nil)
                }
            if let start = self.topModule.lookup(label: name.first)
                {
                if let symbol = start.lookup(name: name.withoutFirst)
                    {
                    return(symbol)
                    }
                }
            }
        else if name.count == 1
            {
            if let symbol = self.lookup(label: name.first)
                {
                return(symbol)
                }
            }
        else if let start = self.lookup(label: name.first)
            {
            if let symbol = start.lookup(name: name.withoutFirst)
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(name: name))
        }
        
    public func lookupN(name: Name) -> Symbols?
        {
        if name.isEmpty
            {
            return(nil)
            }
        else if name.isRooted
            {
            if name.count == 1
                {
                return(nil)
                }
            if let starts = self.topModule.lookupN(label: name.first)
                {
                var results = Symbols()
                for start in starts
                    {
                    if let symbols = start.lookupN(name: name.withoutFirst)
                        {
                        results.append(contentsOf: symbols)
                        }
                    }
                return(results.isEmpty ? nil : results)
                }
            }
        else if name.count == 1
            {
            if let symbols = self.lookupN(label: name.first)
                {
                return(symbols)
                }
            }
        else if let starts = self.lookupN(label: name.first)
            {
            var results = Symbols()
            for start in starts
                {
                if let symbols = start.lookupN(name: name.withoutFirst)
                    {
                    results.append(contentsOf: symbols)
                    }
                }
            return(results.isEmpty ? nil : results)
            }
        return(self.parent.lookupN(name: name))
        }
        
    public func lookup(label: Label) -> Symbol?
        {
        self.parent.lookup(label: label)
        }
        
    public func lookupN(label: Label) -> Symbols?
        {
        self.parent.lookupN(label: label)
        }
        
    public func addSymbol(_ symbol:Symbol)
        {
        fatalError("Attempt to addSymbol to a \(Swift.type(of:self))")
        }
        
    public func removeSymbol(_ symbol:Symbol)
        {
        fatalError("Attempt to removeSymbol in a \(Swift.type(of:self))")
        }
        
    public func setSymbol(_ symbol:Symbol,atName: Name)
        {
        fatalError("Attempt to addSymbol:AtName to a \(Swift.type(of:self))")
        }
    }
