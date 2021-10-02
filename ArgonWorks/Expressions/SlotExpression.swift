//
//  SlotAccessExpression.swift
//  SlotAccessExpression
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class SlotExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.receiver.displayString)->\(self.slotExpression?.displayString)")
        }
        
    public override var isLValue: Bool
        {
        return(true)
        }
        
    private let receiver: Expression
    private var slotExpression: Expression?
    private var slot: Slot?
    
    required init?(coder: NSCoder)
        {
        self.receiver = coder.decodeObject(forKey: "receiver") as!Expression
        self.slotExpression = coder.decodeObject(forKey: "slotExpression") as? Expression
        self.slot = coder.decodeObject(forKey: "slot") as? Slot
        super.init(coder: coder)
        }
        
    init(_ receiver:Expression,slot:Slot)
        {
        self.receiver = receiver
        self.slot = slot
        super.init()
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.slot,forKey: "slot")
        coder.encode(self.slotExpression,forKey: "slotExpression")
        coder.encode(self.receiver,forKey: "receiver")
        }
        
    init(_ receiver: Expression,slotExpression: SlotSelectorExpression)
        {
        self.receiver = receiver
        self.slotExpression = slotExpression
        super.init()
        self.receiver.setParent(self)
        self.slotExpression?.setParent(self)
        }
        
 
        
    public override var resultType: Type
        {
        let receiverType = self.receiver.resultType
        let aClass = receiverType.class
        if let identifier = (self.slotExpression as? SlotSelectorExpression)?.selector,let aSlot = aClass.layoutSlot(atLabel: identifier)
            {
            return(aSlot.type)
            }
        return(.error(.undefined))
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.receiver.analyzeSemantics(using: analyzer)
        self.slotExpression?.analyzeSemantics(using: analyzer)
        let selector = (self.slotExpression as! SlotSelectorExpression).selector
        if self.receiver.lookupSlot(selector: selector).isNil
            {
            analyzer.compiler.reportingContext.dispatchError(at: self.declaration!, message: "Slot '\(selector)' was not found on the receiver, unable to resolve the slot.")
            }
        }
        
    public override func realize(using realizer:Realizer)
        {
        self.receiver.realize(using: realizer)
        self.slotExpression?.realize(using: realizer)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        if let slot = self.receiver.lookupSlot(selector: (self.slotExpression as! SlotSelectorExpression).selector)
            {
            try self.receiver.emitCode(into: instance,using: generator)
            let register = generator.registerFile.findRegister(forSlot: nil, inBuffer: instance)
            instance.append(.LOAD,self.receiver.place,.none,.register(register))
            instance.append(.IADD,.register(register),.integer(Argon.Integer(slot.offset)),.register(register))
            self._place = .register(register)
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
