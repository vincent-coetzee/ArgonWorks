//
//  Name.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public struct Name:CustomStringConvertible,Comparable,Hashable
    {
    public static func ==(lhs:Name,rhs:Name) -> Bool
        {
        return(lhs.description == rhs.description)
        }
        
    public static func <(lhs:Name,rhs:Name) -> Bool
        {
        return(lhs.description < rhs.description)
        }
        
    public static func +(lhs:Name,rhs:Label) -> Name
        {
        let components = lhs.components + [.piece(rhs)]
        return(Name(components))
        }
        
    private enum Component
        {
        case root
        case piece(String)
        
        var isRoot: Bool
            {
            switch(self)
                {
                case .root:
                    return(true)
                default:
                    return(false)
                }
            }
            
        var string:String
            {
            switch(self)
                {
                case .root:
                    return("\\")
                case .piece(let string):
                    return(string)
                }
            }
        }
        
    public var string: String
        {
        return(self.components.map{$0.string}.joined(separator: "\\"))
        }
        
    public var description: String
        {
        return(self.components.map{$0.string}.joined(separator: "\\"))
        }
        
    public var displayString: String
        {
        return(self.components.map{$0.string}.joined(separator: "\\"))
        }
        
    public var count: Int
        {
        return(self.components.count)
        }
        
    public var isEmpty: Bool
        {
        return(self.components.isEmpty)
        }
        
    public var withoutFirst: Name
        {
        if self.components.isEmpty
            {
            return(Name())
            }
        if self.components.first!.isRoot
            {
            return(Name(Array(self.components.dropFirst(2))))
            }
        return(Name(Array(self.components.dropFirst(1))))
        }
        
    public var isRooted: Bool
        {
        return(self.components.first!.isRoot)
        }
        
    public var first: Label
        {
        if self.count == 0
            {
            fatalError("Called first on an empty name")
            }
        if self.components.first!.isRoot
            {
            if self.components.count > 1
                {
                return(self.components[1].string)
                }
            fatalError("Called first on a rooted name with no second part")
            }
        return(self.components.first!.string)
        }
        
    public var last: Label
        {
        return(self.components.last!.string)
        }
        
    private let components: Array<Component>
    
    private init(_ bits:Array<Component>)
        {
        self.components = bits
        }
        
    public init()
        {
        self.components = []
        }
        
    public init(rooted:Bool)
        {
        if rooted
            {
            self.components = [.root]
            }
        else
            {
            self.components = []
            }
        }
        
    public init(_ label:Label)
        {
        var input = label
        var first: Component? = nil
        if label.hasPrefix("\\\\")
            {
            first = .root
            input = String(input.dropFirst(2))
            }
        else if label.hasPrefix("\\")
            {
            input = String(input.dropFirst())
            }
        let bits = input.components(separatedBy: "\\")
        self.components = (first.isNil ? [] : [first!]) + bits.map{Component.piece($0)}
        }
        
    public func hash(into hasher:inout Hasher)
        {
        for component in self.components
            {
            hasher.combine(component.string)
            }
        }
    }
