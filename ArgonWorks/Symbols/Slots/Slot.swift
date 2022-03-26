//
//  Slot.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import AppKit

public struct SlotType: OptionSet
    {
    public static let kInstanceSlot = SlotType(rawValue: 1)
    public static let kModuleSlot = SlotType(rawValue: 1 << 1)
    public static let kSystemHeaderSlot = SlotType(rawValue: 1 << 2)
    public static let kSystemMagicNumberSlot = SlotType(rawValue: 1 << 3)
    public static let kLocalSlot = SlotType(rawValue: 1 << 4)
    public static let kSystemInnerSlot = SlotType(rawValue: 1 << 5)
    public static let kReadOnlySlot = SlotType(rawValue: 1 << 6)
    public static let kSystemClassSlot = SlotType(rawValue: 1 << 7)
    public static let kClassSlot = SlotType(rawValue: 1 << 8)
    public static let kSystemVirtualTableSlot = SlotType(rawValue: 1 << 9)
    
    public let rawValue: Int
    
    public var isInstanceSlot: Bool
        {
        self.contains(.kInstanceSlot)
        }
        
    public init(rawValue: Int)
        {
        self.rawValue = rawValue
        }
        
    public var displayString: String
        {
        var names = Array<String>()
        if self.contains(.kInstanceSlot)
            {
            names.append("Instance")
            }
        if self.contains(.kModuleSlot)
            {
            names.append("Module")
            }
        if self.contains(.kSystemHeaderSlot)
            {
            names.append("System Header")
            }
        if self.contains(.kSystemMagicNumberSlot)
            {
            names.append("System Magic Number")
            }
        if self.contains(.kLocalSlot)
            {
            names.append("Local")
            }
        if self.contains(.kSystemInnerSlot)
            {
            names.append("System Inner")
            }
        if self.contains(.kReadOnlySlot)
            {
            names.append("Read Only")
            }
        if self.contains(.kSystemClassSlot)
            {
            names.append("System Class")
            }
        if self.contains(.kClassSlot)
            {
            names.append("Class")
            }
        if self.contains(.kSystemVirtualTableSlot)
            {
            names.append("System Virtual Table")
            }
        return("["+names.joined(separator: ",")+"]")
        }
        
    public var isSystemSlot: Bool
        {
        self.contains(.kSystemHeaderSlot) || self.contains(.kSystemMagicNumberSlot) || self.contains(.kSystemClassSlot) || self.contains(.kSystemInnerSlot)
        }
    }
    
public class Slot:Symbol
    {
    public override var symbolType: SymbolType
        {
        .slot
        }
        
    public override var segmentType: Segment.SegmentType
        {
        .static
        }
        
    public override var displayName: String
        {
        self.label + "::" + self.type.displayName
        }
        
    public override var argonHash: Int
        {
        var hashValue = self.type.argonHash
        hashValue = hashValue << 13 ^ "\(Swift.type(of: self))".polynomialRollingHash
        hashValue = hashValue << 13 ^ self.label.polynomialRollingHash
        hashValue = hashValue << 13 ^ self.slotType.rawValue
        hashValue = hashValue << 13 ^ self.offset
        return(hashValue)
        }
        
    public override var sizeInBytes: Int
        {
        let type = ArgonModule.shared.slot
        return(type.instanceSizeInBytes)
        }
        
    public var isSytemSymbol: Bool
        {
        false
        }
        
    public var isSystemSlot: Bool
        {
        self.slotType.contains(.kSystemHeaderSlot) || self.slotType.contains(.kSystemMagicNumberSlot) || self.slotType.contains(.kSystemClassSlot) || self.slotType.contains(.kSystemVirtualTableSlot)
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
        
    public var cloned: Self
        {
        let newSlot = Self(label: self.label)
        newSlot.type = self.type
        newSlot.offset = self.offset
        newSlot.owningClass = self.owningClass
        newSlot.initialValue = self.initialValue
        newSlot.slotType = self.slotType
        newSlot.slotSymbol = self.slotSymbol
        return(newSlot)
        }
        
    public var isVirtual: Bool
        {
        return(false)
        }
        
    public var offset = 0
    public var virtualOffset = 0
    public var initialValue: Expression? = nil
    public var isClassSlot = false
    public var slotType: SlotType = .kInstanceSlot
    public var slotSymbol: Int = 0
    public weak var owningClass: TypeClass?
    public var classIndexInVirtualTable = -1
    public var slotInitializerSelector: StaticSymbol?
    public var slotMandatorySelector: StaticSymbol?

    init(label:Label,type:Type? = nil)
        {
        super.init(label:label)
        self.type = type!
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
        self.slotType = SlotType(rawValue: coder.decodeInteger(forKey: "slotType"))
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
    
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let copy = super.substitute(from: substitution)
        copy.offset = self.offset
        copy.initialValue = self.initialValue.isNil ? nil : substitution.substitute(self.initialValue!)
        copy.slotType = self.slotType
        return(copy)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type.lookup(label: label))
        }
        
    public func nameInClass(_ aClass: TypeClass) -> String
        {
        let className = aClass.label.lowercasingFirstLetter
        if self.label == "_header"
            {
            return("_\(className)Header")
            }
        else if self.label == "_magicNumber"
            {
            return("_\(className)MagicNumber")
            }
        else
            {
            return("_\(className)Class")
            }
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
        let slotType = ArgonModule.shared.slot
        let slotPointer = ClassBasedPointer(address: self.memoryAddress,type: slotType)
        slotPointer.setClass(slotType)
        slotPointer.setAddress(self.type.memoryAddress,atSlot: "type")
        slotPointer.setAddress(segment.allocateString(self.label),atSlot: "name")
        slotPointer.setInteger(self.offset,atSlot: "offset")
        slotPointer.setInteger(self.typeCode.rawValue,atSlot: "typeCode")
        slotPointer.setInteger(self.classIndexInVirtualTable,atSlot: "vtIndex")
        if !(self is GlobalSlot || self is ModuleSlot)
            {
            slotPointer.setAddress(self.owningClass!.memoryAddress,atSlot: "owningClass")
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
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? Slot
            {
            return(self.label == second.label && self.type == second.type && self.slotType == second.slotType && self.offset == second.offset)
            }
        return(super.isEqual(object))
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let slot = Self.init(label: label)
        slot.type = self.type.freshTypeVariable(inContext: context)
        slot.offset = self.offset
        slot.initialValue = self.initialValue.isNil ? nil : self.initialValue!.freshTypeVariable(inContext: context)
        slot.slotType = self.slotType
        return(slot)
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.initialValue?.initializeType(inContext: context)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.initialValue?.initializeTypeConstraints(inContext: context)
        if self.initialValue.isNotNil
            {
            context.append(TypeConstraint(left: self.type,right: self.initialValue!.type,origin: .symbol(self)))
            }
        }
        
    public override func inferType(inContext context: TypeContext)
        {
        if self.type.isTypeVariable
            {
            if let slotType = context.lookupBinding(atLabel: self.label)
                {
                self.type = slotType
                }
            else
                {
                context.bind(self.type,to: self.label)
                }
            }
        else if self.type.isClass || self.type.isEnumeration
            {
            context.bind(self.type,to: self.label)
            }
        else if self.initialValue.isNotNil
            {
            self.type = self.initialValue!.type
            context.bind(self.type,to: self.label)
            }
        else
            {
            self.appendIssue(at: self.declaration!, message: "Slot \(self.label) has an invalid type.")
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
