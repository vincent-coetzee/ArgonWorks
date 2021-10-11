//
//  SuffixExpression.swift
//  SuffixExpression
//
//  Created by Vincent Coetzee on 10/8/21.
//

import Foundation

public class SuffixExpression: Expression
    {
    public override var type: Type
        {
        return(self.expression.type)
        }
        
    public override var displayString: String
        {
        return("\(self.expression.displayString) \(self.operation)")
        }
        
    public let operationName: String
    public let expression: Expression
    
    required init?(coder: NSCoder)
        {
        self.operationName = coder.decodeString(forKey: "operationName")!
        self.expression = coder.decodeObject(forKey: "expression") as! Expression
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.expression,forKey: "expression")
        coder.encode(self.operationName,forKey: "operationName")
        }
        
    init(_ expression:Expression,_ operation:Token.Operator)
        {
        self.operationName = operation.name
        self.expression = expression
        super.init()
        self.expression.setParent(self)
        }
        
 
        
    public override func realize(using realizer: Realizer)
        {
        self.expression.realize(using: realizer)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.expression.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: T3ABuffer, using: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
        try self.expression.emitCode(into: instance,using: using)
        switch(self.operationName)
            {
            case "++":
                instance.append(nil,"INC",self.expression.place,.none,self.expression.place)
            case "--":
                instance.append(nil,"DEC",self.expression.place,.none,self.expression.place)
            default:
                break
            }
        }
    }
