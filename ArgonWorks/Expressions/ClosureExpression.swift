//
//  ClosureExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public class ClosureExpression: Expression
    {
    public let closure: Closure
    
    public init(_ closure:Closure)
        {
        self.closure = closure
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.closure = coder.decodeObject(forKey: "closure") as! Closure
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.closure,forKey: "closure")
        super.encode(with: coder)
        }
        
    public override func allocateAddresses(using allocator:AddressAllocator)
        {
        self.closure.allocateAddresses(using: allocator)
        }
        
    public override func realize(using: Realizer)
        {
        self.closure.realize(using: using)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        self.closure.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
        try self.closure.emitCode(into: instance,using: using)
        }
    }
