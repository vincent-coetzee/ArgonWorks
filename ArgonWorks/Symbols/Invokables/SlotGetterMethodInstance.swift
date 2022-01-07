//
//  SlotGetterMethodInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/12/21.
//

import Foundation

public class SlotGetter
    {
    private let label: Label
    private var objectType:Type
    
    public init(_ label: String,on type:Type)
        {
        self.label = label
        self.objectType = type
        }
        
    public func returns(_ type: Type) -> SlotGetterMethodInstance
        {
        let instance = SlotGetterMethodInstance(label: self.label)
        instance.parameters = [Parameter(label: "object", relabel: nil, type: self.objectType, isVisible: false, isVariadic: false)]
        instance.returnType = type
        return(instance)
        }
    }
    
public class SlotGetterMethodInstance: MethodInstance
    {
    init(slot: Slot,classType: Type)
        {
        super.init(label: slot.label)
        self.parameters = [Parameter(label: "object", relabel: nil, type: classType, isVisible: false, isVariadic: false)]
        self.returnType = slot.type
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
        self.type = self.returnType
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        }
    }
