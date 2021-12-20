//
//  ValueExpression.swift
//  ValueExpression
//
//  Created by Vincent Coetzee on 11/8/21.
//

import Foundation

public class SlotExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.slot.label)")
        }

    public var localSlot: Slot
        {
        return(self.slot)
        }

    public let slot: Slot
    private var isLValue = false

    required init?(coder: NSCoder)
        {
        self.slot = coder.decodeObject(forKey: "slot") as! Slot
        self.isLValue = coder.decodeBool(forKey: "isLValue")
        super.init(coder: coder)
        }

    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.slot,forKey:"slot")
        coder.encode(self.isLValue,forKey:"isLValue")
        }

    init(slot: Slot)
        {
        self.slot = slot
        super.init()
        }

    public override func visit(visitor: Visitor) throws
        {
        try self.slot.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let newSlot = substitution.substitute(self.slot)
        let expression = SlotExpression(slot: newSlot) as! Self
        substitution.typeContext?.bind(newSlot.type!,to: newSlot.label)
        expression.issues = self.issues
        return(expression)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)SLOT EXPRESSION: \(self.slot.label) \(self.slot.type.displayString)")
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.slot.initializeType(inContext: context)
        self.type = self.slot.type
        }
        
    public override func assign(from expression: Expression,into: T3ABuffer,using: CodeGenerator) throws
        {
        try expression.emitValueCode(into: into,using: using)
        try self.emitPointerCode(into: into,using: using)
        into.append("SIP",expression.place,.none,self.place)
        }
        
    public override func emitValueCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        try self.slot.emitRValue(into: buffer,using: using)
        }
        
    public override func emitPointerCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        try self.slot.emitLValue(into: buffer,using: using)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.slot.lookup(label: label))
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        if slot.type!.isGenericClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The type of the slot '\(slot.label)' contains an uninstanciated class which is invalid.")
            }
        }

    public override func emitCode(into instance: T3ABuffer, using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
        let temp = instance.nextTemporary()
        instance.append(nil,"MOV",.relocatable(.frame(self.slot.offset)),.none,temp)
        self._place = temp
        }
    }
