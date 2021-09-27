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
    
    init(label:Label,type:Type,value:Expression)
        {
        self.value = value
        super.init(label: label,type: type)
        }
    
    required init(labeled: Label, ofType: Type) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
    
    public required init?(coder: NSCoder)
        {
        self.value = coder.decodeObject(forKey: "value") as! Expression
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.value,forKey: "value")
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

public class SystemConstant: Constant
    {
    init(label: Label,type: Type)
        {
        let expression = DeferredValueExpression(label,type: type)
        super.init(label: label,type: type,value: expression)
        }
        
        required init(labeled: Label, ofType: Type) {
            fatalError("init(labeled:ofType:) has not been implemented")
        }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
