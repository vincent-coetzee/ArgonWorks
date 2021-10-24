//
//  EnumerationInstanceExpression.swift
//  EnumerationInstanceExpression
//
//  Created by Vincent Coetzee on 17/8/21.
//

import Foundation

public class EnumerationInstanceExpression: Expression
    {
    public override var type: Type
        {
        return(self.theCase.enumeration.type)
        }
        
    public override var displayString: String
        {
        "ERROR"
        }
        
    public let lhs: Expression
    public let theCase: EnumerationCase
    public let associatedValues: Array<Expression>?
    
    required init?(coder: NSCoder)
        {
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        self.theCase = coder.decodeObject(forKey:"theCase") as! EnumerationCase
        self.associatedValues = coder.decodeObject(forKey:"associatedValues") as? Array<Expression>
        super.init(coder: coder)
        }
        
 
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.theCase,forKey: "theCase")
        coder.encode(self.associatedValues,forKey: "associatedValues")
        }
        
    init(lhs: Expression,enumerationCase aCase: EnumerationCase,associatedValues: Array<Expression>?)
        {
        self.lhs = lhs
        self.theCase = aCase
        self.associatedValues = associatedValues
        super.init()
        }
        
    public override func realize(using realizer: Realizer)
        {
        self.lhs.realize(using: realizer)
        if self.associatedValues.isNotNil
            {
            for value in self.associatedValues!
                {
                value.realize(using: realizer)
                }
            }
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        fatalError()
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        print("EnumerationInstanceExpression NEEDS TO GENERATE CODE")
        }
    }
