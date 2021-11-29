//
//  UnaryExpression.swift
//  UnaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class UnaryExpression: Expression
    {
    public override var displayString: String
        {
        return("\(String(describing: self.operation))\(String(describing: self.rhs.displayString))")
        }
        
    private let operationName: String
    private let rhs: Expression
    
    init(_ operation:Token.Symbol,_ rhs:Expression)
        {
        self.operationName = operation.rawValue
        self.rhs = rhs
        super.init()
        self.rhs.setParent(self)
        }
        
    required init?(coder: NSCoder)
        {
        self.operationName = coder.decodeString(forKey: "operationName")!
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        super.init(coder: coder)
        }
        
    public override func deepCopy() -> Self
        {
        UnaryExpression(Token.Symbol(rawValue: self.operationName)!,self.rhs.deepCopy()) as! Self
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.rhs,forKey: "rhs")
        coder.encode(self.operationName,forKey: "operationName")
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.rhs.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.rhs.initializeType(inContext: context)
        self.type = self.rhs.type
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.rhs.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: T3ABuffer, using: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.lineNumber.line)
            }
        try self.rhs.emitCode(into: instance, using: using)
        var opcode = "NOP"
        switch(self.operationName)
            {
            case "sub":
                if self.type == self.topModule.argonModule.integer.type
                    {
                    opcode = "INEG"
                    }
                else
                    {
                    opcode = "FNEG"
                    }
            case "bitNot":
                opcode = "IBITNOT"
            case "not":
                opcode = "NOT"
            default:
                break
            }
        let temp = instance.nextTemporary()
        instance.append(nil,opcode,rhs.place,.none,temp)
        self._place = temp
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)UNARY EXPRESSION()")
        print("\(padding)\t\(String(describing: self.operation))")
        self.rhs.dump(depth: depth + 1)
        }
    }
