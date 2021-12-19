//
//  Slot.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import AppKit

public class Slot:Symbol
    {
    public enum SlotType:Int
        {
        case module
        case instance
        case `class`
        case header
        case magicNumber
        }
        
    public var isSytemSymbol: Bool
        {
        false
        }
        
    public override var asLiteralExpression: LiteralExpression?
        {
        fatalError()
        }
        
    public static func ==(lhs:Slot,rhs:Slot) -> Bool
        {
        return(lhs.index == rhs.index)
        }
        
    public override var typeCode:TypeCode
        {
        .slot
        }
        
    public override var isSlot: Bool
        {
        return(true)
        }
        
    public var size:Int
        {
        return(MemoryLayout<Word>.size)
        }
        
    public override var displayString: String
        {
        "\(self.label)::\(self.type.displayString)"
        }
        
    public override var iconName: String
        {
        "IconSlot"
        }
        
    public override var weight: Int
        {
        100
        }
        
//    public var containedClassParameters: Array<GenericType>
//        {
//        return([])
//        }
        
    public var isArraySlot:Bool
        {
        return(false)
        }
    
    public var isStringSlot:Bool
        {
        return(false)
        }
        
    public var isHidden: Bool
        {
        return(true)
        }
        
    public var cloned: Slot
        {
        let newSlot = Slot(label: self.label,type:self.type)
        newSlot.offset = self.offset
        return(newSlot)
        }
        
    public var isVirtual: Bool
        {
        return(false)
        }
        
    public var offset = 0
    public var initialValue: Expression? = nil
    public var isClassSlot = false
    public var slotType: SlotType = .instance
    

    init(label:Label,type:Type? = nil)
        {
        super.init(label:label)
        self.type = type
        }
        
    required init(labeled:Label,ofType:Type)
        {
        super.init(label:labeled)
        self.type = ofType
        }

    public required init?(coder: NSCoder)
        {
//        print("START DECODE SLOT")
        self.offset = coder.decodeInteger(forKey: "offset")
        self.initialValue = coder.decodeObject(forKey: "initialValue") as? Expression
        self.isClassSlot = coder.decodeBool(forKey: "isClassSlot")
        self.slotType = SlotType(rawValue: coder.decodeInteger(forKey: "slotType"))!
        super.init(coder: coder)
//        print("END DECODE SLOT \(self.label)")
        }

    public required init(label: Label)
        {
        super.init(label: label)
        self.type = TypeContext.freshTypeVariable()
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.offset,forKey: "offset")
        coder.encode(self.initialValue,forKey:"initialValue")
        coder.encode(self.isClassSlot,forKey: "isClassSlot")
        coder.encode(self.slotType.rawValue,forKey: "slotType")
        super.encode(with: coder)
        }
    
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type?.lookup(label: label))
        }
        
    public func setOffset(_ integer:Int)
        {
        self.offset = integer
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator) throws
        {
        guard !self.wasAddressAllocationDone else
            {
            return
            }
        self.wasAddressAllocationDone = true
        allocator.allocateAddress(for: self)
        try self.type?.allocateAddresses(using: allocator)
        }
        
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        guard !self.wasMemoryLayoutDone else
            {
            return
            }
        self.wasMemoryLayoutDone = true
        let segment = allocator.segment(for: self)
        let slotType = ArgonModule.shared.slot
        let slotPointer = ClassBasedPointer(address: self.memoryAddress,type: slotType)
        slotPointer.setClass(slotType)
        slotPointer.setAddress(self.type?.memoryAddress,atSlot: "type")
        slotPointer.setAddress(segment.allocateString(self.label),atSlot: "name")
        slotPointer.setInteger(self.offset,atSlot: "offset")
        slotPointer.setInteger(self.typeCode.rawValue,atSlot: "typeCode")
        slotPointer.setAddress(self.parent.memoryAddress,atSlot: "container")
        self.type?.layoutInMemory(using: allocator)
        }
        
    public override func assign(from expression: Expression,into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        try self.emitLValue(into: buffer, using: using)
        try expression.emitValueCode(into: buffer,using: using)
        buffer.append("STIP",expression.place,.none,self.place)
        }
        
    public override func emitRValue(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public override func emitLValue(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        if self.type.isNil
            {
            return(self)
            }
        let slot = Self.init(label: label)
        slot.type = self.type?.freshTypeVariable(inContext: context)
        return(slot)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        if self.type.isNil
            {
            if let slotType = context.lookupBinding(atLabel: self.label)
                {
                self.type = slotType
                }
            else
                {
                self.type = context.freshTypeVariable()
                context.bind(self.type!,to: self.label)
                }
            }
        else if self.type!.isTypeVariable
            {
            if let slotType = context.lookupBinding(atLabel: self.label)
                {
                self.type = slotType
                }
            else
                {
                context.bind(self.type!,to: self.label)
                }
            }
        else if self.type!.isClass || self.type!.isEnumeration
            {
            context.bind(self.type!,to: self.label)
            }
        else if self.initialValue.isNotNil
            {
            self.type = self.initialValue!.type
            context.bind(self.type!,to: self.label)
            }
        else
            {
            self.enclosingScope.appendIssue(at: self.declaration!, message: "Slot \(self.label) has an invalid type.")
            }
        }
    }

public typealias Slots = Array<Slot>

extension Slots
    {
    public func removeDuplicates() -> Slots
        {
        var seenSlots = Slots()
        for slot in self
            {
            if !seenSlots.contains(slot)
                {
                seenSlots.append(slot)
                }
            }
        return(seenSlots)
        }
    }

public class HiddenSlot: Slot
    {
    public override var isHidden: Bool
        {
        return(true)
        }
    }

public class ScopedSlot: Slot
    {
    }
