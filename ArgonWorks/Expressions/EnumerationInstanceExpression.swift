//
//  EnumerationInstanceExpression.swift
//  EnumerationInstanceExpression
//
//  Created by Vincent Coetzee on 17/8/21.
//

import Foundation

public class EnumerationInstanceExpression: Expression
    {
    public override var resultType: Type
        {
        return(self.enumeration.isNil ? .error(.mismatch) : .enumeration(self.enumeration!))
        }
        
    public override var displayString: String
        {
        if self.enumeration.isNil
            {
            return("CASE: \(self.caseLabel)")
            }
        let values = "(" + self.associatedValues!.map{$0.displayString}.joined(separator: ",") + ")"
        return("\(self.enumeration!.label) \(self.theCase!.label) \(values)")
        }
        
    public let enumeration: Enumeration?
    public let theCase: EnumerationCase?
    public let associatedValues: Array<Expression>?
    public let caseLabel: String
    
    init(caseLabel: String,enumeration: Enumeration?,enumerationCase aCase: EnumerationCase?,associatedValues: Array<Expression>?)
        {
        self.caseLabel = caseLabel
        self.enumeration = enumeration
        self.theCase = aCase
        self.associatedValues = associatedValues
        }
        
    public override func realize(using realizer: Realizer)
        {
        self.enumeration?.realize(using: realizer)
        self.theCase?.realize(using: realizer)
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
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        print("EnumerationInstanceExpression NEEDS TO GENERATE CODE")
        }
    }
