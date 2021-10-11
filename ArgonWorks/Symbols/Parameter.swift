//
//  Parameter.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Parameter:Slot,Displayable
    {
    public override var displayString: String
        {
        return("\(self.label)::\(type.label)")
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
    public var place: T3AInstruction.Operand = .none
    
    init(label:Label,type:Type,isVisible:Bool = false,isVariadic:Bool = false)
        {
        self.isVisible = isVisible
        self.isVariadic = isVariadic
        super.init(label: label,type: type)
        }
    
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator)
        {
//        self.place = self.addresses.mostEfficientAddress.operand
        }
        
    required init(labeled: Label, ofType: Type) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
    
    public required init?(coder: NSCoder)
        {
        self.isVisible = coder.decodeBool(forKey: "isVisible")
        self.isVariadic = coder.decodeBool(forKey: "isVariadic")
        super.init(coder: coder)
        }
        
 
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.isVisible,forKey: "isVisible")
        coder.encode(self.isVariadic,forKey: "isVariadic")
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
