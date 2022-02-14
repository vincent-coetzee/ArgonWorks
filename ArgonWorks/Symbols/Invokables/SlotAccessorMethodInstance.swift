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
        
    public func returns(_ type: Type) -> SlotAccessorMethodInstance
        {
        let instance = SlotAccessorMethodInstance(label: self.label,classType: objectType)
        instance.parameters = [Parameter(label: "object", relabel: nil, type: self.objectType, isVisible: false, isVariadic: false)]
        instance.returnType = type
        instance.type = type
        return(instance)
        }
    }
    
public class SlotAccessorMethodInstance: MethodInstance
    {
    public override var isSlotAccessor: Bool
        {
        true
        }
        
    private let slot: Slot
    private let classType: Type
    
    init(slot: Slot,classType: Type)
        {
        self.slot = slot
        self.classType = classType
        super.init(label: slot.label)
        self.parameters = [Parameter(label: "object", relabel: nil, type: classType, isVisible: false, isVariadic: false)]
        self.returnType = slot.type
        }
        
    public required init?(coder: NSCoder)
        {
        self.slot = coder.decodeObject(forKey: "slot") as! Slot
        self.classType = coder.decodeObject(forKey: "classType") as! Type
        super.init(coder: coder)
        }
        
    public required init(label: Label,classType: Type)
        {
        self.slot = Slot(label: label)
        self.classType = classType
        super.init(label: label)
        }
    
    public required init(label: Label) {
        fatalError("init(label:) has not been implemented")
    }
    
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.slot,forKey: "slot")
        coder.encode(self.classType,forKey: "classType")
        super.encode(with: coder)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = SlotAccessorMethodInstance(slot: self.slot,classType: substitution.substitute(self.classType))
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let instance = SlotAccessorMethodInstance(slot: self.slot.freshTypeVariable(inContext: context),classType: self.classType.freshTypeVariable(inContext: context))
        instance.returnType = self.returnType.freshTypeVariable(inContext: context)
        instance.type = self.type.freshTypeVariable(inContext: context)
        return(instance as! Self)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.slot.initializeType(inContext: context)
        self.type = self.slot.type
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.slot.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.type,right: self.slot.type,origin: .symbol(self)))
        context.append(TypeConstraint(left: self.type,right: TypeMemberSlot(slotLabel: self.slot.label, base: self.classType),origin: .symbol(self)))
        context.append(TypeConstraint(left: self.slot.type,right: TypeMemberSlot(slotLabel: self.slot.label, base: self.classType),origin: .symbol(self)))
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        buffer.add(.SLOTR,.frameOffset(self.parameters[0].offset),.integer(Argon.Integer(self.slot.offset)),.register(.RR))
        }
    }
