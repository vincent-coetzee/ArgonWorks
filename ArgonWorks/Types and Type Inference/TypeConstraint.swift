//
//  TypeConstraint.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/11/21.
//

import Foundation

public class TypeConstraint: Displayable,CustomStringConvertible
    {
    public var description: String
        {
        self.displayString
        }
        
    public var displayString: String
        {
        "TypeConstraint(\(self.lhs),\(self.rhs))"
        }
        
    internal enum Origin
        {
        case symbol(Symbol)
        case expression(Expression)
        case block(Block)
        }
        
    internal let lhs: Type
    internal let rhs: Type
    internal let origin: Origin
    
    init(left: Type,right: Type,origin: Origin)
        {
        self.lhs = left
        self.rhs = right
        self.origin = origin
        }
        
    public func replace(_ id:Int,with type: Type)
        {
        self.lhs.replace(id,with: type)
        self.rhs.replace(id,with: type)
        }
    }
    
public class SubTypeConstraint: TypeConstraint
    {
    init(subtype left: Type,supertype right: Type,origin: Origin)
        {
        super.init(left: left,right: right,origin: origin)
        }
    }

public typealias TypeConstraints = Array<TypeConstraint>
