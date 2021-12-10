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
            case .slot(let slot):
                return(slot.displayString)
            case .tuple(let tuple):
                return(tuple.displayString)
            case .expression(let expression):
                return(expression.displayString)
            case .literal(let literal):
                return(literal.displayString)
            case .type(let type):
                return(type.displayString)
            }
        }
        
    public var type: Type?
        {
        switch(self)
            {
            case .slot(let slot):
                return(slot.type)
            case .literal(let literal):
                return(literal.type)
            case .expression(let expression):
                return(expression.type)
            case .tuple(let tuple):
                return(tuple.type)
            case .type(let type):
                return(type)
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
        
    case type(Type)
    case literal(Literal)
    case slot(Slot)
    case tuple(Tuple)
    case expression(Expression)
    
    init(coder: NSCoder)
        {
        let kind = coder.decodeInteger(forKey: "kind")
        if kind == 1
            {
            self = .literal(Literal(coder: coder,forKey: "literal"))
            }
        else if kind == 2
            {
            self = .slot(coder.decodeObject(forKey: "slot") as! LocalSlot)
            }
        else if kind == 3
            {
            self = .tuple(coder.decodeObject(forKey: "tuple") as! Tuple)
            }
        else if kind == 4
            {
            self = .expression(coder.decodeObject(forKey: "expression") as! Expression)
            }
        else if kind == 5
            {
            self = .type(coder.decodeObject(forKey: "type") as! Type)
            }
        else
            {
            fatalError()
            }
        }
        
    public func substitute(from substitution: TypeContext.Substitution) -> TupleElement
        {
        switch(self)
            {
            case .slot(let slot):
                return(.slot(substitution.substitute(slot) as! LocalSlot))
            case .literal(let literal):
                return(.literal(substitution.substitute(literal)))
            case .expression(let expression):
                return(.expression(substitution.substitute(expression)))
            case .tuple(let tuple):
                return(.tuple(substitution.substitute(tuple)))
            case .type(let type):
                return(.type(substitution.substitute(type)))
            }
        }
        
    public func visit(visitor: Visitor) throws
        {
        switch(self)
            {
            case .slot(let slot):
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
            case .slot(let slot):
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
                value.encode(with: coder,forKey: "literal")
            case .slot(let slot):
                coder.encode(2,forKey: "kind")
                coder.encode(slot,forKey: "slot")
            case .tuple(let tuple):
                coder.encode(3,forKey: "kind")
                coder.encode(tuple,forKey: "tuple")
            case .expression(let expression):
                coder.encode(4,forKey: "kind")
                coder.encode(expression,forKey: "expression")
            case .type(let type):
                coder.encode(5,forKey: "kind")
                coder.encode(type,forKey: "type")
            }
        }
        
    @discardableResult
    public func initializeType(inContext context: TypeContext) throws -> Type
        {
        switch(self)
            {
            case .literal(let literal):
                return(literal.type(inContext: context)!)
            case .slot(let slot):
                return(self.slotType(slot: slot,inContext: context))
            case .tuple(let tuple):
                try tuple.initializeType(inContext: context)
                return(tuple.type!)
            case .expression(let expression):
                try expression.initializeType(inContext: context)
                return(expression.type!)
            case .type(let type):
                return(type)
            }
        }
        
    private func slotType(slot: Slot,inContext context: TypeContext) -> Type
        {
        if slot.type.isNil
            {
            if let slotType = context.lookupBinding(atLabel: slot.label)
                {
                slot.type = slotType
                return(slotType)
                }
            else
                {
                slot.type = context.freshTypeVariable()
                context.bind(slot.type!,to: slot.label)
                return(slot.type!)
                }
            }
        else if slot.type!.isTypeVariable
            {
            if let slotType = context.lookupBinding(atLabel: slot.label)
                {
                slot.type = slotType
                return(slotType)
                }
            else
                {
                context.bind(slot.type!,to: slot.label)
                return(slot.type!)
                }
            }
        else if slot.type!.isClass || slot.type!.isEnumeration
            {
            context.bind(slot.type!,to: slot.label)
            return(slot.type!)
            }
        else
            {
            fatalError("This should not happen.")
            }
        }
        
    public func display(indent: String)
        {
        switch(self)
            {
            case .slot(let slot):
                slot.display(indent: indent + "\t")
            case .literal(let literal):
                literal.display(indent: indent + "\t")
            case .expression(let expression):
                expression.display(indent: indent + "\t")
            case .tuple(let tuple):
                tuple.display(indent: indent + "\t")
            case .type(let type):
                type.display(indent: indent + "\t")
            }
        }
        
    func setParent(_ parent: Parent)
        {
        switch(self)
            {
            case .expression(let expression):
                expression.setParent(parent)
            default:
                break
            }
        }
    }

    
public class Tuple: NSObject,Collection,VisitorReceiver,NSCoding
    {
    public var isEmpty: Bool
        {
        self.elements.count == 0
        }
        
    public var displayString: String
        {
        let strings = self.elements.map{$0.displayString}.joined(separator: ",")
        return("Tuple(\(strings))")
        }
        
    public var startIndex: Int
        {
        return(self.elements.startIndex)
        }
        
    public var endIndex: Int
        {
        return(self.elements.startIndex)
        }
        
    internal private(set) var elements = Array<TupleElement>()
    internal var type: Type?
    internal var parent: Parent = .none
        {
        didSet
            {
            self.elements.forEach{$0.setParent(parent)}
            }
        }
    
    override init()
        {
        super.init()
        }
        
    init(_ elements: TupleElement...)
        {
        self.elements = elements
        super.init()
        }
        
    init(_ types: Type...)
        {
        self.elements = types.map{TupleElement.type($0)}
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        let count = coder.decodeInteger(forKey: "count")
        self.parent = coder.decodeParent(forKey: "parent")!
        for _ in 0..<count
            {
            self.elements.append(TupleElement(coder: coder))
            }
        super.init()
        }
        
    init(_ slot: LocalSlot)
        {
        self.elements.append(.slot(slot))
        super.init()
        }
        
    init(_ expression: Expression)
        {
        self.elements.append(.expression(expression))
        super.init()
        }
        
    convenience init(elements: Array<TupleElement>)
        {
        self.init()
        self.elements = elements
        }
        
    convenience init(_ expressions: Expressions)
        {
        self.init()
        self.elements = expressions.map{TupleElement.expression($0)}
        }

    public func encode(with coder:NSCoder)
        {
        coder.encode(self.elements.count,forKey: "count")
        coder.encodeParent(self.parent,forKey: "parent")
        for element in self.elements
            {
            element.encode(with: coder)
            }
        }
        
    internal func append(_ slot: Slot)
        {
        self.elements.append(.slot(slot))
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
        
    internal func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        Tuple(elements: self.elements.map{substitution.substitute($0)}) as! Self
        }
        
    public func initializeType(inContext context: TypeContext) throws
        {
        try self.elements.forEach{try $0.initializeType(inContext: context)}
        let types = self.elements.map{$0.type!}
        let label = types.map{$0.displayString}.joined(separator: "x")
        self.type = TypeConstructor(label: label,generics: types)
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.elements.forEach{try $0.initializeTypeConstraints(inContext: context)}
        }
        
    public func visit(visitor: Visitor) throws
        {
        for element in self.elements
            {
            try element.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public  func display(indent: String)
        {
        print("\(indent)TUPLE:")
        for element in self.elements
            {
            element.display(indent: indent + "\t")
            }
        }
    }
