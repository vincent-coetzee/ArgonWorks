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
        
    public override var label: Label
        {
        get
            {
            self.relabel.isNotNil ? self.relabel! : super.label
            }
        set
            {
            }
        }

    public let isVisible:Bool
    public let isVariadic: Bool
    public var place: T3AInstruction.Operand = .none
    public let relabel: Label?
    
    init(label:Label,relabel:Label? = nil,type:Type,isVisible:Bool = false,isVariadic:Bool = false)
        {
        self.isVisible = isVisible
        self.isVariadic = isVariadic
        self.relabel = relabel
        super.init(label: label,type: type)
        }
    
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator)
        {
        }
        
    required init(labeled: Label, ofType: Type) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
    
    public required init?(coder: NSCoder)
        {
        self.isVisible = coder.decodeBool(forKey: "isVisible")
        self.isVariadic = coder.decodeBool(forKey: "isVariadic")
        self.relabel = coder.decodeString(forKey: "relabel")
        super.init(coder: coder)
        }
        
 
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.isVisible,forKey: "isVisible")
        coder.encode(self.isVariadic,forKey: "isVariadic")
        coder.encode(self.relabel,forKey: "relabel")
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
