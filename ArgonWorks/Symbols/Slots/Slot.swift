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
        super.init(coder: coder)
        self.type = coder.decodeObject(forKey: "_type") as? Type
//        print("END DECODE SLOT \(self.label)")
        }

    public required init(label: Label)
        {
        super.init(label: label)
        self.type = TypeContext.freshTypeVariable()
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.type,forKey: "_type")
        coder.encode(self.offset,forKey: "offset")
        coder.encode(self.initialValue,forKey:"initialValue")
        coder.encode(self.isClassSlot,forKey: "isClassSlot")
        super.encode(with: coder)
        }
        
    public override func deepCopy() -> Self
        {
        let newSlot = super.deepCopy()
        newSlot.type = self.type
        newSlot.addresses = self.addresses
        newSlot.locations = self.locations
        newSlot.source = self.source
        newSlot.offset = self.offset
        newSlot.initialValue = self.initialValue
        newSlot.isClassSlot = self.isClassSlot
        return(newSlot)
        }
    
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type?.lookup(label: label))
        }
        
    public func setOffset(_ integer:Int)
        {
        self.offset = integer
        }
        
    public func printFormattedSlotContents(base:WordPointer)
        {
        let offsetValue = self.offset
        let offsetString = String(format: "%08X",offsetValue)
        let name = self.label.aligned(.left,in:25)
        let word = base.word(atByteOffset: offsetValue)
        print("\(offsetString) \(name) WRD \(word.bitString) \(word)")
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
        
    public override func initializeType(inContext context: TypeContext) throws
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
            fatalError("This should not happen.")
            }
        }
        
    public func layoutSymbol(in vm: VirtualMachine)
        {
//        guard !self.isMemoryLayoutDone else
//            {
//            return
//            }
//        let pointer = InnerSlotPointer.allocate(in: vm)
//        self.addresses.append(.absolute(pointer.address))
//        assert( self.topModule.argonModule.slot.sizeInBytes == 88)
//        pointer.setSlotValue(vm.managedSegment.allocateString(self.label),atKey:"name")
////        pointer.setSlotValue(self._type?.memoryAddress ?? 0,atKey:"slotClass")
//        pointer.setSlotValue(self.offset,atKey:"offset")
////        pointer.setSlotValue(self._type?.typeCode.rawValue ?? 0,atKey:"typeCode")
//        self.isMemoryLayoutDone = true
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
