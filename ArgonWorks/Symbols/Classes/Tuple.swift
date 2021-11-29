//
//  Tuple.swift
//  Tuple
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Foundation

public enum TupleElement
    {
    public var displayString: String
         {
        switch(self)
            {
            case .localSlot(let slot):
                return(slot.displayString)
            case .tuple(let tuple):
                return(tuple.displayString)
            case .expression(let expression):
                return(expression.displayString)
            case .literal(let literal):
                return(literal.displayString)
            }
        }
        
    public var type: Type
        {
        switch(self)
            {
            case .localSlot(let slot):
                return(slot.type)
            case .literal(let literal):
                return(literal.type)
            case .expression(let expression):
                return(expression.type)
            case .tuple(let tuple):
                return(tuple.type)
            }
        }
        
    public var isTuple: Bool
        {
        if case TupleElement.tuple = self
            {
            return(true)
            }
        return(false)
        }
        
    case literal(Literal)
    case localSlot(LocalSlot)
    case tuple(Tuple)
    case expression(Expression)
    
    init(coder: NSCoder)
        {
        let kind = coder.decodeInteger(forKey: "kind")
        if kind == 1
            {
            self = .literal(Literal(coder: coder))
            }
        else if kind == 2
            {
            self = .localSlot(coder.decodeObject(forKey: "slot") as! LocalSlot)
            }
        else if kind == 3
            {
            self = .tuple(coder.decodeObject(forKey: "tuple") as! Tuple)
            }
        else if kind == 4
            {
            self = .expression(coder.decodeObject(forKey: "expression") as! Expression)
            }
        else
            {
            fatalError()
            }
        }
        
    public func visit(visitor: Visitor) throws
        {
        switch(self)
            {
            case .localSlot(let slot):
                try slot.visit(visitor: visitor)
            case .tuple(let tuple):
                try tuple.visit(visitor: visitor)
            case .expression(let expression):
                try expression.visit(visitor: visitor)
            default:
                break
            }
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        switch(self)
            {
            case .localSlot(let slot):
                try slot.initializeTypeConstraints(inContext: context)
            case .tuple(let tuple):
                try tuple.initializeTypeConstraints(inContext: context)
            case .expression(let expression):
                try expression.initializeTypeConstraints(inContext: context)
            default:
                break
            }
        }
        
        
    func encode(with coder: NSCoder)
        {
        switch(self)
            {
            case .literal(let value):
                coder.encode(1,forKey: "kind")
                value.encode(with: coder)
            case .localSlot(let slot):
                coder.encode(2,forKey: "kind")
                coder.encode(slot,forKey: "slot")
            case .tuple(let tuple):
                coder.encode(3,forKey: "kind")
                coder.encode(tuple,forKey: "tuple")
            case .expression(let expression):
                coder.encode(4,forKey: "kind")
                coder.encode(expression,forKey: "expression")
            }
        }
        
    public func initializeType(inContext context: TypeContext) throws -> TupleElement
        {
        switch(self)
            {
            case .literal:
                return(self)
            case .localSlot(let slot):
                try slot.initializeType(inContext: context)
                return(.localSlot(slot))
            case .tuple(let tuple):
                try tuple.initializeType(inContext: context)
                return(.tuple(tuple))
            case .expression(let expression):
                try expression.initializeType(inContext: context)
                return(.expression(expression))
            }
        }
        
    func setParent(_ block: Block)
        {
        switch(self)
            {
            case .expression(let expression):
                expression.setParent(block)
            default:
                break
            }
        }
        
    public func deepCopy() -> Self
        {
        switch(self)
            {
            case .literal:
                return(self)
            case .localSlot(let slot):
                return(.localSlot(slot.deepCopy()))
            case .tuple(let tuple):
                return(.tuple(tuple.deepCopy()))
            case .expression(let expression):
                return(.expression(expression.deepCopy()))
            }
        }
    }
    
public struct TupleElementPair
    {
    public var displayString: String
        {
        self.lhs.displayString + ":" + self.rhs.displayString
        }
        
    internal let lhs: TupleElement
    internal let rhs: TupleElement
    
    public func setParent(_ block: Block)
        {
        lhs.setParent(block)
        rhs.setParent(block)
        }
        
    public func deepCopy() -> Self
        {
        TupleElementPair(lhs: self.lhs.deepCopy(),rhs: self.rhs.deepCopy())
        }
        
    public func initializeType(inContext context: TypeContext) throws -> TupleElementPair
        {
        let newLeft = try self.lhs.initializeType(inContext: context)
        let newRight = try self.lhs.initializeType(inContext: context)
        return(TupleElementPair(lhs: newLeft,rhs: newRight))
        }
        
    public func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.rhs.visit(visitor: visitor)
        }
    }
    
public typealias TupleElementPairs = Array<TupleElementPair>

extension TupleElementPairs
    {
    public var displayString: String
        {
        self.map{$0.displayString}.joined(separator: " ")
        }
    }
    
public class Tuple: Class,Collection
    {
    public var startIndex: Int
        {
        return(self.elements.startIndex)
        }
        
    public var endIndex: Int
        {
        return(self.elements.startIndex)
        }
        
    internal private(set) var elements = Array<TupleElement>()
    
    init()
        {
        super.init(label: Argon.nextName("1_TUPLE_"))
        }
        
    required init?(coder: NSCoder)
        {
        let count = coder.decodeInteger(forKey: "count")
        for _ in 0..<count
            {
            self.elements.append(TupleElement(coder: coder))
            }
        super.init(coder: coder)
        }
        
    init(_ slot: LocalSlot)
        {
        self.elements.append(.localSlot(slot))
        super.init(label: Argon.nextName("1_TUPLE_"))
        }
        
    init(_ expression: Expression)
        {
        self.elements.append(.expression(expression))
        super.init(label: Argon.nextName("1_TUPLE_"))
        }
        
    required init(label: Label)
        {
        super.init(label: label)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.elements.count,forKey: "count")
        for element in self.elements
            {
            element.encode(with: coder)
            }
        super.encode(with: coder)
        }
        
    internal func append(_ slot: LocalSlot)
        {
        self.elements.append(.localSlot(slot))
        }
        
    internal func append(_ tuple: Tuple)
        {
        self.elements.append(.tuple(tuple))
        }
        
    internal func append(_ expression: Expression)
        {
        self.elements.append(.expression(expression))
        }
        
    public subscript(_ index: Int) -> TupleElement
        {
        self.elements[index]
        }
        
    public func index(after: Int) -> Int
        {
        return(after + 1)
        }
        
    func paired(with: Tuple) -> TupleElementPairs
        {
        zip(self.elements,with.elements).map{TupleElementPair(lhs: $0.0,rhs: $0.1)}
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        self.elements = try self.elements.map{try $0.initializeType(inContext: context)}
        }
        
    public override func deepCopy() -> Self
        {
        let copy = super.deepCopy()
        copy.elements = self.elements.map{$0.deepCopy()}
        return(copy)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        for element in self.elements
            {
            try element.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
    }
