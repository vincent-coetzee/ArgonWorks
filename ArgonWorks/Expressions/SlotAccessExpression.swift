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
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func assign(from expression: Expression,into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        guard let slot = self.slot else
            {
            fatalError("Slot is nil, can not assign into nil slot.")
            }
        try expression.emitValueCode(into: buffer,using: using)
        try self.receiver.emitPointerCode(into: buffer,using: using)
        let temporary = buffer.nextTemporary()
        buffer.append("ADD",self.receiver.place,.literal(.integer(Argon.Integer(slot.offset))),temporary)
        buffer.append("STIP",expression.place,.none,temporary)
        self._place = temporary
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.receiver.initializeType(inContext: context)
        self.type = context.freshTypeVariable()
        }

    public override func emitValueCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        try self.receiver.emitPointerCode(into: into,using: using)
        if let slot = self.slot
            {
            let temporary = into.nextTemporary()
            into.append("IADD",.literal(.integer(Argon.Integer(slot.offset))),.none,temporary)
            into.append("LFP",temporary,.none,temporary)
            self._place = temporary
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.receiver.initializeTypeConstraints(inContext: context)
        if let aType = self.receiver.type,!aType.isTypeVariable
            {
            if let aSlot = aType.lookup(label: self.slotLabel) as? Slot
                {
                self.slot = aSlot
                self.type = aSlot.type!
                context.append(TypeConstraint(left: self.type,right: aSlot.type!,origin: .expression(self)))
                context.append(TypeConstraint(left: self.type,right: TypeMemberSlot(slotLabel: self.slotLabel,base: self.receiver.type!),origin: .expression(self)))
                context.append(TypeConstraint(left: self.slot!.type!,right: TypeMemberSlot(slotLabel: self.slotLabel,base: self.receiver.type!),origin: .expression(self)))
                }
            else
                {
                self.appendIssue(at: self.declaration!, message: "The base type of this expression '\(self.receiver.type!.displayString)' does not have a slot labeled '\(self.slotLabel)'.")
                return
                }
            }
        else
            {
            self.slot = Slot(label: self.slotLabel)
            context.append(TypeConstraint(left: self.type,right: self.slot!.type,origin: .expression(self)))
            context.append(TypeConstraint(left: self.type,right: TypeMemberSlot(slotLabel: self.slotLabel,base: self.receiver.type!),origin: .expression(self)))
            context.append(TypeConstraint(left: self.slot!.type!,right: TypeMemberSlot(slotLabel: self.slotLabel,base: self.receiver.type!),origin: .expression(self)))
            let substitution = context.unify()
            let receiverType = substitution.substitute(self.receiver.type)!
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
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type?.lookup(label: label))
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        }
    }

