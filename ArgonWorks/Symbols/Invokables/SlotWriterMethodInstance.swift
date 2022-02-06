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
        
    public func value(_ type: Type) -> SlotWriterMethodInstance
        {
        let instance = SlotWriterMethodInstance(label: self.label)
        instance.parameters = [Parameter(label: "object", relabel: nil, type: self.objectType, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: type, isVisible: false, isVariadic: false)]
        return(instance)
        }
    }
    
public class SlotWriterMethodInstance: MethodInstance
    {
    private let slot: Slot
    private let classType: Type
    
    init(slot: Slot,classType: Type)
        {
        self.slot = slot
        self.classType = classType
        super.init(label: slot.label)
        self.parameters = [Parameter(label: "object", relabel: nil, type: classType, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: slot.type, isVisible: false, isVariadic: false)]
        self.returnType = ArgonModule.shared.void
        }
        
    public required init?(coder: NSCoder)
        {
        self.slot = coder.decodeObject(forKey: "slot") as! Slot
        self.classType = coder.decodeObject(forKey: "classType") as! Type
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        self.slot = Slot(label: label)
        self.classType = Type()
        super.init(label: label)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.slot,forKey: "slot")
        coder.encode(self.classType,forKey: "classType")
        super.encode(with: coder)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.type = ArgonModule.shared.void
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        buffer.add(.SLOTW,.frameOffset(self.parameters[0].offset),.frameOffset(self.parameters[1].offset),.integer(Argon.Integer(self.slot.offset)))
        }
    }
