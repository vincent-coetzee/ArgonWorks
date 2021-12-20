//
//  ClassPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public class ClassPointer: ObjectPointer
    {
    public override class func sizeInBytes() -> Int
        {
        168
        }
        
    public var instanceObjectType: Argon.ObjectType
        {
        .custom
        }
        
    public var namePointer: StringPointer?
        {
        get
            {
            StringPointer(dirtyAddress: self.wordPointer[12])
            }
        set
            {
            self.wordPointer[12] = newValue.dirtyAddress
            }
        }
        
    public var nameAddress: Address
        {
        get
            {
            self.wordPointer[12].cleanAddress
            }
        set
            {
            self.wordPointer[12] = newValue.objectAddress
            }
        }
        
    public var extraSizeInBytes: Int
        {
        set
            {
            self.wordPointer[15] = Word(newValue)
            }
        get
            {
            return(Int(self.wordPointer[15]))
            }
        }
        
    public var classHasBytes: Bool
        {
        set
            {
            self.setBoolean(newValue,atIndex: 16)
            }
        get
            {
            return(self.boolean(atIndex: 16))
            }
        }
        
    public var instanceSizeInBytes: Int
        {
        set
            {
            self.wordPointer[17] = Word(newValue)
            }
        get
            {
            return(Int(self.wordPointer[17]))
            }
        }
//
//    public var classMagicNumber: Int
//        {
//        set
//            {
//            self.wordPointer[17] = Word(newValue)
//            }
//        get
//            {
//            return(Int(self.wordPointer[17]))
//            }
//        }
        
    public var slotsPointer: ArrayPointer?
        {
        set
            {
            self.wordPointer[20] = newValue.dirtyAddress.objectAddress
            }
        get
            {
            return(ArrayPointer(dirtyAddress: self.wordPointer[20]))
            }
        }
        
    public var superclassesPointer: ArrayPointer?
        {
        set
            {
            self.wordPointer[22] = newValue.dirtyAddress.objectAddress
            }
        get
            {
            return(ArrayPointer(dirtyAddress: self.wordPointer[22]))
            }
        }
        
    public var subclassesPointer: ArrayPointer?
        {
        set
            {
            self.wordPointer[21] = newValue.dirtyAddress.objectAddress
            }
        get
            {
            return(ArrayPointer(dirtyAddress: self.wordPointer[21]))
            }
        }
    }
