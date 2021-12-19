//
//  HandlerBlock.swift
//  HandlerBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class HandlerBlock: ClosureBlock
    {
    public var symbols = Array<String>()
    
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        }
        
    public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        let literal = Literal.array(Argon.addStatic(StaticArray(self.symbols.map{Literal.symbol(Argon.addStatic(StaticSymbol(string: $0)))})))
        let codeLabel = buffer.nextLabel()
        buffer.append(nil,"HAND",.literal(literal),.label(codeLabel),.none)
        let label = buffer.nextLabel()
        buffer.append(nil,"BR",.label(label),.none,.none)
        buffer.pendingLabel = codeLabel
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: using)
            }
        buffer.pendingLabel = label
        }
        
    public override func display(indent: String)
        {
        print("\(indent)HANDLER: \(Swift.type(of: self))")
        print("\(indent)SYMBOLS: \(self.symbols)")
        for block in self.blocks
            {
            block.display(indent: indent + "\t")
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        for block in self.blocks
            {
            block.initializeTypeConstraints(inContext: context)
            }
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        for block in self.blocks
            {
            block.initializeType(inContext: context)
            }
        self.type = context.voidType
        }
    }
