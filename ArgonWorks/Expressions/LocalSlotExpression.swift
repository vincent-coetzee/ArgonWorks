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
        
    public override var isLValue: Bool
        {
        return(true)
        }
        
    public var localSlot: Slot
        {
        return(self.slot)
        }
    
    private let slot: Slot
    
    required init?(coder: NSCoder)
        {
        self.slot = coder.decodeObject(forKey: "slot") as! Slot
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.slot,forKey:"slot")
        }
        
    init(slot: Slot)
        {
        self.slot = slot
        super.init()
        }
        
    public override func realize(using realizer:Realizer)
        {
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        if slot.type.isGenericClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The type of the slot '\(slot.label)' contains an uninstanciated class which is invalid.")
            }
        }
        
    public override var resultType: Type
        {
        return(self.slot.type)
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        
        try self.slot.emitCode(into: instance,using: using)
        self._place = slot.addresses.mostEfficientAddress.operand
        }
    }
