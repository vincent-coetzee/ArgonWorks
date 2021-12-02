//
//  SlotAccessExpression.swift
//  SlotAccessExpression
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class SlotAccessExpression: Expression
    {
    public override var assignedSlots: Slots
        {
        return(self.slot.isNil ? [] : [self.slot as! Slot])
        }
        
    public override var enumerationCaseHasAssociatedTypes: Bool
        {
        if self.slot.isNotNil,let aCase = self.slot as? EnumerationCase,aCase.hasAssociatedTypes
            {
            return(true)
            }
        return(false)
        }
        
    public override var enumerationCase: EnumerationCase
        {
        return(self.slot as! EnumerationCase)
        }
        
    public override var isEnumerationCaseExpression: Bool
        {
        if self.slot.isNotNil
            {
            return(self.slot!.isEnumerationCase)
            }
        return(false)
        }
        
    public override var displayString: String
        {
        return("\(self.receiver.displayString)->\(String(describing: self.slotExpression?.displayString))")
        }

    private let receiver: Expression
    private var slotExpression: Expression?
    private var slot: Symbol?
    private var isLValue = false
    private var selector: String?
     
    required init?(coder: NSCoder)
        {
//        print("START DECODE SLOT ACCESS EXPRESSION")
        self.receiver = coder.decodeObject(forKey: "receiver") as!Expression
        self.slotExpression = coder.decodeObject(forKey: "slotExpression") as? Expression
        self.slot = coder.decodeObject(forKey: "slot") as? Slot
        self.selector = coder.decodeString(forKey: "selector")
        self.isLValue = coder.decodeBool(forKey: "isLValue")
        super.init(coder: coder)
//        print("END DECODE SLOT ACCESS EXPRESSION")
        }
        
    init(_ receiver:Expression,slot: Symbol)
        {
        self.receiver = receiver
        self.slot = slot
        super.init()
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.isLValue,forKey: "isLValue")
        coder.encode(self.slot,forKey: "slot")
        coder.encode(self.slotExpression,forKey: "slotExpression")
        coder.encode(self.receiver,forKey: "receiver")
        coder.encode(self.selector,forKey: "selector")
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.receiver.visit(visitor: visitor)
        try self.slotExpression?.visit(visitor: visitor)
        try self.slot?.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func inferType(context: TypeContext) throws -> Type
        {
        self.slot!.type
        }
        
    public override func display(indent: String)
        {
        print("\(indent)SLOT EXPRESSION:")
        self.receiver.display(indent: indent + "\t")
        print("\(indent)\tSLOT \(self.slot!.label) \(self.slot!.type.displayString)")
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        SlotAccessExpression(substitution.substitute(self.receiver),slot: substitution.substitute(self.slot!)) as! Self
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        self.type = self.slot!.type
        }
        
    public override func becomeLValue()
        {
        self.isLValue = true
        }
        
//    init(_ receiver: Expression,slotExpression: SlotSelectorExpression)
//        {
//        self.receiver = receiver
//        self.slotExpression = slotExpression
//        super.init()
//        self.receiver.setParent(self)
//        self.slotExpression?.setParent(self)
//        }
//        
//    init(_ receiver: Expression,selector: String)
//        {
//        self.receiver = receiver
//        self.slotExpression = nil
//        super.init()
//        self.receiver.setParent(self)
//        self.selector = selector
//        }
        
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type.lookup(label: label))
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.receiver.analyzeSemantics(using: analyzer)
        self.slotExpression?.analyzeSemantics(using: analyzer)
        let selector = (self.slotExpression as! SlotSelectorExpression).selector
        if self.receiver.lookupSlot(selector: selector).isNil
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "Slot '\(selector)' was not found on the receiver, unable to resolve the slot, the receiver may need to have it's type defined.")
            }
        }
        
    public override func emitAddressCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
        print("halt")
//        if let slot = self.receiver.lookupSlot(selector: (self.slotExpression as! SlotSelectorExpression).selector)
//            {
//            let temp = instance.nextTemporary()
//            try self.receiver.emitCode(into: instance,using: generator)
//            instance.append(nil,"MOV",self.receiver.place,.none,temp)
//            instance.append(nil,"IADD",temp,.integer(slot.offset),temp)
//            self._place = temp
//            }
        }
        
    public override func emitAssign(value: Expression,into instance: T3ABuffer,using: CodeGenerator) throws
        {
        try value.emitCode(into: instance, using: using)
        try self.receiver.emitAddress(into: instance,using: using)
        let aSlot = self.slot as! Slot
        let aClass = aSlot.parent.node as! Class
        let actualSlot = aClass.layoutSlot(atLabel: aSlot.label)!
        instance.append("STORE",value.place,.none,.indirect(self.receiver.place,actualSlot.offset))
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
        if slot.isNotNil && slot is Slot
            {
            let temp = instance.nextTemporary()
            try self.receiver.emitCode(into: instance,using: generator)
            instance.append(nil,"MOV",self.receiver.place,.none,temp)
            instance.append(nil,"IADD",temp,.literal(.integer(Argon.Integer((slot as! Slot).offset))),temp)
            self._place = temp
            }
        else if let expression = self.slotExpression,let aSlot = self.receiver.lookupSlot(selector: (expression as! SlotSelectorExpression).selector)
            {
            let temp = instance.nextTemporary()
            try self.receiver.emitCode(into: instance,using: generator)
            instance.append(nil,"MOV",self.receiver.place,.none,temp)
            instance.append(nil,"IADD",temp,.literal(.integer(Argon.Integer(aSlot.offset))),temp)
            self._place = temp
            }
        else
            {
//            fatalError("SLOT is not found")
            }
        }
    }

public class SlotSelectorExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.selector)")
        }
        
    public let selector: String
    
    init(selector: String)
        {
        self.selector = selector
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.selector = coder.decodeObject(forKey: "selector") as! String
        super.init(coder: coder)
        }
        
 
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.selector,forKey: "selector")
        }
    }
