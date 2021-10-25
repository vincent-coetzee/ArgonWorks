//
//  AssignmentExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/10/21.
//

import Foundation

public class AssignmentExpression: Expression
    {
    public override var assignedSlots: Slots
        {
        return(self.lhs.assignedSlots)
        }
        
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
    
    public required init?(coder: NSCoder)
        {
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.rhs,forKey: "rhs")
        coder.encode(self.lhs,forKey: "lhs")
        }
        
    public override var type: Type
        {
        return(self.rhs.type)
        }
        
    init(_ lhs:Expression,_ rhs:Expression)
        {
        self.rhs = rhs
        self.lhs = lhs
        self.lhs.becomeLValue()
        self.lhs.imposeType(self.rhs.type)
        super.init()
        }
        
    public override var displayString: String
        {
        return("\(self.lhs.displayString) = \(self.rhs.displayString)")
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
        try self.lhs.emitAssign(value: self.rhs, into: instance, using: generator)
        }
    }
