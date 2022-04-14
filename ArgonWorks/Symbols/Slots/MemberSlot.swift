//
//  MemberSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/4/22.
//

import Foundation

public class MemberSlot: Slot
    {
    public override var identityHash: Int
        {
        var hash = super.identityHash
        hash = hash << 13 ^ self.owningType.identityHash
        return(hash)
        }
        
    public var owningClass: TypeClass
        {
        get
            {
            self.owningType as! TypeClass
            }
        set
            {
            self.owningType = newValue
            }
        }
        
    public var owningType: Type = Type(label: "DummyType")
    public var isClassSlot = false
    public var classIndexInVirtualTable = -1
    public var slotInitializerSelector: StaticSymbol?
    public var slotMandatorySelector: StaticSymbol?
    
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public required init(labeled: Label, ofType: Type)
        {
        super.init(label: labeled)
        self.type = ofType
        }
        
    public required init?(coder: NSCoder)
        {
        self.isClassSlot = coder.decodeBool(forKey: "isClassSlot")
        self.classIndexInVirtualTable = coder.decodeInteger(forKey: "classIndexInVirtualTable")
        self.slotInitializerSelector = coder.decodeObject(forKey: "slotInitializerSelector") as? StaticSymbol
        self.slotMandatorySelector = coder.decodeObject(forKey: "slotMandatorySelector") as? StaticSymbol
        self.owningType = coder.decodeObject(forKey: "owningType") as! Type
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.isClassSlot,forKey: "isClassSlot")
        coder.encode(TypeSurrogate(type: self.owningType),forKey: "owningType")
        coder.encode(self.classIndexInVirtualTable,forKey: "classIndexInVirtualTable")
        coder.encode(self.slotInitializerSelector,forKey: "slotInitializerSelector")
        coder.encode(self.slotMandatorySelector,forKey: "slotMandatorySelector")
        super.encode(with: coder)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let copy = super.substitute(from: substitution)
        copy.offset = self.offset
        return(copy)
        }
        
    public override func patchSymbols(topModule: TopModule)
        {
        guard !self.wasSymbolPatchingDone else
            {
            return
            }
        super.patchSymbols(topModule: topModule)
        self.owningType = self.owningType.patchClass(topModule: topModule)
        }
        
    public func setOffset(_ integer:Int)
        {
        self.offset = integer
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator)
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
        allocator.allocateAddress(for: self)
        self.type.allocateAddresses(using: allocator)
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        guard self.wasAddressAllocationDone else
            {
            fatalError("Address allocation should have been done")
            }
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self.segmentType)
        let slotType = self.container.argonModule.slot
        let slotPointer = ClassBasedPointer(address: self.memoryAddress,type: slotType,argonModule: self.container.argonModule)
        slotPointer.setClass(slotType)
        slotPointer.setAddress(self.type.memoryAddress,atSlot: "type")
        slotPointer.setAddress(segment.allocateString(self.label),atSlot: "name")
        slotPointer.setInteger(self.offset,atSlot: "offset")
        slotPointer.setInteger(self.typeCode.rawValue,atSlot: "typeCode")
        slotPointer.setInteger(self.classIndexInVirtualTable,atSlot: "vtIndex")
        if !(self is ModuleSlot)
            {
            slotPointer.setAddress(self.owningClass.memoryAddress,atSlot: "owningClass")
            }
        else
            {
            slotPointer.setAddress(nil,atSlot: "owningClass")
            }
        let slotIndex = allocator.payload.symbolRegistry.registerSymbol("#" + self.label)
        slotPointer.setInteger(slotIndex,atSlot: "symbol")
        if self is InstanceSlot
            {
            let instanceSlot = self as! InstanceSlot
            slotPointer.setAddress(instanceSlot.type.memoryAddress,atSlot: "type")
            }
        else if self is ModuleSlot
            {
            
            }
        slotPointer.setInteger(self.slotType.rawValue, atSlot: "slotType")
        slotPointer.setInteger(self.argonHash,atSlot: "hash")
        self.type.layoutInMemory(using: allocator)
        }
    }
