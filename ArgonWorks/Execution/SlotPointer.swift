//
//  SlotPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public class SlotPointer: ObjectPointer
    {
    public override class func sizeInBytes() -> Int
        {
        96
        }
        
    public var namePointer: StringPointer?
        {
        get
            {
            StringPointer(dirtyAddress: self.wordPointer[8])
            }
        set
            {
            self.wordPointer[8] = newValue.cleanAddress.objectAddress
            }
        }
        
    public var containerClassPointer: ClassPointer?
        {
        get
            {
            ClassPointer(dirtyAddress: self.containerClassAddress)
            }
        set
            {
            self.containerClassAddress = newValue.cleanAddress.objectAddress
            }
        }
        
    public var containerClassAddress: Address
        {
        get
            {
            self.wordPointer[7]
            }
        set
            {
            self.wordPointer[7] = newValue
            }
        }
        
    public var nameAddress: Address
        {
        get
            {
            self.wordPointer[8].cleanAddress
            }
        set
            {
            self.wordPointer[8] = newValue.objectAddress
            }
        }
        
    public var offset: Int
        {
        set
            {
            self.wordPointer[9] = Word(newValue)
            }
        get
            {
            return(Int(self.wordPointer[9]))
            }
        }
        
    public var typePointer: ClassPointer?
        {
        get
            {
            ClassPointer(dirtyAddress: self.wordPointer[10])
            }
        set
            {
            self.wordPointer[10] = newValue.cleanAddress.objectAddress
            }
        }
        
    public var typeAddress: Address
        {
        get
            {
            self.wordPointer[10].cleanAddress
            }
        set
            {
            self.wordPointer[10] = newValue.objectAddress
            }
        }
    }
