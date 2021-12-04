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
        return(expression)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)SLOT EXPRESSION: \(self.slot.label) \(self.slot.type.displayString)")
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        if self.slot.type.isNil
            {
            if let slotType = context.lookupBinding(atLabel: self.slot.label)
                {
                self.type = slotType
                self.slot.type = slotType
                }
            else
                {
                self.slot.type = context.freshTypeVariable()
                self.type = self.slot.type
                context.bind(self.slot.type!,to: self.slot.label)
                }
            }
        else if self.slot.type!.isTypeVariable
            {
            if let slotType = context.lookupBinding(atLabel: self.slot.label)
                {
                self.slot.type = slotType
                self.type = slotType
                }
            else
                {
                self.type = self.slot.type!
                context.bind(self.slot.type!,to: self.slot.label)
                }
            }
        else if self.slot.type!.isClass || self.slot.type!.isEnumeration
            {
            self.type = self.slot.type
            context.bind(self.slot.type!,to: self.slot.label)
            }
        else if self.slot.initialValue.isNotNil
            {
            self.slot.type = self.slot.initialValue!.type
            self.type = self.slot.type
            context.bind(self.slot.type!,to: self.slot.label)
            }
        else
            {
            fatalError("This should not happen.")
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        }
        
    public override func becomeLValue()
        {
        self.isLValue = true
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

    public override func emitAssign(value: Expression,into instance: T3ABuffer,using: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
        try value.emitCode(into: instance, using: using)
        instance.append("MOV",value.place,.none,.relocatable(.slot(self.slot)))
        }
        
    public override func emitAddressCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
        let temp = instance.nextTemporary()
        instance.append(nil,"ADDR",.relocatable(.slot(self.slot)),.none,temp)
        self._place = temp
        }

    public override func emitCode(into instance: T3ABuffer, using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
        let temp = instance.nextTemporary()
        instance.append(nil,"MOV",.relocatable(.slot(self.slot)),.none,temp)
        self._place = temp
        }
    }
