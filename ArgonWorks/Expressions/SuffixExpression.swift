//
//  SuffixExpression.swift
//  SuffixExpression
//
//  Created by Vincent Coetzee on 10/8/21.
//

import Foundation

public class SuffixExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.slotExpression.displayString) \(String(describing: self.operation))")
        }
        
    public let operationName: String
    public let slotExpression: SlotExpression
    
    required init?(coder: NSCoder)
        {
        self.operationName = coder.decodeString(forKey: "operationName")!
        self.slotExpression = coder.decodeObject(forKey: "slotExpression") as! SlotExpression
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.slotExpression,forKey: "slotExpression")
        coder.encode(self.operationName,forKey: "operationName")
        }
        
    init(_ slotExpression:SlotExpression,_ operation:Token.Operator)
        {
        self.operationName = operation.name
        self.slotExpression = slotExpression
        super.init()
        self.slotExpression.setParent(self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.slotExpression.initializeType(inContext: context)
        self.type = self.slotExpression.type
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.slotExpression.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.slotExpression.analyzeSemantics(using: analyzer)
        }
        
    public override func deepCopy() -> Self
        {
        fatalError()
        }
        
    public override func emitCode(into instance: T3ABuffer, using: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
//        try self.expression.emitCode(into: instance,using: using)
        switch(self.operationName)
            {
            case "++":
                instance.append(nil,"INC",.relocatable(.slot(self.slotExpression.slot)),.none,.none)
            case "--":
                instance.append(nil,"DEC",.relocatable(.slot(self.slotExpression.slot)),.none,.none)
            default:
                break
            }
        }
    }
