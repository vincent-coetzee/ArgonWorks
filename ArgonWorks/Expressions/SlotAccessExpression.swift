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
        return("\(self.receiver.displayString)->\(self.slotExpression?.displayString)")
        }

    private let receiver: Expression
    private var slotExpression: Expression?
    private var slot: Slot?
    private var isLValue = false
    
    required init?(coder: NSCoder)
        {
        self.receiver = coder.decodeObject(forKey: "receiver") as!Expression
        self.slotExpression = coder.decodeObject(forKey: "slotExpression") as? Expression
        self.slot = coder.decodeObject(forKey: "slot") as? Slot
        self.isLValue = coder.decodeBool(forKey: "isLValue")
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
        coder.encode(self.isLValue,forKey: "isLValue")
        coder.encode(self.slot,forKey: "slot")
        coder.encode(self.slotExpression,forKey: "slotExpression")
        coder.encode(self.receiver,forKey: "receiver")
        }
        
    public override func setType(_ type:Type)
        {
        self.receiver.setType(type)
        }
        
    public override func becomeLValue()
        {
        self.isLValue = true
        }
        
    init(_ receiver: Expression,slotExpression: SlotSelectorExpression)
        {
        self.receiver = receiver
        self.slotExpression = slotExpression
        super.init()
        self.receiver.setParent(self)
        self.slotExpression?.setParent(self)
        }
        
    public override var type: Type
        {
        let receiverType = self.receiver.type
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
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        if let slot = self.receiver.lookupSlot(selector: (self.slotExpression as! SlotSelectorExpression).selector)
            {
            let temp = instance.nextTemporary()
            try self.receiver.emitCode(into: instance,using: generator)
            instance.append(nil,"MOV",self.receiver.place,.none,temp)
            instance.append(nil,"IADD",temp,.integer(slot.offset),temp)
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
