//
//  Node.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import SwiftUI
    
public class Node:NSObject,NamingContext,Identifiable,NSCoding,StorableObject
    {
    public var tag: Int = 0
    public var index: UUID
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
        
//    public required init(input: InputFile) throws
//        {
//        fatalError("Not implemented")
//        }
    
    public func write(output: OutputFile) throws
        {
        try output.write(self)
        }
    
    public var firstInitializer: Initializer?
        {
        return(nil)
        }
        
    public var name: Name
        {
        return(self.parent.name + self.label)
        }
        
    public static func ==(lhs:Node,rhs:Node) -> Bool
        {
        return(lhs.index == rhs.index)
        }

    public func resetParent()
        {
        self.parent = .none
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
            case .none:
                break
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
            if let start = TopModule.shared.lookup(label: name.first)
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
        
    public func lookup(label: Label) -> Symbol?
        {
        return(nil)
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
