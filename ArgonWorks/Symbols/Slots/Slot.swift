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
    
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type?.lookup(label: label))
        }
        
    public func setOffset(_ integer:Int)
        {
        self.offset = integer
        }
        
    public override func assign(from expression: Expression,into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        try self.emitLValue(into: buffer, using: using)
        try expression.emitRValue(into: buffer,using: using)
        buffer.append("STIP",expression.place,.none,self.place)
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
        slot.type = self.type!.freshTypeVariable(inContext: context)
        return(slot)
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        if self.label == "newArray"
            {
            print("halt")
            }
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
        
//    public func layoutSymbol(in vm: VirtualMachine)
//        {
////        guard !self.isMemoryLayoutDone else
////            {
////            return
////            }
////        let pointer = InnerSlotPointer.allocate(in: vm)
////        self.addresses.append(.absolute(pointer.address))
////        assert( self.topModule.argonModule.slot.sizeInBytes == 88)
////        pointer.setSlotValue(vm.managedSegment.allocateString(self.label),atKey:"name")
//////        pointer.setSlotValue(self._type?.memoryAddress ?? 0,atKey:"slotClass")
////        pointer.setSlotValue(self.offset,atKey:"offset")
//////        pointer.setSlotValue(self._type?.typeCode.rawValue ?? 0,atKey:"typeCode")
////        self.isMemoryLayoutDone = true
//        }
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
