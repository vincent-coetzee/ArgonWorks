//
//  SlotSetterMethodInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/12/21.
//

import Foundation

public class SlotSetter
    {
    private let label: Label
    private var objectType:Type
    
    public init(_ label: String,on type:Type)
        {
        self.label = label
        self.objectType = type
        }
        
    public func value(_ type: Type) -> SlotSetterMethodInstance
        {
        let instance = SlotSetterMethodInstance(label: self.label)
        instance.parameters = [Parameter(label: "object", relabel: nil, type: self.objectType, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: type, isVisible: false, isVariadic: false)]
        return(instance)
        }
    }
    
public class SlotSetterMethodInstance: MethodInstance
    {
    init(slot: Slot,classType: Type)
        {
        super.init(label: slot.label)
        self.parameters = [Parameter(label: "object", relabel: nil, type: classType, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: slot.type, isVisible: false, isVariadic: false)]
        self.returnType = ArgonModule.shared.void
        }
        
    public required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.type = ArgonModule.shared.void
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        }
    }
