//
//  ExpressionBlock.swift
//  ExpressionBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ExpressionBlock: Block
    {
    private let expression:Expression
    public var place: Instruction.Operand = .none
    
    init(_ expression:Expression)
        {
        self.expression = expression
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        fatalError()
        }
        
    public override func realize(using realizer:Realizer)
        {
        super.realize(using: realizer)
        self.expression.realize(using: realizer)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        super.analyzeSemantics(using: analyzer)
//        let type = self.expression.resultType
        }
        
    public override func emitCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.expression.emitCode(into: into,using: using)
        self.place = self.expression.place
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)EXPRESSION BLOCK")
        self.expression.dump(depth: depth+1)
        }
    }
