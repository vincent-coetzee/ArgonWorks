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
    public var symbols = Symbols()
    
    required init(label:Label)
        {
        self.block = Block()
        self.buffer = T3ABuffer()
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder)
        {
        self.block = coder.decodeObject(forKey: "block") as! Block
        self.symbols = coder.decodeObject(forKey: "symbols") as! Symbols
        self.buffer = coder.decodeObject(forKey: "buffer") as! T3ABuffer
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.symbols,forKey: "symbols")
        coder.encode(self.block,forKey: "block")
        coder.encode(self.buffer,forKey: "buffer")
        super.encode(with: coder)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for symbol in self.symbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(label: label))
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
