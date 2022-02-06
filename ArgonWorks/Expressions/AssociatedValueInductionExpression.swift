//
//  AssociatedValueInductionExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/10/21.
//

import Foundation

public class AssociatedValueInductionExpression: Expression
    {
    public override var enumerationCase: EnumerationCase
        {
        return(self.expression.enumerationCase)
        }
        
    private let expression: Expression
    public let slots: Array<Slot>
    
    public required init?(coder: NSCoder)
        {
        self.expression = coder.decodeObject(forKey: "expression") as! Expression
        self.slots = coder.decodeObject(forKey: "slots") as! Array<Slot>
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.expression,forKey: "expression")
        coder.encode(self.slots,forKey: "slots")
        }

    init(_ expression:Expression,_ names:Array<String>)
        {
        self.slots = names.map{LocalSlot(label: $0,type: TypeContext.freshTypeVariable(),value: nil)}
        self.expression = expression
        super.init()
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.expression.visit(visitor: visitor)
        for slot in self.slots
            {
            try slot.visit(visitor: visitor)
            }
        try visitor.accept(self)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
//        instance.append("ASSOC",.relocatable(.enumerationCase(expression.enumerationCase)),.literal(.integer(Argon.Integer(self.slots.count))),.none)
//        for slot in self.slots
//            {
////            instance.append("AVSLOT",.relocatable(.slot(slot)),.none,.none)
//            }
        }
    }
