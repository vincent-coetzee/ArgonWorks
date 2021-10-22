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
        return("\(self.receiver.displayString)->\(String(describing: self.slotExpression?.displayString))")
        }

    private let receiver: Expression
    private var slotExpression: Expression?
    private var slot: Symbol?
    private var isLValue = false
    private var _type: Type?
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
        
    public override func setType(_ type:Type)
        {
        self._type = type
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
        
    init(_ receiver: Expression,selector: String)
        {
        self.receiver = receiver
        self.slotExpression = nil
        super.init()
        self.receiver.setParent(self)
        self.selector = selector
        }
        
    public override var type: Type
        {
        let receiverType = self.receiver.type
        if receiverType.isUnknown
            {
            return(.unknown)
            }
        let aClass = receiverType.class
        if self.slot.isNotNil
            {
            return(self.slot!.type)
            }
        if let identifier = (self.slotExpression as? SlotSelectorExpression)?.selector,let aSlot = aClass.slotWithLabel(identifier)
            {
            return(aSlot.type)
            }
        if self._type.isNotNil
            {
            return(self._type!)
            }
        return(.unknown)
        }
        
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
