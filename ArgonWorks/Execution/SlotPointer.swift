//
//  SlotPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public class SlotPointer: ClassBasedPointer
    {
    public var namePointer: StringPointer?
        {
        get
            {
            StringPointer(dirtyAddress: self.address(atSlot: "name")!)
            }
        set
            {
            self.setAddress(newValue.isNil ? 0 : newValue!.cleanAddress.pointerAddress,atSlot: "name")
            }
        }
        
    public var modulePointer: ClassBasedPointer?
        {
        get
            {
            ClassBasedPointer(address: self.moduleAddress!,class: ArgonModule.shared.moduleType as! TypeClass)
            }
        set
            {
            self.moduleAddress = newValue!.address.pointerAddress
            }
        }
        
    public var moduleAddress: Address?
        {
        get
            {
            self.address(atSlot: "module")
            }
        set
            {
            self.setAddress(newValue,atSlot: "module")
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
        
    public var offset: Int
        {
        get
            {
            self.integer(atSlot: "offset")
            }
        set
            {
            self.setInteger(newValue,atSlot: "offset")
            }
        }
        
    public var typePointer: ClassBasedPointer?
        {
        get
            {
            ClassBasedPointer(address: self.typeAddress!,class: ArgonModule.shared.type as! TypeClass)
            }
        set
            {
            self.typeAddress = newValue!.address.pointerAddress
            }
        }
        
    public var typeAddress: Address?
        {
        get
            {
            self.address(atSlot: "type")
            }
        set
            {
            self.setAddress(newValue,atSlot: "type")
            }
        }
        
    init(address: Address)
        {
        super.init(address: address.cleanAddress,class: ArgonModule.shared.slot as! TypeClass)
        }
    }
