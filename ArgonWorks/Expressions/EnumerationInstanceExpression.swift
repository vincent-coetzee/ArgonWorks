//
//  EnumerationInstanceExpression.swift
//  EnumerationInstanceExpression
//
//  Created by Vincent Coetzee on 17/8/21.
//

import Foundation

public class EnumerationInstanceExpression: Expression
    {
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
        
    public override func visit(visitor: Visitor) throws
        {
        try self.lhs.visit(visitor: visitor)
        try self.theCase.visit(visitor: visitor)
        for expression in self.associatedValues!
            {
            try expression.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        fatalError()
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
        var count:Argon.Integer = 1
        instance.append("PUSH",.address(self.theCase.memoryAddress),.none,.none)
        if self.theCase.hasAssociatedTypes
            {
            let values = self.associatedValues!
            for value in values
                {
                try value.emitCode(into: instance,using: generator)
                instance.append("PUSH",value.place,.none,.none)
                count += 1
                }
            }
//        instance.append("CALL",.relocatable(.address(function.memoryAddress)),.none,.none)
//        instance.append("ADD",.stackPointer,.integer(count * 8),.stackPointer)
        self._place = .returnValue
        }
    }
