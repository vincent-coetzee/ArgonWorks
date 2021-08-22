//
//  GeneralPointer.swift
//  GeneralPointer
//
//  Created by Vincent Coetzee on 17/8/21.
//

import Foundation

@dynamicMemberLookup
public class GeneralPointer
    {
    private let address: Word
    private var wordPointer: WordPointer?
    private let theClass: Class
    private var virtualMachine: VirtualMachine?
    
    public class func allocateInstance(of aClass:Class,in vm: VirtualMachine) -> GeneralPointer
        {
        let address = vm.managedSegment.allocateObject(sizeInBytes: aClass.innerClassPointer.instanceSizeInBytes)
        let pointer = GeneralPointer(address: address,class: aClass)
        pointer.virtualMachine = vm
        pointer.setValue(aClass.memoryAddress,atLabel: "_classPointer")
        pointer.setValue(aClass.magicNumber,atLabel: "_magicNumber")
        return(pointer)
        }
        
    init(address: Word,class:Class)
        {
        self.theClass = `class`
        self.address = address
        self.wordPointer = WordPointer(address: address)
        }
        
    public func setValue(_ word:Word,atLabel: String)
        {
        if let slot = theClass.layoutSlot(atLabel: atLabel)
            {
            self.wordPointer?[slot.offset / 8] = word
            return
            }
        fatalError("Attempt to set the value of an invalid slot \(atLabel)")
        }
        
    public func setValue(_ value:Int,atLabel: String)
        {
        if let slot = theClass.layoutSlot(atLabel: atLabel)
            {
            self.wordPointer?[slot.offset / 8] = Word(bitPattern: Int64(value))
            return
            }
        fatalError("Attempt to set the value of an invalid slot \(atLabel)")
        }
        
    public func setValue(_ value:String,atLabel: String)
        {
        if let slot = theClass.layoutSlot(atLabel: atLabel),let vm = self.virtualMachine
            {
            let stringPointer = InnerStringPointer.allocateString(value, in: vm)
            self.wordPointer?[slot.offset / 8] = stringPointer.address
            return
            }
        fatalError("Attempt to set the value of an invalid slot \(atLabel)")
        }
        
    public func value(atLabel: String) -> Word
        {
        if let slot = theClass.layoutSlot(atLabel: atLabel)
            {
            return(self.wordPointer?[slot.offset / 8] ?? 0)
            }
        fatalError("Attempt to read the value of an invalid slot \(atLabel)")
        }
        
    public func stringValue(atLabel: String) -> String
        {
        if let slot = theClass.layoutSlot(atLabel: atLabel),let stringAddress = self.wordPointer?[slot.offset / 8]
            {
            return(InnerStringPointer(address: stringAddress).string)
            }
        fatalError("Attempt to read the value of an invalid slot \(atLabel)")
        }
        
    public func arrayElement(atIndex: Int,atLabel: String) -> Word
        {
        let array = self.value(atLabel: atLabel)
        return(InnerArrayPointer(address: array)[atIndex])
        }

    public subscript(dynamicMember key: String) -> Word
        {
        get
            {
            return(self.value(atLabel: key))
            }
        set
            {
            self.setValue(newValue,atLabel: key)
            }
        }
    }
    
