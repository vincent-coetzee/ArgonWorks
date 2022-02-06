//
//  TreeNodePointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 24/1/22.
//

import Foundation

public class TreeNodePointer: ObjectPointer
    {
    public var keyAddress: Address?
        {
        get
            {
            self.address(atIndex: 7)
            }
        set
            {
            self.setAddress(newValue,atIndex: 7)
            }
        }
        
    public var valueAddress: Address?
        {
        get
            {
            self.address(atIndex: 8)
            }
        set
            {
            self.setAddress(newValue,atIndex: 8)
            }
        }
        
    public var leftNodeAddress: Address?
        {
        get
            {
            self.address(atIndex: 9)
            }
        set
            {
            self.setAddress(newValue,atIndex: 9)
            }
        }
        
    public var rightNodeAddress: Address?
        {
        get
            {
            self.address(atIndex: 10)
            }
        set
            {
            self.setAddress(newValue,atIndex: 10)
            }
        }
        
    public var payload1: Word
        {
        get
            {
            self.word(atIndex: 11)
            }
        set
            {
            self.setAddress(newValue,atIndex: 11)
            }
        }
        
    public var payload2: Word
        {
        get
            {
            self.word(atIndex: 12)
            }
        set
            {
            self.setWord(newValue,atIndex: 12)
            }
        }
        
    public var payload3: Int
        {
        get
            {
            self.integer(atIndex: 13)
            }
        set
            {
            self.setInteger(newValue,atIndex: 13)
            }
        }
        
    public func value(forKey key: String) -> Address?
        {
        let stringKey = StringPointer(dirtyAddress: self.keyAddress!)!.string
        if stringKey == key
            {
            return(self.valueAddress)
            }
        else if key < stringKey
            {
            if let leftAddress = self.leftNodeAddress
                {
                return(TreeNodePointer(dirtyAddress: leftAddress)!.value(forKey: key))
                }
            return(nil)
            }
        else
            {
            if let rightAddress = self.rightNodeAddress
                {
                return(TreeNodePointer(dirtyAddress: rightAddress)!.value(forKey: key))
                }
            return(nil)
            }
        }
        
//    public func value(forKey keyAddress: Address) -> Address?
//        {
//        let theHash = self.hashValue
//        if theHash == hashValue
//            {
//            if let middleAddress = self.middleNodeAddress
//                {
//                return(TreeNodePointer(dirtyAddress: middleAddress)!.value(forKey: keyAddress,hashValue: hashValue))
//                }
//            if self.keyAddress == keyAddress
//                {
//                return(self.valueAddress)
//                }
//            return(nil)
//            }
//        else if hashValue < self.hashValue
//            {
//            if let leftAddress = self.leftNodeAddress
//                {
//                return(TreeNodePointer(dirtyAddress: leftAddress)!.value(forKey: keyAddress,hashValue: hashValue))
//                }
//            return(nil)
//            }
//        else
//            {
//            if let rightAddress = self.rightNodeAddress
//                {
//                return(TreeNodePointer(dirtyAddress: rightAddress)!.value(forKey: keyAddress,hashValue: hashValue))
//                }
//            return(nil)
//            }
//        }
        
    public func nodeNearestKey(_ key: String) -> TreeNodePointer
        {
        let stringPointer = StringPointer(dirtyAddress: self.keyAddress!)!
        let stringKey = stringPointer.string
        if stringKey == key
            {
            return(self)
            }
        if key < stringKey
            {
            if self.leftNodeAddress.isNil
                {
                return(self)
                }
            return(TreeNodePointer(dirtyAddress: self.leftNodeAddress!)!.nodeNearestKey(key))
            }
        if key > stringKey
            {
            if self.rightNodeAddress.isNil
                {
                return(self)
                }
            return(TreeNodePointer(dirtyAddress: self.rightNodeAddress!)!.nodeNearestKey(key))
            }
        return(self)
        }
        
    public func nodeAtKey(_ key: String) -> TreeNodePointer?
        {
        let stringKey = StringPointer(dirtyAddress: self.keyAddress!)!.string
        print("NODE \(self.cleanAddress)")
        print("NODE KEY = \(stringKey)")
        print("COMPARING \(key) WITH \(stringKey)")
        if stringKey == key
            {
            print("RETURNING SELF")
            return(self)
            }
        if key < stringKey
            {
            if self.leftNodeAddress.isNil
                {
                print("RETURNING LEFT(nil)")
                return(nil)
                }
            print("RETURNING LEFT")
            return(TreeNodePointer(dirtyAddress: self.leftNodeAddress!)!.nodeAtKey(key))
            }
        if key > stringKey
            {
            if self.rightNodeAddress.isNil
                {
                print("RETURNING RIGHT(nil)")
                return(nil)
                }
            print("RETURNING RIGHT")
            return(TreeNodePointer(dirtyAddress: self.rightNodeAddress!)!.nodeAtKey(key))
            }
        return(nil)
        }
        
    public func printNode()
        {
        if self.leftNodeAddress.isNotNil
            {
            TreeNodePointer(dirtyAddress: self.leftNodeAddress!)!.printNode()
            }
        let stringPointer = StringPointer(dirtyAddress: self.keyAddress!)!
        print("NODE KEY: \(stringPointer.string)")
        if self.rightNodeAddress.isNotNil
            {
            TreeNodePointer(dirtyAddress: self.rightNodeAddress!)!.printNode()
            }
        }
        
    public func setValue(_ value: Address,forKey key:String,inSegment: Segment) -> TreeNodePointer
        {
        let keyString = StringPointer(dirtyAddress: self.keyAddress!)!.string
        if key < keyString
            {
            if self.leftNodeAddress.isNil
                {
                let address = inSegment.allocateObject(ofType: ArgonModule.shared.treeNode, extraSizeInBytes: 0)
                let pointer = TreeNodePointer(dirtyAddress: address)!
                pointer.keyAddress = inSegment.allocateString(key)
                pointer.leftNodeAddress = nil
                pointer.rightNodeAddress = nil
                pointer.valueAddress = value
                self.leftNodeAddress = address
                return(pointer)
                }
            else
                {
                return(TreeNodePointer(dirtyAddress: self.leftNodeAddress!)!.setValue(value,forKey: key,inSegment: inSegment))
                }
            }
        else if key > keyString
            {
            if self.rightNodeAddress.isNil
                {
                let address = inSegment.allocateObject(ofType: ArgonModule.shared.treeNode, extraSizeInBytes: 0)
                let pointer = TreeNodePointer(dirtyAddress: address)!
                pointer.keyAddress = inSegment.allocateString(key)
                pointer.leftNodeAddress = nil
                pointer.rightNodeAddress = nil
                pointer.valueAddress = value
                self.rightNodeAddress = address
                return(pointer)
                }
            else
                {
                return(TreeNodePointer(dirtyAddress: self.rightNodeAddress!)!.setValue(value,forKey: key,inSegment: inSegment))
                }
            }
        else if key == keyString
            {
            if key == keyString
                {
                self.valueAddress = value
                return(self)
                }
            else
                {
                let address = inSegment.allocateObject(ofType: ArgonModule.shared.treeNode, extraSizeInBytes: 0)
                let pointer = TreeNodePointer(dirtyAddress: address)!
                pointer.keyAddress = inSegment.allocateString(key)
                pointer.leftNodeAddress = nil
                pointer.rightNodeAddress = nil
                pointer.valueAddress = value
                return(pointer)
                }
            }
        else
            {
            fatalError()
            }
        }
    }
