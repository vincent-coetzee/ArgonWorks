//
//  PersistentDictionary.swift
//  PersistentDictionary
//
//  Created by Vincent Coetzee on 15/8/21.
//

import Foundation
//
//public typealias Strings = Array<String>
//private typealias Children = Array<BTreeNode?>
//public typealias StringHandles = Array<StringHandle?>
//public typealias PageAddress = Int
//
//public class BTreeKeyValue
//    {
//    public var key: String?
//    private let keyHandle: ObjectHandle
//    private let valueHandle: ObjectHandle?
//    private var pageAddress: Word?
//    private var page: BTreeNode?
//    
//    init(key: String,value: ObjectHandle,pageAddress: Word)
//        {
//        self.key = key
//        self.valueHandle = value
//        self.pageAddress = pageAddress
//        self.keyHandle = 0
//        }
//        
//    init(key: ObjectHandle,value: ObjectHandle?,pageAddress: Word?)
//        {
//        self.keyHandle = key
//        self.valueHandle = value
//        self.pageAddress = pageAddress
//        }
//        
////    public func isLessThan(key: String) -> Bool
////        {
////        /// load key if not loaded and cache it so it
////        /// can be reused
////        }
////
////    public func isEqualTo(key: String) -> Bool
////        {
////        /// load key if not loaded and cache it so it
////        /// can be reused
////        }
//        
//    public func traverse()
//        {
//        self.page?.traverse()
//        }
//        
//    internal func loadPage()
//        {
//        }
//        
//    internal func search(key: String) -> BTreeKeyValue?
//        {
//        return(self.page?.search(key: key))
//        }
//    }
//    
//public class BTreeNode
//    {
//    private static let kDegreeOffset = 88
//    private static let kisLeafOffset = 96
//    private static let kKeyCountOffset = 104
//    
//    private static let kKeysPerPage = 500
//    
//    internal var keyValues = Array<BTreeKeyValue?>(repeating: nil, count: BTreeNode.kKeysPerPage)
//    internal var keyCount: Int = 0
//    private var isLeaf: Bool = false
//    private var degree: Int = 0
//
////    init(page: Page)
////        {
////        self.page = page
////        self.degree = self.page.intValue(atOffset: Self.kDegreeOffset)
////        self.isLeaf = self.page.intValue(atOffset: Self.kisLeafOffset) == 1
////        self.keyCount = self.page.intValue(atOffset: Self.kKeyCountOffset)
////        }
//
//    init(degree: Int,isLeaf: Bool)
//        {
//        self.isLeaf = isLeaf
//        self.degree = degree
//        self.keyCount = 0
//        }
//        
//    private func binarySearchKeys(for: String) -> BTreeKeyValue?
//        {
//        return(nil)
//        }
//        
//    public func search(key: String) -> BTreeKeyValue?
//        {
//        var index = 0
//        while index < self.keyCount && key > self.keyValues[index]!.key!
//            {
//            index += 1
//            }
//        if index < self.keyCount && key == self.keyValues[index]!.key!
//            {
//            return(self.keyValues[index])
//            }
//        if self.isLeaf
//            {
//            return(nil)
//            }
//        return(self.keyValues[index]?.search(key: key))
//        }
//        
//    public func traverse()
//        {
//        var index = 0
//        while index < self.keyCount
//            {
//            if !self.isLeaf
//                {
//                self.keyValues[index]?.traverse()
//                }
//            index += 1
//            }
//        if !self.isLeaf
//            {
//            self.keyValues[index]?.traverse()
//            }
//        }
//        
//    public func insert(key: String,value: Word,at index: Int)
//        {
//        for item in stride(from: self.keyCount - 1,through: index + 1,by: 1)
//            {
//            self.keyValues[item] = self.keyValues[item - 1]
//            }
//        self.keyValues[index] = BTreeKeyValue(key: key,value: value,pageAddress: 0)
//        }
//        
//    public func insert(key: String,value: Word)
//        {
//        var index = 0
//        while self.keyValues[index]!.key! < key && index < self.keyCount
//            {
//            index += 1
//            }
//        if self.isLeaf
//            {
//            self.insert(key: key,value: value,at: index)
//            }
//        else
//            {
//            if self.
//            }
//        }
//        
//    public func splitChild(index: Int,newNode: BTreeNode)
//        {
//        }
//    }
//    
//public class BTree
//    {
//    private var root: BTreeNode?
//    private let degree: Int
//    
//    init(degree: Int)
//        {
//        self.degree = degree
//        }
//        
//    public func search(key: String) -> BTreeKeyValue?
//        {
//        return(self.root?.search(key: key))
//        }
//        
//    public func insert(key: String,value: Word)
//        {
//        if self.root.isNil
//            {
//            self.root = BTreeNode(degree: self.degree,isLeaf: true)
//            }
//        self.root?.insert(key: key,value: value)
//        }
//    }
//    
//    
//private class BTree
//    {
//    private var root: BTreeNode?
//    private var rootHandle: ObjectHandle?
//    private let degree: Int
//
//    init(degree: Int)
//        {
//        self.degree = degree
//        self.root = nil
//        }
//
//    public func create()
//        {
//        let page = PageServer.shared.findOrMakePage()
//        let node = BTreeNode(degree: self.degree,isLeaf: true,page: page)
//        /// TODO:
//        /// config this as a root
//        page.writeNew(pageServer: PageServer.shared)
//        self.root = node
//        }
//
//    public func traverse()
//        {
//        self.root?.traverse()
//        }
//
//    public func search(key: String) -> BTreeKeyValue?
//        {
//        return(root?.search(key: key))
//        }
//
//    public func insert(key: String,value: Word)
//        {
//        if root.isNil
//            {
//            root = BTreeNode(degree: self.degree,isLeaf: true)
//            root?.keyValues[0] = BTreeKeyValue(key: key,value: 0,pageAddress: 0)
//            root?.keyCount = 1
//            }
//        else
//            {
//            if root!.keyCount == 2 * self.degree - 1
//                {
//                let newNode = BTreeNode(degree: self.degree, isLeaf: false)
//                PageServer.writeNewPage
//                }
//            }
//        }
//    }
//    
//public class PersistentDictionary
//    {
//    private static let kPrimeOffset = Page.kFirstOffset
//    private static let kCountOffset = Page.kFirstOffset + MemoryLayout<Word>.size
//    private static let
//    private static let kPrime = 997
//    
//    private var _count: Int
//    private let prime: Int
//    private let rootPage: Page
//    
//    init(fileOffset: Int)
//        {
//        self.rootPage = PageServer.shared.loadPage(fileOffset: fileOffset)
//        self.prime = self.rootPage.intValue(atOffset: Self.kPrimeOffset)
//        self.count = self.rootPage.intValue(atOffset: Self.kCountOffset)
//
//        }
//    }
