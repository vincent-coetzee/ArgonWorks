//
//  Closure.swift
//  Closure
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class Closure:Invocable,Scope
    {
    public var enclosingStackFrame: StackFrame
        {
        self
        }
        
    public var isSlotScope: Bool
        {
        false
        }
        
    public override var enclosingScope: Scope
        {
        return(self)
        }
        
    public var isMethodInstanceScope: Bool
        {
        return(false)
        }
        
    public var isClosureScope: Bool
        {
        return(true)
        }
        
    public var isInitializerScope: Bool
        {
        return(false)
        }
        
    public let block: Block
    public let buffer: T3ABuffer
    
    required init(label:Label)
        {
        self.block = Block()
        self.buffer = T3ABuffer()
        super.init(label: label)
        self.block.setParent(self)
        }
    
    public required init?(coder: NSCoder)
        {
        self.block = coder.decodeObject(forKey: "block") as! Block
        self.buffer = coder.decodeObject(forKey: "buffer") as! T3ABuffer
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.block,forKey: "block")
        coder.encode(self.buffer,forKey: "buffer")
        super.encode(with: coder)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for symbol in self.localSymbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(label: label))
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let newClosure = Closure(label: self.label)
        newClosure.localSymbols = self.localSymbols.map{$0.substitute(from: substitution)}
        newClosure.parameters = self.parameters.map{$0.substitute(from: substitution)}
        newClosure.returnType = substitution.substitute(self.returnType)
        for block in self.block.blocks
            {
            newClosure.block.addBlock(substitution.substitute(block))
            }
        self.type = substitution.substitute(self.type!)
        return(newClosure as! Self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)CLOSURE: \(self.type.displayString)")
        for block in self.block.blocks
            {
            block.display(indent: indent + "\t")
            }
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        for symbol in self.localSymbols
            {
            try symbol.initializeType(inContext: context)
            }
        for block in block.blocks
            {
            try block.initializeType(inContext: context)
            }
        self.type = TypeFunction(label: self.label,types: self.parameters.map{$0.type!},returnType: self.returnType)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        for symbol in self.localSymbols
            {
            try symbol.initializeTypeConstraints(inContext: context)
            }
        for block in self.block.blocks
            {
            try block.initializeTypeConstraints(inContext: context)
            }
        }
        
    public override func allocateAddresses(using allocator:AddressAllocator)
        {
        super.allocateAddresses(using: allocator)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        super.analyzeSemantics(using: analyzer)
        self.block.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
        try self.block.emitCode(into: self.buffer,using: using)
        }
    }
