//
//  Constant.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Constant:Slot
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }

    public override var iconName: String
        {
        return("IconConstant")
        }
        
    public var place: T3AInstruction.Operand = .none
    
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
    
    public override func isElement(ofType: Group.ElementType) -> Bool
        {
        return(ofType == .constant)
        }
        
    public override var typeCode:TypeCode
        {
        .constant
        }
        
    public override func emitCode(into instance: T3ABuffer, using: CodeGenerator) throws
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
    
    public required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
    
 
}
