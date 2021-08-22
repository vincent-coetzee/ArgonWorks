//
//  LoopBlock.swift
//  LoopBlock
//
//  Created by Vincent Coetzee on 12/8/21.
//

import Foundation

public class LoopBlock: Block
    {
    private let startExpressions: Array<Expression>
    private let endExpression: Expression
    private let updateExpressions: Array<Expression>
    
    init(start: Array<Expression>,end: Expression,update: Array<Expression>)
        {
        self.startExpressions = start
        self.endExpression = end
        self.updateExpressions = update
        super.init()
        }
        
   public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for expression in startExpressions
            {
            expression.analyzeSemantics(using: analyzer)
            }
        self.endExpression.analyzeSemantics(using: analyzer)
        for expression in updateExpressions
            {
            expression.analyzeSemantics(using: analyzer)
            }
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)LOOP")
        for expression in self.startExpressions
            {
            expression.dump(depth: depth+1)
            }
        self.endExpression.dump(depth: depth+1)
        for expression in self.updateExpressions
            {
            expression.dump(depth: depth+1)
            }
        for block in self.blocks
            {
            block.dump(depth: depth + 1)
            }
        }
        
    public override func emitCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        for expression in self.startExpressions
            {
            try expression.emitCode(into: into, using: using)
            }
        let marker = into.fromHere()
        for block in self.blocks
            {
            try block.emitCode(into: into,using: using)
            }
        for expression in self.updateExpressions
            {
            try expression.emitCode(into: into,using: using)
            }
        try self.endExpression.emitCode(into: into,using: using)
        do
            {
            into.append(.BRT,self.endExpression.place,.none,.label(try into.toHere(marker)))
            }
        catch let error
            {
            using.compiler.reportingContext.dispatchError(at: .zero, message: "\(error) Code generator has caught a throws when attemping to dereference a label marker, this is because some idiot used the marker incorrectly, fix it")
            }
        }
    }
