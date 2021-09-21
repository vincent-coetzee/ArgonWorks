//
//  InnerInstancePointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation
import Interpreter

public class InnerInstancePointer:InnerPointer
    {
    private struct SlotKey
        {
        internal let name: String
        internal let offset: Int
        }
        
    public static func allocateInstance(ofClass: Class,in vm: VirtualMachine) -> InnerInstancePointer
        {
        let address = vm.managedSegment.allocateObject(sizeInBytes: ofClass.sizeInBytes)
        let pointer = InnerInstancePointer(address: address)
        pointer.initWithClass(ofClass)
        pointer.typeCode = ofClass.typeCode
        return(pointer)
        }
        
    public override var sizeInBytes: Int
        {
        get
            {
            Header(self.slotValue(forKey:"_header")).sizeInWords * 8
            }
        set
            {
            }
        }
        
    public var typeCode: TypeCode
        {
        get
            {
            Header(self.slotValue(forKey:"_header")).typeCode
            }
        set
            {
            var header = Header(self.slotValue(forKey:"_header"))
            header.typeCode = newValue
            self.setSlotValue(header,forKey: "_header")
            }
        }
        
    private var slotKeys: Dictionary<String,SlotKey> = [:]
    
    public func setSlotValue(_ value:Word,forKey: String)
        {
        if let slot = self.slotKeys[forKey]
            {
            self.wordPointer?[slot.offset] = value
            return
            }
        fatalError("Attempt to access invalid slot with key \(forKey)")
        }
        
    public func setSlotValue(_ value:Int,forKey: String)
        {
        if let slot = self.slotKeys[forKey]
            {
            self.wordPointer?[slot.offset] = Word(bitPattern: Int64(value))
            return
            }
        fatalError("Attempt to access invalid slot with key \(forKey)")
        }
        
    public func slotValue(forKey: String) -> Word
        {
        if let slot = self.slotKeys[forKey]
            {
            return(self.wordPointer?[slot.offset] ?? 0)
            }
        fatalError("Attempt to access invalid slot with key \(forKey)")
        }
        
    public func slotIntValue(forKey: String) -> Int
        {
        if let slot = self.slotKeys[forKey]
            {
            return(Int(bitPattern: UInt(self.wordPointer?[slot.offset] ?? 0)))
            }
        fatalError("Attempt to access invalid slot with key \(forKey)")
        }
        
    private func initWithClass(_ aClass:Class)
        {
        for slot in aClass.layoutSlots
            {
            let slotKey = SlotKey(name: slot.label,offset: slot.offset / 8)
            self.slotKeys[slotKey.name] = slotKey
            }
        self.setSlotValue(aClass.memoryAddress,forKey: "_classPointer")
        self.setSlotValue(aClass.magicNumber,forKey: "_magicNumber")
        for someClass in aClass.superclasses
            {
            self.setClassSlots(inClass: aClass,forClass: someClass)
            }
        }
        
    private func setClassSlots(inClass: Class,forClass: Class)
        {
//        let name = forClass.label
        let offset = inClass.offsetOfClass[forClass]
        if offset.isNil
            {
            fatalError("Offset of class \(forClass.label) in class \(inClass.label) is nil can should not be")
            }
        let actualOffset = offset!
        for aSlot in forClass.localSystemSlots
            {
            let slotOffset = aSlot.offset + actualOffset
            if aSlot.offset == 8
                {
                self.setSlotValue(forClass.magicNumber,forKey: aSlot.label)
                }
            else if slotOffset == 16
                {
                self.setSlotValue(forClass.memoryAddress,forKey: aSlot.label)
                }
            }
        for aClass in forClass.superclasses
            {
            self.setClassSlots(inClass: inClass,forClass: aClass)
            }
        }
    }
