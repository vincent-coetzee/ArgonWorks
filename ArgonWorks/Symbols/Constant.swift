//
//  Constant.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Constant:Slot
    {
    public override var isLiteral: Bool
        {
        return(true)
        }
        
    public override var asLiteralExpression: LiteralExpression?
        {
        return(LiteralExpression(.constant(self)))
        }

    public override var iconName: String
        {
        return("IconConstant")
        }

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

 
    public required init(label: Label)
        {
        self.value = Expression()
        super.init(label: label)
        }
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.value,forKey: "value")
        }
//    
//    public override func isElement(ofType: Group.ElementType) -> Bool
//        {
//        return(ofType == .constant)
//        }
        
    public override var typeCode:TypeCode
        {
        .constant
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        try self.value.emitCode(into: instance,using: using)
        self.place = self.value.place
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
    }

public class SystemConstant: Constant
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    init(label: Label,type: Type)
        {
//        let expression = DeferredValueExpression(label,type: type)
        super.init(label: label,type: type,value: Expression())
        }
        
        required init(labeled: Label, ofType: Type) {
            fatalError("init(labeled:ofType:) has not been implemented")
        }
    
    public required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }

    public required init(label: Label)
        {
        super.init(label: label)
        }
 
}
