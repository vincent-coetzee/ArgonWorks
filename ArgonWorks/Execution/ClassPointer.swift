//
//  ClassPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public class ClassPointer: ClassBasedPointer
    {
    public var instanceObjectType: Argon.ObjectType
        {
        .custom
        }
        
    public var namePointer: StringPointer?
        {
        get
            {
            self.stringPointer(atSlot: "name")
            }
        set
            {
            self.setStringPointer(newValue!,atSlot: "name")
            }
        }
        
    public var nameAddress: Address?
        {
        get
            {
            self.address(atSlot: "name")
            }
        set
            {
            self.setAddress(newValue,atSlot: "name")
            }
        }
        
    public var extraSizeInBytes: Int
        {
        get
            {
            self.integer(atSlot: "extraSizeInBytes")
            }
        set
            {
            self.setInteger(newValue,atSlot: "extraSizeInBytes")
            }
        }
        
    public var classHasBytes: Bool
        {
        get
            {
            self.boolean(atSlot: "hasBytes")
            }
        set
            {
            self.setBoolean(newValue,atSlot: "hasBytes")
            }
        }
        
    public var instanceSizeInBytes: Int
        {
        get
            {
            self.integer(atSlot: "instanceSizeInBytes")
            }
        set
            {
            self.setInteger(newValue,atSlot: "instanceSizeInBytes")
            }
        }

    public var classMagicNumber: Int
        {
        get
            {
            self.integer(atSlot: "magicNumber")
            }
        set
            {
            self.setInteger(newValue,atSlot: "magicNumber")
            }
        }
        
    public var slotsPointer: ArrayPointer?
        {
        get
            {
            self.arrayPointer(atSlot: "slots")
            }
        set
            {
            self.setArrayPointer(newValue!,atSlot: "slots")
            }
        }
        
    public var superclassPointer: ClassPointer?
        {
        get
            {
            ClassPointer(address: self.address(atSlot: "superclass").cleanAddress)
            }
        set
            {
            self.setAddress(newValue!.address.pointerAddress,atSlot: "superclass")
            }
        }
        
    public var subclassesPointer: ArrayPointer?
        {
        get
            {
            self.arrayPointer(atSlot: "subclasses")
            }
        set
            {
            self.setArrayPointer(newValue!,atSlot: "subclasses")
            }
        }
        
    public init(address: Address)
        {
        super.init(address: address.cleanAddress,class: ArgonModule.shared.classType as! TypeClass)
        }
    }
