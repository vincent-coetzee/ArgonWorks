//
//  AssignmentExpression.swift
//  AssignmentExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class AssignmentExpression: Expression
    {
    private let rhs: Expression
    private let lhs: Expression
    private let operation: Token.Operator
    
    public override var resultType: TypeResult
        {
        return(.undefined)
        }
        
    init(_ lhs:Expression,_ operation: Token.Operator,_ rhs:Expression)
        {
        self.rhs = rhs
        self.lhs = lhs
        self.operation = operation
        super.init()
        }
        
    public override var displayString: String
        {
        return("\(self.lhs.displayString) \(self.operation) \(self.rhs.displayString)")
        }

    public override func realize(using realizer:Realizer)
        {
        self.lhs.realize(using: realizer)
        self.rhs.realize(using: realizer)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.lhs.analyzeSemantics(using: analyzer)
        self.rhs.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.lhs.emitCode(into: instance,using: generator)
        try self.rhs.emitCode(into: instance,using: generator)
        instance.append(.STORE,self.lhs.place,.none,rhs.place)
        self._place = rhs.place
        }
    }
