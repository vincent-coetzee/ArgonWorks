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
    
    init(coder: NSCoder,forKey: String)
        {
        let kind = coder.decodeInteger(forKey: forKey + "kind")
        if kind == 1
            {
            self = .literal(coder.decodeLiteral(forKey: forKey + "literal"))
            }
        else if kind == 2
            {
            self = .slot(coder.decodeObject(forKey: forKey + "slot") as! LocalSlot)
            }
        else if kind == 3
            {
            self = .tuple(coder.decodeObject(forKey: forKey + "tuple") as! Tuple)
            }
        else if kind == 4
            {
            self = .expression(coder.decodeObject(forKey: forKey + "expression") as! Expression)
            }
        else if kind == 5
            {
            self = .type(coder.decodeObject(forKey: forKey + "type") as! Type)
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
        
    public func freshTypeVariable(inContext context: TypeContext) -> TupleElement
        {
        switch(self)
            {
            case .slot(let slot):
                return(.slot(slot.freshTypeVariable(inContext: context) as! LocalSlot))
            case .literal:
                return(self)
            case .expression(let expression):
                return(.expression(expression.freshTypeVariable(inContext: context)))
            case .tuple(let tuple):
                return(.tuple(tuple.freshTypeVariable(inContext: context)))
            case .type(let type):
                return(.type(type.freshTypeVariable(inContext: context)))
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
        
    public func initializeTypeConstraints(inContext context: TypeContext)
        {
        switch(self)
            {
            case .slot(let slot):
                slot.initializeTypeConstraints(inContext: context)
            case .tuple(let tuple):
                tuple.initializeTypeConstraints(inContext: context)
            case .expression(let expression):
                expression.initializeTypeConstraints(inContext: context)
            default:
                break
            }
        }
        
        
    func encode(with coder: NSCoder,forKey: String)
        {
        switch(self)
            {
            case .literal(let value):
                coder.encode(1,forKey: forKey + "kind")
                coder.encodeLiteral(value,forKey: forKey + "literal")
            case .slot(let slot):
                coder.encode(2,forKey: forKey + "kind")
                coder.encode(slot,forKey: forKey + "slot")
            case .tuple(let tuple):
                coder.encode(3,forKey: forKey + "kind")
                coder.encode(tuple,forKey: forKey + "tuple")
            case .expression(let expression):
                coder.encode(4,forKey: forKey + "kind")
                coder.encode(expression,forKey: forKey + "expression")
            case .type(let type):
                coder.encode(5,forKey: forKey + "kind")
                coder.encode(type,forKey: forKey + "type")
            }
        }
        
    @discardableResult
    public func initializeType(inContext context: TypeContext) -> Type
        {
        switch(self)
            {
            case .literal(let literal):
                return(literal.type(inContext: context)!)
            case .slot(let slot):
                return(self.slotType(slot: slot,inContext: context))
            case .tuple(let tuple):
                tuple.initializeType(inContext: context)
                return(tuple.type)
            case .expression(let expression):
                expression.initializeType(inContext: context)
                return(expression.type)
            case .type(let type):
                return(type)
            }
        }
        
    private func slotType(slot: Slot,inContext context: TypeContext) -> Type
        {
        if slot.type.isTypeVariable
            {
            if let slotType = context.lookupBinding(atLabel: slot.label)
                {
                slot.type = slotType
                return(slotType)
                }
            else
                {
                context.bind(slot.type,to: slot.label)
                return(slot.type)
                }
            }
        else if slot.type.isClass || slot.type.isEnumeration
            {
            context.bind(slot.type,to: slot.label)
            return(slot.type)
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
        
//    func setParent(_ parent: Parent)
//        {
//        switch(self)
//            {
//            case .expression(let expression):
//                expression.setParent(parent)
//            default:
//                break
//            }
//        }
        
    func assign(from: Expression,into: T3ABuffer,using: CodeGenerator) throws
        {
        switch(self)
            {
            case .slot(let slot):
                try slot.assign(from: from,into: into,using: using)
            case .literal:
                fatalError("Can not assign into a literal.")
            case .expression(let expression):
                try expression.assign(from: from,into: into,using: using)
            case .tuple(let tuple):
                try tuple.assign(from: from,into: into,using: using)
            case .type:
                fatalError("Can not assign into a type.")
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
    internal var type: Type = Type()
//    internal var parent: Parent = .none
//        {
//        didSet
//            {
//            self.elements.forEach{$0.setParent(parent)}
//            }
//        }
    
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
        self.elements = []
        for index in 0..<count
            {
            self.elements.append(TupleElement(coder: coder,forKey: "element\(index)"))
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
        var index = 0
        for element in self.elements
            {
            element.encode(with: coder,forKey: "element\(index)")
            index += 1
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
        
    public func assign(from: Expression,into: T3ABuffer,using: CodeGenerator) throws
        {
        guard from is TupleExpression else
            {
            fatalError("A tuple can only be assigned to from a TupleExpression.")
            }
        let rhs = from as! TupleExpression
        let tuple = rhs.tuple
        guard tuple.elements.count == self.elements.count else
            {
            fatalError("Tuple arities do not match.")
            }
        for (left,right) in zip(self.elements,tuple.elements)
            {
            guard case let TupleElement.expression(expression) = right else
                {
                fatalError("Tuple element can only be assigned from an expression.")
                }
            try left.assign(from: expression, into: into, using: using)
            }
        }
        
    public func freshTypeVariable(inContext context: TypeContext) -> Tuple
        {
        Tuple(elements: self.elements.map{$0.freshTypeVariable(inContext: context)})
        }
        
    internal func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        Tuple(elements: self.elements.map{substitution.substitute($0)}) as! Self
        }
        
    public func initializeType(inContext context: TypeContext)
        {
        self.elements.forEach{$0.initializeType(inContext: context)}
        let types = self.elements.map{$0.type!}
        let label = types.map{$0.displayString}.joined(separator: "x")
        self.type = Argon.addType(TypeConstructor(label: label,generics: types))
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.elements.forEach{$0.initializeTypeConstraints(inContext: context)}
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
