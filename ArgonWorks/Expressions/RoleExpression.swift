//
//  RoleExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 23/10/21.
//

import Foundation

public class RoleExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.type)")
        }

    private let expression: Expression

    required init?(coder: NSCoder)
        {
        self.expression = coder.decodeObject(forKey: "expression") as! Expression
        super.init(coder: coder)
        }

    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.expression,forKey:"expression")
        }

    init(expression: Expression,type: Type)
        {
        self.expression = expression
        super.init()
        self.type = type
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type.lookup(label: label))
        }
        
    public override func substitute(from context: TypeContext) -> Self
        {
        fatalError()
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }

    public override func emitAddressCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
        }

    public override func emitCode(into instance: T3ABuffer, using generator: CodeGenerator) throws
        {
        try self.expression.emitCode(into: instance,using: generator)
        let temp = instance.nextTemporary()
        instance.append("ROLE",self.expression._place,.relocatable(.type(self.type)),temp)
        self._place = temp
        }
    }
