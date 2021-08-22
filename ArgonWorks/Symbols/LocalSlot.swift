//
//  LocalSlot.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class LocalSlot:Slot
    {
    private let _typeExpression: Expression
    public var place: Instruction.Operand = .none
    
    init(label:Label,type:Expression)
        {
        self._typeExpression = type
        let aType = type.resultType.class ?? VoidClass.voidClass
        super.init(label: label,type: aType)
        }
    
    required init(labeled: Label, ofType: Class) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
    
    public override var typeCode:TypeCode
        {
        .localSlot
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator)
        {
        self.place = self.addresses.mostEfficientAddress.operand
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        if !self.type.scalarClass
            {
            return(self.type.lookup(label: label))
            }
        return(nil)
        }
    }

public typealias LocalSlots = Array<LocalSlot>
