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
     
    public var isSlotReader = false
    public var isSlotWriter = false
    
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
        expression.type = substitution.substitute(self.type)
        if let aSlot = self.slot
            {
            expression.slot = aSlot
            expression.slot!.type = substitution.substitute(aSlot.type)
            }
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func assign(from expression: Expression,into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        try expression.emitValueCode(into: buffer,using: using)
        try self.receiver.emitAddressCode(into: buffer,using: using)
        let temporary = buffer.nextTemporary
        if let slot = self.slot
            {
            let owningClass = slot.owningClass
            let index = owningClass!.slotIndexCache[slot.label]!
            buffer.add(.i64,.ADD,receiver.place,.integer(3 * Argon.kWordSizeInBytesInt),temporary)
            buffer.add(.LOADP,temporary,.integer(0),temporary)
            buffer.add(.LOADP,temporary,.integer(index * Argon.kWordSizeInBytesInt),temporary)
            buffer.add(.i64,.ADD,self.receiver.place,temporary,temporary)
            buffer.add(.STOREP,expression.place,temporary,.integer(0))
            }
        else
            {
            buffer.add(.LOOKUP,self.receiver.place,.address(using.emitStaticString(self.slotLabel)),temporary)
            buffer.add(.STOREP,expression.place,temporary,.integer(0))
            }
        self._place = temporary
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.receiver.initializeType(inContext: context)
        self.type = TypeMemberSlot(slotLabel: self.slotLabel, base: self.receiver.type)
        }

    public override func emitValueCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.receiver.emitAddressCode(into: into,using: using)
        let temporary = into.nextTemporary
        let receiverType = self.receiver.type
        if let slot = self.slot,let receiverClass = receiverType as? TypeClass
            {
            let offset = receiverClass.offsetInObject(ofSlot: slot)
            into.add(.LOADP,self.receiver.place,.integer(Argon.Integer(offset)),temporary)
            }
        else
            {
            into.add(.LOOKUP,self.receiver.place,.address(using.emitStaticString(self.slotLabel)),temporary)
            }
        self._place = temporary
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.receiver.initializeTypeConstraints(inContext: context)
        let aType = self.receiver.type
        if !aType.isTypeVariable
            {
            if let aSlot = aType.lookup(label: self.slotLabel.withoutHash()) as? Slot
                {
                self.slot = aSlot
                context.append(TypeConstraint(left: self.type,right: self.slot!.type,origin: .expression(self)))
                }
            else
                {
                self.appendIssue(at: self.declaration!, message: "The base type of this expression '\(self.receiver.type.displayString)' does not have a slot labeled '\(self.slotLabel)'.")
                return
                }
            }
        else
            {
            self.slot = Slot(label: self.slotLabel.withoutHash())
            context.append(TypeConstraint(left: self.type,right: self.slot!.type,origin: .expression(self)))
            let substitution = context.unify()
            let receiverType = substitution.substitute(self.receiver.type)
            guard receiverType.isClass else
                {
                self.appendIssue(at: self.declaration!, message: "Unable to infer base type of slot parent in this expression.")
                return
                }
            guard let aSlot = receiverType.lookup(label: self.slotLabel) as? Slot else
                {
                self.appendIssue(at: self.declaration!, message: "The inferred base type of this expression '\(self.receiver.type.displayString)' does not have a slot labeled '\(self.slotLabel)'.")
                return
                }
            self.slot = aSlot
            self.slot!.type = substitution.substitute(aSlot.type)
            context.append(TypeConstraint(left: self.type,right: self.slot!.type,origin: .expression(self)))
            }
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        }
    }

