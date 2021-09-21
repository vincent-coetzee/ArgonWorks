//
//  ArrayAccessExpression.swift
//  ArrayAccessExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ArrayAccessExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.array.displayString)[\(self.index.displayString)]")
        }
        
    public override var isLValue: Bool
        {
        return(true)
        }
        
    private let array:Expression
    private let index:Expression
    
    init(array:Expression,index:Expression)
        {
        self.array = array
        self.index = index
        }
        
    public override var resultType: Type
        {
        self.array.resultType
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.array.analyzeSemantics(using: analyzer)
        self.index.analyzeSemantics(using: analyzer)
        }
        
    public override func realize(using realizer:Realizer)
        {
        self.array.realize(using: realizer)
        self.index.realize(using: realizer)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        print("ArrayAccessExpression NEEDS TO GENERATE CODE")
        }
    }
