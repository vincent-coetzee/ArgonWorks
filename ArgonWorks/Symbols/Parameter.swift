//
//  Parameter.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Parameter:Slot,Displayable
    {
    public var displayString: String
        {
        return("\(self.tag)::\(type.label)")
        }
        
    public override var typeCode:TypeCode
        {
        .parameter
        }
        
    public var valueTag: Label
        {
        return(self.label)
        }
        
    public let isVisible:Bool
    public let isVariadic: Bool
    public var place: Instruction.Operand = .none
    
    init(label:Label,type:Type,isVisible:Bool = false,isVariadic:Bool = false)
        {
        self.isVisible = isVisible
        self.isVariadic = isVariadic
        super.init(label: label,type: type)
        }
    
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator)
        {
        self.place = self.addresses.mostEfficientAddress.operand
        }
        
    required init(labeled: Label, ofType: Type) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public typealias Parameters = Array<Parameter>

extension Array where Element == Displayable
    {
    public var displayString: String
        {
        return("[" + self.map{$0.displayString}.joined(separator: ",") + "]")
        }
    }
