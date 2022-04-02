//
//  Name.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public protocol Nameable
    {
    var fullName: Name { get }
    }

public struct Name:CustomStringConvertible,Comparable,Hashable
    {
    public static func ==(lhs:Name,rhs:Name) -> Bool
        {
        return(lhs.components == rhs.components)
        }
        
    public static func <(lhs:Name,rhs:Name) -> Bool
        {
        return(lhs.description < rhs.description)
        }
        
    public static func +(lhs:Name,rhs:Label) -> Name
        {
        let components = lhs.components + [.piece(rhs)]
        let newName = Name(components)
//        newName.topModule = lhs.topModule
        return(newName)
        }
        
    public init(coder:NSCoder,forKey key:String)
        {
        let count = coder.decodeInteger(forKey: key + "count")
        var pieces = Array<Component>()
        for index in 0..<count
            {
            if coder.decodeInteger(forKey: key + "\(index)kind") == 1
                {
                pieces.append(.root)
                }
            else
                {
                let string = coder.decodeString(forKey: key + "\(index)string")!
                pieces.append(.piece(string))
                }
            }
        self.components = pieces
        }
        
    public func encode(with coder:NSCoder,forKey key:String)
        {
        coder.encode(self.components.count,forKey: key+"count")
        var index = 0
        for component in self.components
            {
            switch(component)
                {
                case .root:
                    coder.encode(1,forKey: key + "\(index)kind")
                    index += 1
                case .piece(let string):
                    coder.encode(2,forKey: key + "\(index)kind")
                    coder.encode(string,forKey: key + "\(index)string")
                    index += 1
                }
            }
        }
        
    public var hashValue: Int
        {
        self.string.polynomialRollingHash
        }
        
    private enum Component: Equatable
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
        
    public var withoutLast: Name
        {
        if self.components.isEmpty
            {
            return(Name())
            }
        return(Name(Array(self.components.dropLast())))
        }
        
    public var isRooted: Bool
        {
        if self.components.isEmpty
            {
            return(false)
            }
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
        
    public var car: String
        {
        self.first
        }
        
    public var cdr: Name
        {
        self.withoutFirst
        }
        
    public var last: Label
        {
        return(self.components.last!.string)
        }
        
    private let components: Array<Component>
//    public var topModule: TopModule!
    
    private init(_ bits:Array<Component>)
        {
        self.components = bits
        }
        
    public init()
        {
        self.components = []
        }
        
//    public func withTopModule(_ topModule: TopModule) -> Name
//        {
//        var aName = self
//        aName.topModule = topModule
//        return(aName)
//        }

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
        
    public init(rooted: Bool)
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
        
    public func hash(into hasher:inout Hasher)
        {
        for component in self.components
            {
            hasher.combine(component.string)
            }
        }
    }
