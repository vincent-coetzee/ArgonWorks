//
//  ValueExpression.swift
//  ValueExpression
//
//  Created by Vincent Coetzee on 11/8/21.
//

import Foundation

public class LocalSlotExpression: Expression
    {
    public override var displayString: String
        {
        return("\(self.slot.label)")
        }

    public var localSlot: Slot
        {
        return(self.slot)
        }

    private let slot: Slot
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

    public override func realize(using realizer:Realizer)
        {
        }

    public override func becomeLValue()
        {
        self.isLValue = true
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        if slot.type.isGenericClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The type of the slot '\(slot.label)' contains an uninstanciated class which is invalid.")
            }
        }

    public override var type: Type
        {
        return(self.slot.type)
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
