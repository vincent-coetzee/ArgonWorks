//
//  LayoutSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/4/22.
//

import Foundation

public class LayoutSlot: MemberSlot
    {
    public init(instanceSlot: InstanceSlot)
        {
        super.init(labeled: instanceSlot.label,ofType: instanceSlot.type)
        self.offset = instanceSlot.offset
        self.virtualOffset = instanceSlot.virtualOffset
        self.initialValue = instanceSlot.initialValue
        self.isClassSlot = instanceSlot.isClassSlot
        self.slotType = instanceSlot.slotType
        self.slotSymbol = instanceSlot.slotSymbol
        self.owningType = instanceSlot.owningType
        self.classIndexInVirtualTable = instanceSlot.classIndexInVirtualTable
        self.slotInitializerSelector = instanceSlot.slotInitializerSelector
        self.slotMandatorySelector = instanceSlot.slotMandatorySelector
        }
        
    public required init?(coder: NSCoder)
        {
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public required init(labeled: Label,ofType: Type)
        {
        super.init(labeled: labeled,ofType: ofType)
        }
    }

public typealias LayoutSlots = Array<LayoutSlot>
