//
//  Closure.swift
//  Closure
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class Closure:Invocable
    {
    public var block: Block
    public let buffer: InstructionBuffer
    
    required init(label:Label)
        {
        self.block = Block()
        self.buffer = InstructionBuffer()
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder)
        {
        self.block = coder.decodeObject(forKey: "block") as! Block
        self.buffer = coder.decodeObject(forKey: "buffer") as! InstructionBuffer
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
        return(self.parentScope?.lookup(label: label))
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        self.localSymbols = self.localSymbols.map{$0.substitute(from: substitution)}
        self.parameters = self.parameters.map{$0.substitute(from: substitution)}
        self.returnType = substitution.substitute(self.returnType)
        self.block = substitution.substitute(self.block)
        self.type = substitution.substitute(self.type)
        return(self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)CLOSURE: \(self.type.displayString)")
        for block in self.block.blocks
            {
            block.display(indent: indent + "\t")
            }
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        for symbol in self.localSymbols
            {
            symbol.initializeType(inContext: context)
            }
        for block in block.blocks
            {
            block.initializeType(inContext: context)
            }
        self.type = TypeFunction(label: "Closure",types: self.parameters.map{$0.type},returnType: self.returnType)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        for symbol in self.localSymbols
            {
            symbol.initializeTypeConstraints(inContext: context)
            }
        for block in self.block.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        let returnBlocks = self.block.returnBlocks
        for returnBlock in returnBlocks
            {
            context.append(TypeConstraint(left: self.returnType,right: returnBlock.type,origin: .symbol(self)))
            }
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        super.analyzeSemantics(using: analyzer)
        self.block.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.block.emitCode(into: self.buffer,using: using)
        }
    }
