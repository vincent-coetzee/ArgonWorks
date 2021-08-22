//
//  AccessLevel.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 5/30/21.
//

import Foundation

///
///
/// A symbol's visibility depends on the access modifier that has been
/// applied to it.
///
/// An EXPORTED symbol is visible to anyone who imports the
/// module that contains the exported symbol, it is the most unrestrictive
/// access modifier.
///
/// A PUBLIC symbol is available anywhere inside the
/// container that defines it, it is therefore visible to anyone down the
/// containment hierarchy, as is an exported symbol. A PUBLIC slot is visible
/// anywhere within the container that defined it.
///
/// A PRIVATE symbol is visible only within the container in which
/// it is defined, it is therefore not visible
/// outside the container that defines it or in subcontainers of the container
/// in which it is defined. A PRIVATE slot is NOT visible to subclasses of
/// the defining class.
///
/// A PROTECTED modifier can only be applied to slots
/// within classes ( slots attached to a module can not be decorated with
/// a protected modifier ). Protected slots are slots that are accessible
/// both within the class in which they are defined as well as in subclasses
/// of their definining class.
///
///
/// Some symbols may be SEALED or UNSEALED. A SEALED attribute is a marker to
/// the compiler that informs it that while it must keep the API stable it may
/// completely reorganise and optiise the inner workings of the SEALED symbol.
/// UNSEALED carries the opposite meaning.
///
/// An OPEN symbol is a symbol that may still be extended subclassed or otherwise
/// enhanced, a CLOSED symbol may not be extended or subclasses.
///
///

public enum SymbolAttribute:Int
    {
    case open
    case closed
    case sealed
    case unsealed
    case `public`
    case `private`
    case protected
    case exported
    }
    
public struct SymbolAttributes
    {
    private var attributes = Set<SymbolAttribute>()
    
    init()
        {
        }
        
    init(_ array:[Int])
        {
        self.attributes = Set(array.map{SymbolAttribute(rawValue:$0)!})
        }
        
    init(_ array:Array<SymbolAttribute>)
        {
        self.attributes = Set(array)
        }
        
    init(_ attributes:SymbolAttributes)
        {
        self.attributes = attributes.attributes
        }
        
    public static func +=(left:inout SymbolAttributes,rhs:SymbolAttribute)
        {
        var lhs = left.attributes
        if rhs == .open
            {
            lhs.remove(.closed)
            }
        else if rhs == .sealed
            {
            lhs.remove(.closed)
            }
        if rhs == .closed
            {
            lhs.remove(.open)
            }
        else if rhs == .unsealed
            {
            lhs.remove(.sealed)
            }
        else if rhs == .exported
            {
            lhs.remove(.public)
            lhs.remove(.private)
            lhs.remove(.protected)
            }
        else if rhs == .public
            {
            lhs.remove(.exported)
            lhs.remove(.private)
            lhs.remove(.protected)
            }
        else if rhs == .private
            {
            lhs.remove(.public)
            lhs.remove(.exported)
            lhs.remove(.protected)
            }
        else if rhs == .protected
            {
            lhs.remove(.public)
            lhs.remove(.private)
            lhs.remove(.exported)
            }
        lhs.insert(rhs)
        left.attributes = lhs
        }
        
    public static func +(lhs:SymbolAttributes,rhs:SymbolAttribute) -> SymbolAttributes
        {
        var old = lhs
        old.attributes.insert(rhs)
        return(old)
        }
        
    public var containedAttributes: [SymbolAttribute]
        {
        var set: [SymbolAttribute] = []
        if self.attributes.contains(.open)
            {
            set.append(.open)
            }
        if self.attributes.contains(.closed)
            {
            set.append(.closed)
            }
        if self.attributes.contains(.sealed)
            {
            set.append(.unsealed)
            }
        if self.attributes.contains(.exported)
            {
            set.append(.exported)
            }
        if self.attributes.contains(.public)
            {
            set.append(.public)
            }
        if self.attributes.contains(.protected)
            {
            set.append(.protected)
            }
        if self.attributes.contains(.private)
            {
            set.append(.private)
            }
        return(set)
        }
        
    public func contains(_ attribute:SymbolAttribute) -> Bool
        {
        return(self.attributes.contains(attribute))
        }
        
    public mutating func remove(_ attribute:SymbolAttribute)
        {
        self.attributes.remove(attribute)
        }
        
    public func asIntArray() -> [Int]
        {
        return(self.attributes.map{$0.rawValue})
        }
    }
