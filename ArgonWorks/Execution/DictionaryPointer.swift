//
//  DictionaryPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 30/1/22.
//

import Foundation
    
public class DictionaryPointer: ClassBasedPointer
    {
    public var count: Int
        {
        self.countNodes()
        }
        
    public var rootAddress: Address?
        {
        get
            {
            self.address(atSlot: "rootNode")
            }
        set
            {
            self.setAddress(newValue,atSlot: "rootNode")
            }
        }
        
    private var rootNode: TreeNodePointer?
    private let segment: Segment
    private var _count: Int = 0
    
    public init(address: Address,inSegment segment: Segment)
        {
        self.segment = segment
        super.init(address: address.cleanAddress,class: segment.argonModule.dictionary as! TypeClass,argonModule: segment.argonModule)
        self.rootNode = self.rootAddress.isNil ? nil : TreeNodePointer(address: self.rootAddress!,argonModule: segment.argonModule)
        }
        
    public func setValue(_ value: Address,forKey: String)
        {
        if self.rootNode.isNil
            {
            self.rootAddress = self.segment.allocateObject(ofType: segment.argonModule.treeNode)
            self.rootNode = TreeNodePointer(address: self.rootAddress!,argonModule: segment.argonModule)
            self.rootNode?.valueAddress = value
            self.rootNode?.keyAddress = self.segment.allocateString(forKey)
            self.rootNode?.height = 1
            }
        else
            {
            self.rootNode?.setValue(value,forKey: forKey,inSegment: self.segment)
            self.rootAddress = self.rootNode!.rebalance().address
            self.rootNode = TreeNodePointer(address: self.rootAddress!,argonModule: segment.argonModule)
            }
        }
        
    public func printBalance()
        {
        print("LEFT HEIGHT = \(self.rootNode!.leftNodePointer!.height)")
        print("RIGHT HEIGHT = \(self.rootNode!.rightNodePointer?.height)")
        print("LEFT NODE HEIGHT = \(self.rootNode!.leftNodePointer!.nodeHeight)")
        print("RIGHT NODE HEIGHT = \(self.rootNode!.rightNodePointer?.nodeHeight)")
        print("BALANCE = \(self.rootNode!.balance)")
        }
        
    public func audit()
        {
        self.rootNode?.audit(indent: "")
        }
        
    private func setRootAddress(_ address: Address?)
        {
        self.rootAddress = address
        if address.isNil
            {
            self.rootNode = nil
            }
        else
            {
            self.rootNode = TreeNodePointer(address: address!,argonModule: segment.argonModule)
            }
        }
        
    public func value(forKey: String) -> Address?
        {
        return(self.rootNode?.value(forKey: forKey))
        }
        
    private func countNodes() -> Int
        {
        var total = 0
        self.rootNode?.count(total: &total)
        return(total)
        }
        
    public func deleteNode(forKey: String)
        {
        guard self.rootNode.isNotNil else
            {
            return
            }
        let rootKey = self.rootNode!.stringKey
        if forKey == rootKey
            {
            if self.rootNode!.leftNodeAddress.isNil
                {
                self.setRootAddress(self.rootNode!.rightNodeAddress)
                }
            else if rootNode!.rightNodeAddress.isNil
                {
                self.setRootAddress(self.rootNode!.leftNodeAddress)
                }
            else
                {
                self.setRootAddress(nil)
                }
            }
        else if forKey < rootKey
            {
            self.rootNode!.leftNodeAddress = self.rootNode!.leftNodePointer?.deleteNode(forKey: forKey)
            }
        else
            {
            self.rootNode!.rightNodeAddress = self.rootNode!.rightNodePointer?.deleteNode(forKey: forKey)
            }
        }
        
    public func dump()
        {
        self.rootNode?.printNode()
        }
    }
