//
//  TypeConstraint.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/11/21.
//

import Foundation

public class TypeConstraint: Displayable,CustomStringConvertible
    {
    public var line: Int
        {
        switch(self.origin)
            {
            case .symbol(let symbol):
            if let line = symbol.declaration?.line
                {
                return(line)
                }
            return(0)
            case .expression(let expression):
                return(expression.declaration!.line)
            case .block(let block):
                return(block.declaration.isNil ? 0 : block.declaration!.line)
            case .tuple:
                return(0)
            }
        }
        
    public var originTypeString: String
        {
        switch(self.origin)
            {
            case .symbol(let symbol):
                return("\(Swift.type(of: symbol))")
            case .expression(let expression):
                return("\(Swift.type(of: expression)) \(expression.diagnosticString)")
            case .block(let block):
                return("\(Swift.type(of: block))")
            case .tuple(let tuple):
                return("\(tuple)")
            }
        }
        
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
        public var diagnosticString: String
            {
            switch(self)
                {
                case .symbol(let symbol):
                    return(symbol.displayString)
                case .expression(let expression):
                    return(expression.diagnosticString)
                case .block(let block):
                    return(block.displayString)
                default:
                    return("")
                }
            }
            
        case symbol(Symbol)
        case expression(Expression)
        case block(Block)
        case tuple(Tuple)
        
        public func appendIssue(_ issue: CompilerIssue)
            {
            switch(self)
                {
                case .symbol(let symbol):
                    symbol.appendIssue(issue)
                case .expression(let expression):
                    expression.appendIssue(issue)
                case .block(let block):
                    block.appendIssue(issue)
                default:
                    break
                }
            }
        }
        
    internal let lhs: Type
    internal let rhs: Type
    internal let origin: Origin
    
    init(left: Type?,right: Type?,origin: Origin)
        {
        assert(left.isNotNil)
        assert(right.isNotNil)
        self.lhs = left!
        self.rhs = right!
        self.origin = origin
        }
    }
    
public class SubTypeConstraint: TypeConstraint
    {
    init(subtype left: Type?,supertype right: Type?,origin: Origin)
        {
        assert(left.isNotNil)
        assert(right.isNotNil)
        super.init(left: left,right: right,origin: origin)
        }
    }

public typealias TypeConstraints = Array<TypeConstraint>
