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
        
    public override var type: Type
        {
        return(self._type ?? .class(VoidClass.voidClass))
        }
        
    public var size:Int
        {
        return(MemoryLayout<Word>.size)
        }
        
    public override var displayString: String
        {
        "\(self.label)::\(self._type?.displayString ?? "")"
        }
        
    public override var imageName: String
        {
        "IconSlot"
        }
        
    public override var defaultColor: NSColor
        {
        Palette.shared.currentScheme.dark
        }
        
    public override var weight: Int
        {
        100
        }
        
    public var containedClassParameters: Array<GenericClassParameter>
        {
        return([])
        }
        
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
        let newSlot = Slot(label: self.label,type:self._type)
        newSlot.offset = self.offset
        return(newSlot)
        }
        
    public var isVirtual: Bool
        {
        return(false)
        }
        
    private var _type:Type?
    public private(set) var offset:Int = 0
    public var initialValue: Expression? = nil
    public var isClassSlot = false
    

    init(label:Label,type:Type?)
        {
        self._type = type
        super.init(label:label)
        }
        
    required init(labeled:Label,ofType:Type)
        {
        self._type = ofType
        super.init(label:labeled)
        }

    public required init?(coder: NSCoder)
        {
        self._type = coder.decodeType(forKey: "_type")
        self.offset = coder.decodeInteger(forKey: "offset")
        print("ABOUT TO DECODE AN EXPRESSION IN SLOT")
        self.initialValue = coder.decodeObject(forKey: "initialValue") as? Expression
        print("DECODED EXPRESSION \(Swift.type(of: self.initialValue)) IN SLOT")
        self.isClassSlot = coder.decodeBool(forKey: "isClassSlot")
        super.init(coder: coder)
        }

 
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encodeType(self._type,forKey: "_type")
        coder.encode(self.offset,forKey: "offset")
        coder.encode(self.initialValue,forKey:"initialValue")
        coder.encode(self.isClassSlot,forKey: "isClassSlot")
        }
        
    public func deepCopy() -> Slot
        {
        let newSlot = Slot(label: self.label,type: self._type)
        newSlot.addresses = self.addresses
        newSlot.locations = self.locations
        newSlot.source = self.source
        newSlot._type = self._type
        newSlot.offset = self.offset
        newSlot.initialValue = self.initialValue
        newSlot.isClassSlot = self.isClassSlot
        return(newSlot)
        }
        
    public override func realize(using realizer: Realizer)
        {
        self._type?.realize(using: realizer)
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
        
    public func layoutSymbol(in vm: VirtualMachine)
        {
        guard !self.isMemoryLayoutDone else
            {
            return
            }
        let pointer = InnerSlotPointer.allocate(in: vm)
        self.addresses.append(.absolute(pointer.address))
        assert( self.topModule.argonModule.slot.sizeInBytes == 88)
        pointer.setSlotValue(vm.managedSegment.allocateString(self.label),atKey:"name")
        pointer.setSlotValue(self._type?.memoryAddress ?? 0,atKey:"slotClass")
        pointer.setSlotValue(self.offset,atKey:"offset")
        pointer.setSlotValue(self._type?.typeCode.rawValue ?? 0,atKey:"typeCode")
        self.isMemoryLayoutDone = true
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
