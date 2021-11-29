//
//  InnerEnumerationCasePointer.swift
//  InnerEnumerationCasePointer
//
//  Created by Vincent Coetzee on 5/8/21.
//

import Foundation

public class InnerEnumerationCasePointer: InnerPointer
    {
    public class func allocate(in vm: VirtualMachine) -> InnerEnumerationCasePointer
        {
        let address = vm.managedSegment.allocateObject(sizeInBytes: Self.kEnumerationCaseSizeInBytes)
        let pointer = InnerEnumerationCasePointer(address: address)
//        pointer.assignSystemSlots(from: vm.topModule.argonModule.enumerationCase)
        return(pointer)
        }
        
    public var associatedTypesPointer: InnerArrayPointer
        {
        get
            {
            if self._associatedTypesPointer.isNil
                {
                self._associatedTypesPointer = InnerArrayPointer(address: self.slotValue(atKey:"associatedTypes"))
                }
            return(self._associatedTypesPointer!)
            }
        set
            {
            self.setSlotValue(newValue.address,atKey:"associatedTypes")
            self._associatedTypesPointer = newValue
            }
        }
        
    public var index: Int
        {
        get
            {
            return(Int(slotValue(atKey: "index")))
            }
        set
            {
            self.setSlotValue(Word(bitPattern: newValue),atKey: "index")
            }
        }
        
    public var enumerationPointer: InnerEnumerationPointer
        {
        get
            {
            if self._enumerationPointer.isNil
                {
                self._enumerationPointer = InnerEnumerationPointer(address: self.slotValue(atKey:"enumeration"))
                }
            return(self._enumerationPointer!)
            }
        set
            {
            self.setSlotValue(newValue.address,atKey:"enumeration")
            self._enumerationPointer = newValue
            }
        }
        
    private var _associatedTypesPointer:InnerArrayPointer?
    private var _enumerationPointer: InnerEnumerationPointer?
    
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kEnumerationCaseSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","associatedTypes","caseSizeInBytes","enumeration","index","rawType","symbol"]

        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
