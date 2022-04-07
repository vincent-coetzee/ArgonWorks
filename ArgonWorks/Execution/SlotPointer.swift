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
            StringPointer(address: self.address(atSlot: "name")!,argonModule: self.argonModule)
            }
        set
            {
            self.setAddress(newValue.isNil ? 0 : newValue!.address.pointerAddress,atSlot: "name")
            }
        }
        
    public var modulePointer: ClassBasedPointer?
        {
        get
            {
            ClassBasedPointer(address: self.moduleAddress!,class: self.argonModule.moduleType as! TypeClass,argonModule: self.argonModule)
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
            ClassBasedPointer(address: self.typeAddress!,class: self.argonModule.type as! TypeClass,argonModule: self.argonModule)
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
        
    private let argonModule: ArgonModule
    
    init(address: Address,argonModule: ArgonModule)
        {
        self.argonModule = argonModule
        super.init(address: address.cleanAddress,class: argonModule.slot as! TypeClass,argonModule: argonModule)
        }
    }
