//
//  IfBlock.swift
//  IfBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class IfBlock: Block
    {
    private let condition:Expression
    internal var elseBlock: Block?
        {
        didSet
            {
            self.elseBlock?.setParent(self)
            }
        }
    
    public init(condition: Expression)
        {
        self.condition = condition
        super.init()
        self.condition.setParent(self)
        }
        
    public required init?(coder: NSCoder)
        {
        self.condition = Expression()
        super.init(coder: coder)
        }
    
    public override func realize(using realizer:Realizer)
        {
        super.realize(using: realizer)
        self.condition.realize(using: realizer)
        for block in self.blocks
            {
            block.realize(using: realizer)
            }
        self.elseBlock?.realize(using: realizer)
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)IF")
        condition.dump(depth: depth+1)
        for block in self.blocks
            {
            block.dump(depth: depth + 1)
            }
        }
        
   public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.condition.analyzeSemantics(using: analyzer)
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        self.elseBlock?.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        let outLabel = buffer.nextLabel()
        try self.condition.emitCode(into: buffer,using: using)
        buffer.append(nil,"BRF",self.condition.place,.none,.label(outLabel))
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: using)
            }
        if self.elseBlock.isNotNil
            {
            buffer.pendingLabel = outLabel
            try self.elseBlock!.emitCode(into: buffer,using: using)
            }
        else
            {
            buffer.pendingLabel = outLabel
            }
        }
    }
    
