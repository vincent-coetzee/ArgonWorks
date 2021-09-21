//
//  ReturnBlock.swift
//  ReturnBlock
//
//  Created by Vincent Coetzee on 8/8/21.
//

import Foundation

public class ReturnBlock: Block
    {
    public override var isReturnBlock: Bool
        {
        return(true)
        }
        
    public var value: Expression = Expression()
    
    public override func realize(using realizer:Realizer)
        {
        self.value.realize(using: realizer)
        super.realize(using: realizer)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.value.analyzeSemantics(using: analyzer)
        let returnValue = self.methodInstance.returnType
        let valueType = self.value.resultType
        if !valueType.isEquivalent(to: returnValue)
            {
            analyzer.compiler.reportingContext.dispatchError(at: self.declaration!, message: "The type of the return expression \(valueType.label) does not match that of the method \(returnValue)")
            }
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.value.emitCode(into: buffer,using: generator)
        buffer.append(.STORE,self.value.place,.none,.register(.RET))
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)RETURN BLOCK")
        self.value.dump(depth: depth+1)
        }
    }
