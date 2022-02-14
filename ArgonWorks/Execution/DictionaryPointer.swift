//
//  DictionaryPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 30/1/22.
//

import Foundation
    
public class DictionaryPointer: ObjectPointer
    {
//    private static let sizeInBytes = 112
//        
//    private static let primes = [1223,4391,7879,11587,21269,41893,81353,160553,331249]
//    
//    private var prime: Word
//        {
//        self.word(atIndex: 13)
//        }
//        
//    public var count: Int
//        {
//        get
//            {
//            self.integer(atIndex: 10)
//            }
//        set
//            {
//            self.setInteger(newValue,atIndex: 10)
//            }
//        }
//        
//    public var size: Int
//        {
//        get
//            {
//            self.integer(atIndex: 11)
//            }
//        set
//            {
//            self.setInteger(newValue,atIndex: 11)
//            }
//        }
//        
//    private let segment: Segment
//        
//    public convenience init?(inSegment: Segment)
//        {
//        let address = inSegment.allocateObject(ofType: ArgonModule.shared.dictionary,extraSizeInBytes: 0)
//        self.init(dirtyAddress: address,inSegment: inSegment)
//        }
//        
//    public init?(dirtyAddress: Address,inSegment: Segment)
//        {
//        self.segment = inSegment
//        super.init(dirtyAddress: dirtyAddress)
//        }
//        
//    public required init?(dirtyAddress: Address)
//        {
//        fatalError()
//        }
//        
//    public func value(forKey string: String) -> TreeNodePointer?
//        {
//        if let address = self.address(atIndex: 13)
//            {
//            let rootNode = TreeNodePointer(dirtyAddress: address)!
//            if let address = rootNode.value(forKey: string)
//                {
//                return(TreeNodePointer(dirtyAddress: address))
//                }
//            return(nil)
//            }
//        else
//            {
//            return(nil)
//            }
//        }
        
//    public func setValue(_ value: Address,forKey: String)
//        {
//        if let address = self.address(atIndex: 13)
//            {
//            let rootNode = TreeNodePointer(dirtyAddress: address)!
//            rootNode.setValue(value,forKey: forKey,inSegment: self.segment)
//            }
//        else
//            {
//            let rootAddress = self.segment.allocateObject(ofType: ArgonModule.shared.treeNode, extraSizeInBytes: 0)
//            let rootNode = TreeNodePointer(dirtyAddress: rootAddress)!
//            rootNode.leftNodeAddress = 0
//            rootNode.rightNodeAddress = 0
//            rootNode.keyAddress = self.segment.allocateString(forKey)
//            rootNode.valueAddress = value
//            self.setAddress(rootAddress,atIndex: 13)
//            }
//        }
    }
