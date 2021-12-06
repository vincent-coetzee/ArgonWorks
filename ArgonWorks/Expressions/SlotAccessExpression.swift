//
//  SlotAccessExpression.swift
//  SlotAccessExpression
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class SlotAccessExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.receiver.displayString)->\(self.slotLabel)")
        }

    private let receiver: Expression
    private var slotExpression: Expression?
    private var slotLabel: Label
    private var slot: Slot?
    private var isLValue = false
    private var selector: String?
     
    required init?(coder: NSCoder)
        {
//        print("START DECODE SLOT ACCESS EXPRESSION")
        self.receiver = coder.decodeObject(forKey: "receiver") as!Expression
        self.slotExpression = coder.decodeObject(forKey: "slotExpression") as? Expression
        self.slotLabel = coder.decodeObject(forKey: "slotLabel") as! String
        self.selector = coder.decodeString(forKey: "selector")
        self.isLValue = coder.decodeBool(forKey: "isLValue")
        super.init(coder: coder)
//        print("END DECODE SLOT ACCESS EXPRESSION")
        }
        
    init(_ receiver:Expression,slotLabel: Label)
        {
        self.receiver = receiver
        self.slotLabel = slotLabel
        super.init()
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.isLValue,forKey: "isLValue")
        coder.encode(self.slotLabel,forKey: "slotLabel")
        coder.encode(self.slotExpression,forKey: "slotExpression")
        coder.encode(self.receiver,forKey: "receiver")
        coder.encode(self.selector,forKey: "selector")
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.receiver.visit(visitor: visitor)
        try self.slotExpression?.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)SLOT ACCESS EXPRESSION:")
        self.receiver.display(indent: indent + "\t")
        let label = self.slot.isNil ? "" : self.slot!.type.displayString
        print("\(indent)\tSLOT \(self.slotLabel) \(label)")
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = SlotAccessExpression(substitution.substitute(self.receiver),slotLabel: self.slotLabel)
        expression.type = substitution.substitute(self.type!)
        if let aSlot = self.slot
            {
            expression.slot = aSlot
            expression.slot!.type = substitution.substitute(aSlot.type!)
            }
        return(expression as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.receiver.initializeType(inContext: context)
        self.type = context.freshTypeVariable()
        }

    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.receiver.initializeTypeConstraints(inContext: context)
        if self.receiver.type!.isClass
            {
            let aClass = self.receiver.type!.classValue
            if let aSlot = aClass.lookup(label: self.slotLabel) as? Slot
                {
                self.slot = aSlot
                self.type = aSlot.type!
                context.append(TypeConstraint(left: self.type,right: aSlot.type!,origin: .expression(self)))
                }
            else
                {
                self.appendIssue(at: self.declaration!, message: "The base type of this expression '\(self.receiver.type!.displayString)' does not have a slot labeled '\(self.slotLabel)'.")
                return
                }
            }
        else
            {
            let substitution = context.unify()
            let receiverType = substitution.substitute(self.receiver.type!)
            guard receiverType.isClass else
                {
                self.appendIssue(at: self.declaration!, message: "Unable to infer base type of slot parent in this expression.")
                return
                }
            guard let aSlot = receiverType.classValue.lookup(label: self.slotLabel) as? Slot else
                {
                self.appendIssue(at: self.declaration!, message: "The inferred base type of this expression '\(self.receiver.type!.displayString)' does not have a slot labeled '\(self.slotLabel)'.")
                return
                }
            self.slot = aSlot
            self.slot!.type = substitution.substitute(aSlot.type!)
            context.append(TypeConstraint(left: self.type,right: self.slot!.type!,origin: .expression(self)))
            }
        }
        
    public override func becomeLValue()
        {
        self.isLValue = true
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type?.lookup(label: label))
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
