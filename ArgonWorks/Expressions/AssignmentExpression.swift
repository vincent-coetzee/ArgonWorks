//
//  AssignmentExpression.swift
//  AssignmentExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class AssignmentExpression: Expression
    {
    public override var lhsValue: Expression?
        {
        return(self.lhs)
        }
        
    public override var rhsValue: Expression?
        {
        return(self.rhs)
        }
        
    private let rhs: Expression
    private let lhs: Expression
    private var operationName: String = ""
    
    public required init?(coder: NSCoder)
        {
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        self.operationName = coder.decodeString(forKey: "operationName")!
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.rhs,forKey: "rhs")
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.operationName,forKey: "operationName")
        }
        
    public override var type: Type
        {
        return(.unknown)
        }
        
    init(_ lhs:Expression,_ operation: Token.Operator,_ rhs:Expression)
        {
        self.rhs = rhs
        self.lhs = lhs
        self.lhs.becomeLValue()
        self.operationName = operation.name
        super.init()
        }
        
    public override var displayString: String
        {
        return("\(self.lhs.displayString) \(self.operationName) \(self.rhs.displayString)")
        }

    public override func realize(using realizer:Realizer)
        {
        self.lhs.realize(using: realizer)
        self.rhs.realize(using: realizer)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.lhs.analyzeSemantics(using: analyzer)
        self.rhs.analyzeSemantics(using: analyzer)
        if self.lhs.type.isUnknown && !self.rhs.type.isUnknown
            {
            self.lhs.setType(self.rhs.type)
            }
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
        try self.lhs.emitCode(into: instance,using: generator)
        try self.rhs.emitCode(into: instance,using: generator)
        instance.append(nil,"MOVINDIRECT",self.lhs.place,rhs.place,.none)
        if rhs.place.isNone
            {
            print("WARNING: In AssignmentExpression in line \(self.declaration!) RHS.place == .none")
            }
        }
    }
