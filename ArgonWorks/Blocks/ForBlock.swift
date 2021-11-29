//
//  ForBlock.swift
//  ForBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ForBlock: Block
    {
    private var inductionSlot:LocalSlot
    private var elements: Expression
    
    init(inductionSlot:LocalSlot,elements:Expression)
        {
        self.inductionSlot = inductionSlot
        self.elements = elements
        super.init()
        }
        
    public override func deepCopy() -> Self
        {
        let copy = super.deepCopy()
        copy.inductionSlot = self.inductionSlot.deepCopy()
        copy.elements = self.elements.deepCopy()
        return(copy)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.inductionSlot.initializeType(inContext: context)
        try self.elements.initializeType(inContext: context)
        for block in self.blocks
            {
            try block.initializeType(inContext: context)
            }
        self.type = context.voidType
        }

    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.elements.initializeTypeConstraints(inContext: context)
        for block in self.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        let collectionClass = (self.enclosingScope.lookup(name: Name("\\\\Argon\\Collection")) as! TypeClass).theClass
        context.append(SubTypeConstraint(subtype: self.elements.type,supertype: TypeClass(class: collectionClass, generics: [self.inductionSlot.type]),origin: .block(self)))
        context.append(SubTypeConstraint(subtype: self.elements.type,supertype: context.iterableType,origin: .block(self)))
        }
        
    public override func substitute(from context: TypeContext)
        {
        super.substitute(from: context)
        self.inductionSlot.type = self.inductionSlot.type.substitute(from: context)
        self.elements.substitute(from: context)
        }
        
    public required init?(coder: NSCoder)
        {
        self.inductionSlot = coder.decodeObject(forKey:"inductionSlot") as! LocalSlot
        self.elements = coder.decodeObject(forKey:"elements") as! Expression
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.inductionSlot = LocalSlot(label:"")
        self.elements = Expression()
        super.init()
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.inductionSlot,forKey:"inductionSlot")
        coder.encode(self.elements,forKey:"elements")
        super.encode(with: coder)
        }
    }
