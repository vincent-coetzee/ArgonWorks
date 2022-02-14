//
//  TreeNodePointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 24/1/22.
//

import Foundation

public class TreeNodePointer: ClassBasedPointer
    {
    public var keyAddress: Address?
        {
        get
            {
            self.address(atSlot: "key")
            }
        set
            {
            self.setAddress(newValue,atSlot:"key")
            }
        }
        
    public var valueAddress: Address?
        {
        get
            {
            self.address(atSlot: "value")
            }
        set
            {
            self.setAddress(newValue,atSlot: "value")
            }
        }
        
    public var leftNodeAddress: Address?
        {
        get
            {
            self.address(atSlot: "leftNode")
            }
        set
            {
            self.setAddress(newValue,atSlot: "leftNode")
            }
        }
        
    public var rightNodeAddress: Address?
        {
        get
            {
            self.address(atSlot: "rightNode")
            }
        set
            {
            self.setAddress(newValue,atSlot: "rightNode")
            }
        }
        
    public var payload1: Word
        {
        get
            {
            self.word(atSlot: "payload1")
            }
        set
            {
            self.setWord(newValue,atSlot: "payload1")
            }
        }
        
    public var payload2: Word
        {
        get
            {
            self.word(atSlot: "payload2")
            }
        set
            {
            self.setWord(newValue,atSlot: "payload2")
            }
        }
        
    public var payload3: Int
        {
        get
            {
            self.integer(atSlot: "payload3")
            }
        set
            {
            self.setInteger(newValue,atSlot: "payload3")
            }
        }
        
    public static func rotateRight(node: TreeNodePointer,inSegment: Segment) -> TreeNodePointer
        {
        let left = node.leftNodeAddress!
        let leftPointer = TreeNodePointer(dirtyAddress: left)
        let newNode = inSegment.allocateObject(ofType: ArgonModule.shared.treeNode, extraSizeInBytes: 0)
        let newPointer = TreeNodePointer(dirtyAddress: newNode)
        newPointer.copyState(from: node)
        newPointer.leftNodeAddress = leftPointer.rightNodeAddress
        newPointer.rightNodeAddress = node.rightNodeAddress
        let nodeR = inSegment.allocateObject(ofType: ArgonModule.shared.treeNode, extraSizeInBytes: 0)
        let nodeRPointer = TreeNodePointer(dirtyAddress: nodeR)
        nodeRPointer.leftNodeAddress = leftPointer.leftNodeAddress
        nodeRPointer.rightNodeAddress = newNode
        nodeRPointer.copyState(from: leftPointer)
        return(nodeRPointer)
        }
        
    public init(address: Address)
        {
        super.init(address: address,class: ArgonModule.shared.treeNode as! TypeClass)
        }
        
    public init(dirtyAddress: Address)
        {
        super.init(address: dirtyAddress.cleanAddress,class: ArgonModule.shared.treeNode as! TypeClass)
        }
        
    private func copyState(from node: TreeNodePointer)
        {
        self.keyAddress = node.keyAddress
        self.valueAddress = node.valueAddress
        self.payload1 = node.payload1
        self.payload2 = node.payload2
        self.payload3 = node.payload3
        }
        
    public func value(forKey key: String) -> Address?
        {
        let stringKey = StringPointer(address: self.keyAddress!).string
        if stringKey == key
            {
            return(self.valueAddress)
            }
        else if key < stringKey
            {
            if let leftAddress = self.leftNodeAddress
                {
                return(TreeNodePointer(address: leftAddress).value(forKey: key))
                }
            return(nil)
            }
        else
            {
            if let rightAddress = self.rightNodeAddress
                {
                return(TreeNodePointer(address: rightAddress).value(forKey: key))
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
        let stringPointer = StringPointer(address: self.keyAddress!)
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
            return(TreeNodePointer(dirtyAddress: self.leftNodeAddress!).nodeNearestKey(key))
            }
        if key > stringKey
            {
            if self.rightNodeAddress.isNil
                {
                return(self)
                }
            return(TreeNodePointer(dirtyAddress: self.rightNodeAddress!).nodeNearestKey(key))
            }
        return(self)
        }
        
    public func nodeAtKey(_ key: String) -> TreeNodePointer?
        {
        let stringKey = StringPointer(address: self.keyAddress!).string
//        print("NODE \(self.someAddress)")
//        print("NODE KEY = \(stringKey)")
//        print("COMPARING \(key) WITH \(stringKey)")
        if stringKey == key
            {
//            print("RETURNING SELF")
            return(self)
            }
        if key < stringKey
            {
            if self.leftNodeAddress.isNil
                {
//                print("RETURNING LEFT(nil)")
                return(nil)
                }
//            print("RETURNING LEFT")
            return(TreeNodePointer(dirtyAddress: self.leftNodeAddress!).nodeAtKey(key))
            }
        if key > stringKey
            {
            if self.rightNodeAddress.isNil
                {
//                print("RETURNING RIGHT(nil)")
                return(nil)
                }
//            print("RETURNING RIGHT")
            return(TreeNodePointer(dirtyAddress: self.rightNodeAddress!).nodeAtKey(key))
            }
        return(nil)
        }
        
    public func printNode()
        {
        if self.leftNodeAddress.isNotNil
            {
            TreeNodePointer(dirtyAddress: self.leftNodeAddress!).printNode()
            }
//        let stringPointer = StringPointer(address: self.keyAddress!)
//        print("NODE KEY: \(stringPointer.string)")
        if self.rightNodeAddress.isNotNil
            {
            TreeNodePointer(dirtyAddress: self.rightNodeAddress!).printNode()
            }
        }
        
    public func setValue(_ value: Address,forKey key:String,inSegment: Segment) -> TreeNodePointer
        {
        let keyString = StringPointer(address: self.keyAddress!).string
        if key < keyString
            {
            if self.leftNodeAddress.isNil
                {
                let address = inSegment.allocateObject(ofType: ArgonModule.shared.treeNode, extraSizeInBytes: 0)
                let pointer = TreeNodePointer(dirtyAddress: address)
                pointer.keyAddress = inSegment.allocateString(key)
                pointer.leftNodeAddress = nil
                pointer.rightNodeAddress = nil
                pointer.valueAddress = value
                self.leftNodeAddress = address
                return(pointer)
                }
            else
                {
                return(TreeNodePointer(dirtyAddress: self.leftNodeAddress!).setValue(value,forKey: key,inSegment: inSegment))
                }
            }
        else if key > keyString
            {
            if self.rightNodeAddress.isNil
                {
                let address = inSegment.allocateObject(ofType: ArgonModule.shared.treeNode, extraSizeInBytes: 0)
                let pointer = TreeNodePointer(dirtyAddress: address)
                pointer.keyAddress = inSegment.allocateString(key)
                pointer.leftNodeAddress = nil
                pointer.rightNodeAddress = nil
                pointer.valueAddress = value
                self.rightNodeAddress = address
                return(pointer)
                }
            else
                {
                return(TreeNodePointer(dirtyAddress: self.rightNodeAddress!).setValue(value,forKey: key,inSegment: inSegment))
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
                let pointer = TreeNodePointer(dirtyAddress: address)
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
