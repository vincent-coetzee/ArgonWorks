//
//  Closure.swift
//  Closure
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class Closure:Invokable
    {
    public let block: Block
    public let buffer: T3ABuffer
    
    required override init(label:Label)
        {
        self.block = Block()
        self.buffer = T3ABuffer()
        super.init(label: label)
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
        
    public override func allocateAddresses(using allocator:AddressAllocator)
        {
        super.allocateAddresses(using: allocator)
        }
        
    public override func realize(using: Realizer)
        {
        super.realize(using: using)
        self.block.realize(using: using)
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
