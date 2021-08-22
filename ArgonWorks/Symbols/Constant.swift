//
//  Constant.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Constant:Slot
    {
    public var place: Instruction.Operand = .none
    
    private let value: Expression
    
    init(label:Label,type:Class,value:Expression)
        {
        self.value = value
        super.init(label: label,type: type)
        }
    
    required init(labeled: Label, ofType: Class) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
    
    public override var typeCode:TypeCode
        {
        .constant
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        try self.value.emitCode(into: instance,using: using)
        self.place = self.value.place
        }
    }
