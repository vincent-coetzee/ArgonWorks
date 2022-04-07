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
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        let realSymbols = self.symbols.map{generator.payload.symbolRegistry.registerSymbol($0)}
        let array = generator.payload.staticSegment.allocateArray(size: realSymbols.count)
        let arrayPointer = ArrayPointer(dirtyAddress: array,argonModule: self.container.argonModule)!
        for aSymbol in realSymbols
            {
            arrayPointer.append(Word(integer: aSymbol))
            }
        if let declaration = self.declaration
            {
            buffer.add(lineNumber: declaration.line)
            }
        let codeLabel = buffer.nextLabel
        buffer.add(.HAND,.address(array),codeLabel.operand)
        let label = buffer.nextLabel
        buffer.add(.BR,label.operand)
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
