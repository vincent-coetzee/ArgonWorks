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
        
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        let realSymbols = self.symbols.map{generator.payload.symbolRegistry.registerSymbol($0)}
        let array = generator.payload.staticSegment.allocateArray(size: realSymbols.count)
        let arrayPointer = ArrayPointer(dirtyAddress: array)!
        for aSymbol in realSymbols
            {
            arrayPointer.append(aSymbol)
            }
        if let declaration = self.declaration
            {
            buffer.append(lineNumber: declaration.line)
            }
        let codeLabel = buffer.nextLabel()
        buffer.append(.HAND,.address(array),.label(codeLabel),.none)
        let label = buffer.nextLabel()
        buffer.append(.BRA,.label(label),.none,.none)
        buffer.pendingLabel = codeLabel
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: generator)
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
