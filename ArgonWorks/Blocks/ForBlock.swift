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
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let forBlock = ForBlock(inductionSlot: self.inductionSlot.freshTypeVariable(inContext: context), elements: self.elements.freshTypeVariable(inContext: context))
        for block in self.blocks
            {
            let newBlock = block.freshTypeVariable(inContext: context)
            forBlock.addBlock(newBlock)
            }
        forBlock.type = self.type.freshTypeVariable(inContext: context)
        forBlock.locations = self.locations
        forBlock.issues = self.issues
        return(forBlock as! Self)
        }
        
    internal override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let forBlock = ForBlock(inductionSlot: substitution.substitute(self.inductionSlot) as! LocalSlot, elements: substitution.substitute(self.elements))
        for block in self.blocks
            {
            let newBlock = substitution.substitute(block)
            newBlock.type = substitution.substitute(block.type)
            forBlock.addBlock(newBlock)
            }
        forBlock.type = substitution.substitute(self.type)
        forBlock.locations = self.locations
        forBlock.issues = self.issues
        return(forBlock as! Self)
        }

    public override func initializeType(inContext context: TypeContext)
        {
        self.inductionSlot.initializeType(inContext: context)
        self.elements.initializeType(inContext: context)
        for block in self.blocks
            {
            block.initializeType(inContext: context)
            }
        self.type = ArgonModule.shared.void
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.inductionSlot.initializeTypeConstraints(inContext: context)
        self.elements.initializeTypeConstraints(inContext: context)
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        context.append(SubTypeConstraint(subtype: self.elements.type,supertype: ArgonModule.shared.iterable,origin: .block(self)))
        if let elementsType = self.elements.type as? TypeConstructor
            {
            if elementsType.generics.count > 0
                {
                context.append(TypeConstraint(left: elementsType.generics[0],right: self.inductionSlot.type,origin: .block(self)))
                }
            }
        context.extended(withContentsOf: [])
            {
            newContext in
            let sub = newContext.unify()
            self.inductionSlot = sub.substitute(self.inductionSlot)
            self.elements = sub.substitute(self.elements)
            }
        }
        
    public override func inferType(inContext context: TypeContext)
        {
        self.inductionSlot.inferType(inContext: context)
        self.elements.inferType(inContext: context)
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        let collectionClass = ArgonModule.shared.collection
        context.append(SubTypeConstraint(subtype: self.elements.type,supertype: collectionClass.withGenerics([self.inductionSlot.type]),origin: .block(self)))
        context.append(SubTypeConstraint(subtype: self.elements.type,supertype: ArgonModule.shared.iterable,origin: .block(self)))
        self.type = ArgonModule.shared.void
        }
        
    public override func display(indent: String)
        {
        print("\(indent)FOR")
        print("\(indent)\tINDUCTION SLOT \(self.inductionSlot) \(self.inductionSlot.type.displayString)")
        print("\(indent)\tELEMENTS \(self.elements) \(self.elements.type.displayString)")
        for block in self.blocks
            {
            block.display(indent: indent + "\t")
            }
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        if let declaration = self.declaration
            {
            buffer.add(lineNumber: declaration.line)
            }
//        buffer.add(.ENTER,.integer(1),.none,.none)
        try self.elements.emitValueCode(into: buffer,using: using)
        let type = ArgonModule.shared.iterable
        let temporary = buffer.nextTemporary
        buffer.add(.CAST,self.elements.place,.address(type.memoryAddress),temporary)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.inductionSlot.visit(visitor: visitor)
        try self.elements.visit(visitor: visitor)
        try super.visit(visitor: visitor)
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
