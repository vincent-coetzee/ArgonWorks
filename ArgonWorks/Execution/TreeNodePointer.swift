//
//  TreeNodePointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 24/1/22.
//

import Foundation

public class TreeNodePointer: ClassBasedPointer
    {
    public var stringKey: String
        {
        return(StringPointer(address: self.keyAddress!,argonModule: self.argonModule).string)
        }
        
    public var keyAddress: Address?
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
        
    public var valueAddress: Address?
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
        
    public var leftNodeAddress: Address?
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
        
    public var rightNodeAddress: Address?
        {
        get
            {
            self.address(atIndex: 11)
            }
        set
            {
            self.setAddress(newValue,atIndex: 11)
            }
        }
        
    public var payload1: Word
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
        
    public var payload2: Word
        {
        get
            {
            self.word(atIndex: 13)
            }
        set
            {
            self.setWord(newValue,atIndex: 13)
            }
        }
        
    public var payload3: Word
        {
        get
            {
            self.word(atIndex: 14)
            }
        set
            {
            self.setWord(newValue,atIndex: 14)
            }
        }
        
    public var height: Int
        {
        get
            {
            self.integer(atIndex: 15)
            }
        set
            {
            self.setInteger(newValue,atIndex: 15)
            }
        }
        
    public var leftNodePointer: TreeNodePointer?
        {
        if let address = self.leftNodeAddress,address != 0
            {
            return(TreeNodePointer(dirtyAddress: address,argonModule: self.argonModule))
            }
        return(nil)
        }
        
    public var rightNodePointer: TreeNodePointer?
        {
        if let address = self.rightNodeAddress,address != 0
            {
            return(TreeNodePointer(dirtyAddress: address,argonModule: self.argonModule))
            }
        return(nil)
        }
        
    private let argonModule: ArgonModule
    
    public init(address: Address,argonModule: ArgonModule)
        {
        self.argonModule = argonModule
        super.init(address: address,class: argonModule.treeNode as! TypeClass,argonModule: argonModule)
        }
        
    public init(dirtyAddress: Address,argonModule: ArgonModule)
        {
        self.argonModule = argonModule
        super.init(address: dirtyAddress.cleanAddress,class: argonModule.treeNode as! TypeClass,argonModule: argonModule)
        }
        
    public func deleteNode(forKey: String) -> Address?
        {
        let thisKey = self.stringKey
        if thisKey == forKey
            {
            if self.leftNodeAddress.isNil && self.rightNodeAddress.isNil
                {
                return(nil)
                }
            // only have right subtree
            else if self.leftNodeAddress.isNil
                {
                return(self.rightNodeAddress)
                }
            // only have left subtree
            else if self.rightNodeAddress.isNil
                {
                return(self.leftNodeAddress)
                }
            // we have both subtrees
            else
                {
                let temp = self.rightNodePointer!.minimumValueNode
                self.copyState(from: temp)
                self.rightNodeAddress = self.rightNodePointer?.deleteNode(forKey: temp.stringKey)
                return(self.address)
                }
            }
        else if forKey < thisKey
            {
            self.leftNodeAddress = self.leftNodePointer?.deleteNode(forKey: forKey)
            }
        else
            {
            self.rightNodeAddress = self.rightNodePointer?.deleteNode(forKey: forKey)
            }
        return(self.address)
        }
        
    private var minimumValueNode: TreeNodePointer
        {
        var successor:TreeNodePointer? = self
        while successor.isNotNil && successor!.leftNodeAddress.isNotNil
            {
            successor = successor!.leftNodePointer
            }
        return(successor!)
        }
        
    private func copyState(from node: TreeNodePointer)
        {
        self.keyAddress = node.keyAddress
        self.valueAddress = node.valueAddress
        self.payload1 = node.payload1
        self.payload2 = node.payload2
        self.payload3 = node.payload3
        self.height = node.height
        }
        
    public var balance: Int
        {
//        let right = self.rightNodePointer?.nodeHeight ?? 0
//        let left = self.leftNodePointer?.nodeHeight ?? 0
        let right = self.rightNodePointer?.height ?? 0
        let left = self.leftNodePointer?.height ?? 0
        return(right - left)
        }
        
    public func count(total:inout Int)
        {
        self.leftNodePointer?.count(total: &total)
        total += 1
        self.rightNodePointer?.count(total: &total)
        }
        
    private func rotateLeft() -> TreeNodePointer
        {
        let r = self.rightNodePointer!
        self.rightNodeAddress = r.leftNodeAddress
        r.leftNodeAddress = self.address
        self.height = max(self.leftNodePointer?.height ?? 0,self.rightNodePointer?.height ?? 0) + 1
        r.height = max(r.leftNodePointer?.height ?? 0,r.rightNodePointer?.height ?? 0) + 1
        return(r)
        }
        
    private func rotateRight() -> TreeNodePointer
        {
        let l = self.leftNodePointer!
        self.leftNodeAddress = l.rightNodeAddress
        l.rightNodeAddress = self.address
        self.height = max(self.leftNodePointer?.height ?? 0,self.rightNodePointer?.height ?? 0) + 1
        l.height = max(l.leftNodePointer?.height ?? 0,l.rightNodePointer?.height ?? 0) + 1
        return(l)
        }
        
    private func rotateRightLeft() -> TreeNodePointer
        {
        self.rightNodeAddress = self.rightNodePointer!.rotateRight().address
        let n = self.rotateLeft()
        n.height = max(n.leftNodePointer?.height ?? 0,n.rightNodePointer?.height ?? 0) + 1
        return(n)
        }
        
    private func rotateLeftRight() -> TreeNodePointer
        {
        self.leftNodeAddress = self.leftNodePointer!.rotateLeft().address
        let n = self.rotateRight()
        n.height = max(n.leftNodePointer?.height ?? 0,n.rightNodePointer?.height ?? 0) + 1
        return(n)
        }
        
    public func rebalance() -> TreeNodePointer
        {
//        self.height = self.nodeHeight
        if self.leftNodePointer.isNil || self.rightNodePointer.isNil
            {
            return(self)
            }
        if self.balance < -1 && self.leftNodePointer!.balance <= -1
            {
            print("ROTATE RIGHT")
            return(self.rotateRight())
            }
        else if self.balance > 1 && self.rightNodePointer!.balance >= 1
            {
            print("ROTATE LEFT")
            return(self.rotateLeft())
            }
        else if self.balance < -1 && self.leftNodePointer!.balance >= 1
            {
            print("ROTATE LEFT RIGHT")
            return(self.rotateLeftRight())
            }
        else if self.balance > 1 && self.rightNodePointer!.balance <= -1
            {
            print("ROTATE RIGHT LEFT")
            return(self.rotateRightLeft())
            }
        else
            {
            return(self)
            }
        }
        
    public var nodeHeight: Int
        {
        let left = self.leftNodePointer?.nodeHeight ?? 0
        let right = self.rightNodePointer?.nodeHeight ?? 0
        let theHeight = max(left,right)+1
        self.height = theHeight
        return(theHeight)
        }
        
    public func value(forKey key: String) -> Address?
        {
        let stringKey = StringPointer(address: self.keyAddress!,argonModule: self.argonModule).string
        if stringKey == key
            {
            return(self.valueAddress)
            }
        else if key < stringKey
            {
            if let leftAddress = self.leftNodeAddress
                {
                return(TreeNodePointer(address: leftAddress,argonModule: self.argonModule).value(forKey: key))
                }
            return(nil)
            }
        else
            {
            if let rightAddress = self.rightNodeAddress
                {
                return(TreeNodePointer(address: rightAddress,argonModule: self.argonModule).value(forKey: key))
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
        let stringPointer = StringPointer(address: self.keyAddress!,argonModule: self.argonModule)
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
            return(TreeNodePointer(dirtyAddress: self.leftNodeAddress!,argonModule: self.argonModule).nodeNearestKey(key))
            }
        if key > stringKey
            {
            if self.rightNodeAddress.isNil
                {
                return(self)
                }
            return(TreeNodePointer(dirtyAddress: self.rightNodeAddress!,argonModule: self.argonModule).nodeNearestKey(key))
            }
        return(self)
        }
        
    public func nodeAtKey(_ key: String) -> TreeNodePointer?
        {
        let stringKey = StringPointer(address: self.keyAddress!,argonModule: self.argonModule).string
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
            return(TreeNodePointer(dirtyAddress: self.leftNodeAddress!,argonModule: self.argonModule).nodeAtKey(key))
            }
        if key > stringKey
            {
            if self.rightNodeAddress.isNil
                {
//                print("RETURNING RIGHT(nil)")
                return(nil)
                }
//            print("RETURNING RIGHT")
            return(TreeNodePointer(dirtyAddress: self.rightNodeAddress!,argonModule: self.argonModule).nodeAtKey(key))
            }
        return(nil)
        }
        
    public func printNode()
        {
        if self.leftNodeAddress.isNotNil
            {
            TreeNodePointer(dirtyAddress: self.leftNodeAddress!,argonModule: self.argonModule).printNode()
            }
        let stringPointer = StringPointer(address: self.keyAddress!,argonModule: self.argonModule)
        print("NODE KEY: \(stringPointer.string)")
        if self.rightNodeAddress.isNotNil
            {
            TreeNodePointer(dirtyAddress: self.rightNodeAddress!,argonModule: self.argonModule).printNode()
            }
        }
        
    @discardableResult
    public func setValue(_ value: Address,forKey key:String,inSegment: Segment) -> TreeNodePointer
        {
        let keyString = StringPointer(address: self.keyAddress!,argonModule: self.argonModule).string
        if key < keyString
            {
            if self.leftNodeAddress.isNil
                {
                let address = inSegment.allocateObject(ofType: self.argonModule.treeNode, extraSizeInBytes: 0)
                let pointer = TreeNodePointer(dirtyAddress: address,argonModule: self.argonModule)
                pointer.keyAddress = inSegment.allocateString(key)
                pointer.leftNodeAddress = nil
                pointer.rightNodeAddress = nil
                pointer.valueAddress = value
                pointer.height = 1
                self.leftNodeAddress = address
                self.height = max(1,self.rightNodePointer?.height ?? 0) + 1
                return(pointer)
                }
            else
                {
                let thisPointer = TreeNodePointer(dirtyAddress: self.leftNodeAddress!,argonModule: self.argonModule)
                let pointer = thisPointer.setValue(value,forKey: key,inSegment: inSegment)
                thisPointer.height = max(thisPointer.leftNodePointer?.height ?? 0,thisPointer.rightNodePointer?.height ?? 0) + 1
                return(pointer)
                }
            }
        else if key > keyString
            {
            if self.rightNodeAddress.isNil
                {
                let address = inSegment.allocateObject(ofType: self.argonModule.treeNode, extraSizeInBytes: 0)
                let pointer = TreeNodePointer(dirtyAddress: address,argonModule: self.argonModule)
                pointer.keyAddress = inSegment.allocateString(key)
                pointer.leftNodeAddress = nil
                pointer.rightNodeAddress = nil
                pointer.valueAddress = value
                pointer.height = 1
                self.rightNodeAddress = address
                self.height = max(1,self.leftNodePointer?.height ?? 0) + 1
                return(pointer)
                }
            else
                {
                let thisPointer = TreeNodePointer(dirtyAddress: self.rightNodeAddress!,argonModule: self.argonModule)
                let pointer = thisPointer.setValue(value,forKey: key,inSegment: inSegment)
                thisPointer.height = max(thisPointer.leftNodePointer?.height ?? 0,thisPointer.rightNodePointer?.height ?? 0) + 1
                return(pointer)
                }
            }
        else if key == keyString
            {
            self.valueAddress = value
            return(self)
            }
        else
            {
            fatalError()
            }
        }
        
    public func audit(indent: String)
        {
        print("\(indent)\(StringPointer(address: self.keyAddress!,argonModule: self.argonModule).string)")
        print("\(indent)LEFT HEIGHT : \(self.leftNodePointer?.height ?? 0)")
        print("\(indent)RIGHT HEIGHT: \(self.rightNodePointer?.height ?? 0)")
        print("\(indent)THIS HEIGHT : \(self.height)")
        self.leftNodePointer?.audit(indent: indent + "\t")
        self.rightNodePointer?.audit(indent: indent + "\t")
        }
    }
