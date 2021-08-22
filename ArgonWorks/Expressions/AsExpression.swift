//
//  AsExpression.swift
//  AsExpression
//
//  Created by Vincent Coetzee on 19/8/21.
//

import Foundation

public class AsExpression: Expression
    {
    public override var resultType: TypeResult
        {
        return(.class(into))
        }
        
    private let lhs: Expression
    private let into: Class
    
    init(_ lhs:Expression,into: Class)
        {
        self.lhs = lhs
        self.into = into
        super.init()
        }
        
    public override var displayString: String
        {
        return("\(self.lhs.displayString) as \(self.into.displayString)")
        }

    public override func realize(using realizer:Realizer)
        {
        self.lhs.realize(using: realizer)
        self.into.realize(using: realizer)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.lhs.analyzeSemantics(using: analyzer)
        self.into.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        print("AsExpression NEEDS TO GENERATE CODE")
        }
    }
