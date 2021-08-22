//
//  ClassPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerClassPointer:InnerPointer
    {
    public var name:String
        {
        get
            {
            return(InnerStringPointer(address: self.slotValue(atKey:"name")).string)
            }
        }
        
    public var slotCount: Int
        {
        return(self.slots.count)
        }
        
    public var instanceSizeInBytes: Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"instanceSizeInBytes")))
            }
        set
            {
            self.setSlotValue(Word(newValue),atKey:"instanceSizeInBytes")
            }
        }
        
    public var instanceSizeInWords: Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"instanceSizeInBytes")) / 8)
            }
        }
        
    public var magicNumber: Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"_magicNumber")))
            }
        set
            {
            self.setSlotValue(Word(newValue),atKey:"_magicNumber")
            }
        }
        
    public var classAddress: Word
        {
        get
            {
            return(self.slotValue(atKey:"_classPointer"))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"_classPointer")
            }
        }
        
    public var extraSizeInBytes: Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"extraSizeInBytes")))
            }
        set
            {
            self.setSlotValue(Word(newValue),atKey:"extraSizeInBytes")
            }
        }
        
    public var typeCode: TypeCode
        {
        get
            {
            let word = self.slotValue(atKey:"typeCode")
            return(TypeCode(rawValue: Int(word))!)
            }
        set
            {
            self.setSlotValue(newValue.rawValue,atKey:"typeCode")
            }
        }
        
    public var superclasses: InnerArrayPointer
        {
        get
            {
            return(InnerArrayPointer(address: self.slotValue(atKey:"superclasses")))
            }
        set
            {
            self.setSlotValue(newValue.address,atKey:"superclasses")
            }
        }
        
    public var slots: InnerArrayPointer
        {
        get
            {
            return(InnerArrayPointer(address: self.slotValue(atKey:"slots")))
            }
        set
            {
            self.setSlotValue(newValue.address,atKey:"slots")
            }
        }
        
    required init(address:Word)
        {
        super.init(address: address)
        self._classPointer = nil
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kClassSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_TypeHeader","_TypeMagicNumber","_TypeClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","typeCode","extraSizeInBytes","hasBytes","instanceSizeInBytes","isValue","magicNumber","slots","superclasses"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
    public func slot(atKey: String) -> InnerSlotPointer?
        {
        if self._keys[atKey].isNotNil
            {
            return(InnerSlotPointer(address: self.slotValue(atKey: atKey)))
            }
        return(nil)
        }
        
    public func setName(_ string:String,in vm: VirtualMachine)
        {
        let stringPointer = InnerStringPointer.allocateString(string,in: vm)
        self.setSlotValue(stringPointer.address,atKey:"name")
        }
        
    public func slot(atIndex:Int) -> InnerSlotPointer
        {
        let slots = InnerArrayPointer(address: self.slotValue(atKey:"slots"))
        return(InnerSlotPointer(address: slots[atIndex]))
        }
    }
