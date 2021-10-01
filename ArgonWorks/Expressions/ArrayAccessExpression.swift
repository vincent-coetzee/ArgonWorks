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
    
    public required init?(coder: NSCoder)
        {
        self.array = coder.decodeObject(forKey: "array") as! Expression
        self.index = coder.decodeObject(forKey: "index") as! Expression
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.array,forKey: "array")
        coder.encode(self.index,forKey: "indexx")
        }
        
    init(array:Expression,index:Expression)
        {
        self.array = array
        self.index = index
        super.init()
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
