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
    private var _type: Type

    required init?(coder: NSCoder)
        {
        self.expression = coder.decodeObject(forKey: "expression") as! Expression
        self._type = coder.decodeType(forKey: "type")!
        super.init(coder: coder)
        }

    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encodeType(self._type,forKey:"type")
        coder.encode(self.expression,forKey:"expression")
        }

    init(expression: Expression,type: Type)
        {
        self._type = type
        self.expression = expression
        super.init()
        }

    public override func realize(using realizer:Realizer)
        {
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type.lookup(label: label))
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }

    public override var type: Type
        {
        return(self._type)
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
