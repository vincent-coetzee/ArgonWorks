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
        return("\(String(describing: self.operationName))\(String(describing: self.rhs.displayString))")
        }
        
    private let operationName: String
    private let rhs: Expression
    
    init(_ operation:Token.Symbol,_ rhs:Expression)
        {
        self.operationName = operation.rawValue
        self.rhs = rhs
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.operationName = coder.decodeString(forKey: "operationName")!
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        super.init(coder: coder)
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
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.rhs.initializeType(inContext: context)
        self.type = self.rhs.type
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.rhs.initializeTypeConstraints(inContext: context)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.rhs.analyzeSemantics(using: analyzer)
        }
        
   public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = UnaryExpression(Token.Symbol(rawValue: self.operationName)!,self.rhs.freshTypeVariable(inContext: context))
        expression.locations = self.locations
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = UnaryExpression(Token.Symbol(rawValue: self.operationName)!,substitution.substitute(self.rhs)) as! Self
        expression.locations = self.locations
        expression.issues = self.issues
        return(expression)
        }
        
    public override func emitValueCode(into instance: InstructionBuffer,using: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.add(lineNumber: location.line)
            }
        try self.rhs.emitCode(into: instance, using: using)
        var opcode = Opcode.NOP
        let temp = instance.nextTemporary
        switch(self.operationName)
            {
            case "-":
                if self.type == ArgonModule.shared.integer || self.type == ArgonModule.shared.uInteger
                    {
                    instance.add(.i64,.NEG,rhs.place,temp)
                    }
                else if self.type == ArgonModule.shared.byte
                    {
                    instance.add(.i8,.NEG,rhs.place,temp)
                    }
                else if self.type == ArgonModule.shared.character
                    {
                    instance.add(.i16,.NEG,rhs.place,temp)
                    }
                else if self.type == ArgonModule.shared.float
                    {
                    instance.add(.f64,.NEG,rhs.place,temp)
                    }
            case "~":
                    instance.add(.i64,.LNOT,rhs.place,temp)
            case "!":
                    instance.add(.i64,.NOT,rhs.place,temp)
            default:
                fatalError("Unhandled unary operation.")
            }
        self._place = temp
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        try self.emitValueCode(into: instance,using: using)
        }
    }
