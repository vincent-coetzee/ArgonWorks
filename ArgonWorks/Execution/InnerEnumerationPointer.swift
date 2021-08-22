//
//  InnerEnumerationPointer.swift
//  InnerEnumerationPointer
//
//  Created by Vincent Coetzee on 5/8/21.
//

import Foundation

public class InnerEnumerationPointer: InnerPointer
    {
    public class func allocate(in vm: VirtualMachine) -> InnerEnumerationPointer
        {
        let address = vm.managedSegment.allocateObject(sizeInBytes: Self.kEnumerationSizeInBytes)
        let pointer = InnerEnumerationPointer(address: address)
        pointer.assignSystemSlots(from: vm.topModule.argonModule.enumeration)
        return(pointer)
        }
        
    public var casesPointer: InnerArrayPointer
        {
        get
            {
            if self._casesPointer.isNil
                {
                self._casesPointer = InnerArrayPointer(address: self.slotValue(atKey:"cases"))
                }
            return(self._casesPointer!)
            }
        set
            {
            self.setSlotValue(newValue.address,atKey:"cases")
            self._casesPointer = newValue
            }
        }
        
    public var valueTypePointer: InnerClassPointer
        {
        get
            {
            if self._valueTypePointer.isNil
                {
                self._valueTypePointer = InnerClassPointer(address: self.slotValue(atKey:"valueType"))
                }
            return(self._valueTypePointer!)
            }
        set
            {
            self.setSlotValue(newValue.address,atKey:"valueType")
            self._valueTypePointer = newValue
            }
        }

    private var _valueTypePointer: InnerClassPointer?
    private var _casesPointer: InnerArrayPointer?
    
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kEnumerationSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_TypeHeader","_TypeMagicNumber","_TypeClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","typeCode","cases","rawType"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
