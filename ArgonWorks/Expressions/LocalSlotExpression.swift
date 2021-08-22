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
    
    init(slot: Slot)
        {
        self.slot = slot
        }
        
    public override func realize(using realizer:Realizer)
        {
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        if slot.type.isGenericClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration, message: "The type of the slot '\(slot.label)' contains an uninstanciated class which is invalid.")
            }
        }
        
    public override var resultType: TypeResult
        {
        return(.class(self.slot.type))
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        
        try self.slot.emitCode(into: instance,using: using)
        self._place = slot.addresses.mostEfficientAddress.operand
        }
    }
