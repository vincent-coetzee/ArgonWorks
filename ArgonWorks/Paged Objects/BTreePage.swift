//
//  BTreePage.swift
//  BTreePage
//
//  Created by Vincent Coetzee on 23/8/21.
//

import Foundation

public class BTreePage: Page
    {
    private static let kMaxKeyCount = 160
    private static let kKeySizeInBytes = 16
    private static let kFixedOffset = 96
    private static let kOffsetSizeInBytes = 8
    
    public struct KeyEntry
        {
        public let key: Word
        public let value: Word
        }
        
    public class KeyValueAssociation
        {
        public var key: String
            {
            if self.keyCache.isNotNil
                {
                return(self.keyCache!)
                }
            self.keyCache = InnerStringPointer(address: self.keyAddress).string
            return(self.keyCache!)
            }
            
        public let keyAddress: Word
        public var keyCache: String?
        public let value: Word
        
        init(keyAddress: Word,value: Word,key: String? = nil)
            {
            self.keyAddress = keyAddress
            self.value = value
            self.keyCache = key
            }
        }
    
    public struct PromotionValue
        {
        public let key: String
        public let keyAddress: Word
        public let value: Word
        public let leftChildOffset: Int
        public let rightChildOffset: Int
        }
        
    private var isLeaf: Bool
        {
        get
            {
            return(self.value(atOffset: Self.kFixedOffset - 8) == 1)
            }
        set
            {
            self.setValue(newValue ? 1 : 0,atOffset: Self.kFixedOffset - 8)
            }
        }
        
    private var degree: Int
        {
        get
            {
            return(Int(bitPattern: UInt(self.value(atOffset: Self.kFixedOffset - 16))))
            }
        set
            {
            self.setValue(Word(newValue),atOffset: Self.kFixedOffset - 16)
            }
        }
        
    private var count: Int
        {
        get
            {
            return(Int(bitPattern: UInt(self.value(atOffset: Self.kFixedOffset - 32))))
            }
        set
            {
            self.setValue(Word(newValue),atOffset: Self.kFixedOffset - 32)
            }
        }
        
    private var pageOffset: Int
        {
        get
            {
            return(Int(bitPattern: UInt(self.value(atOffset: Self.kFixedOffset - 24))))
            }
        set
            {
            self.setValue(Word(newValue),atOffset: Self.kFixedOffset - 24)
            }
        }
        
    private var cache: Array<KeyValueAssociation>
    private var children: Array<Int?>
    
    init(virtualMachine: VirtualMachine,pageOffset: Int,isLeaf: Bool,degree: Int)
        {
        self.cache = []
        self.children = []
        super.init(virtualMachine: virtualMachine)
        self.isLeaf = isLeaf
        self.degree = degree
        self.pageOffset = pageOffset
        }
        
    init(virtualMachine: VirtualMachine,pageOffset: Int)
        {
        self.cache = []
        self.children = []
        super.init(virtualMachine: virtualMachine)
        virtualMachine.pageServer.load(into: self,atOffset: pageOffset)
        }
        
    public func association(atIndex index:Int) -> KeyValueAssociation
        {
        let theOffset = Self.kFixedOffset + Self.kKeySizeInBytes * index
        let key = self.value(atOffset: theOffset)
        let value = self.value(atOffset: theOffset + 8)
        return(KeyValueAssociation(keyAddress: key,value: value))
        }
        
    public func setAssociation(_ association:KeyValueAssociation,atIndex index:Int)
        {
        let theOffset = Self.kFixedOffset + Self.kKeySizeInBytes * index
        self.setValue(association.keyAddress,atOffset: theOffset)
        self.setValue(association.value,atOffset: theOffset + 8)
        }
        
    public func childOffset(atIndex index: Int) -> Int
        {
        let offset = Self.kFixedOffset + Self.kMaxKeyCount * Self.kKeySizeInBytes + index * Self.kOffsetSizeInBytes
        let integer = Int(bitPattern: UInt(self.value(atOffset: offset)))
        return(integer)
        }
        
    public func setChildOffset(_ child:Int,atIndex index: Int)
        {
        let word = Word(bitPattern: Int64(child))
        let offset = Self.kFixedOffset + Self.kMaxKeyCount * Self.kKeySizeInBytes + index * Self.kOffsetSizeInBytes
        self.setValue(word,atOffset: offset)
        }
        
    public func search(key: String) -> Word?
        {
        var index = 0
        while index < self.count && key >= self.cache[index].key
            {
            index += 1
            }
        if index < self.count && key == self.cache[index].key
            {
            return(self.cache[index].value)
            }
        if self.isLeaf
            {
            return(nil)
            }
        return(BTreePage(virtualMachine: self.virtualMachine,pageOffset: self.children[index]!).search(key: key))
        }
    }

public class BTree
    {
    private let virtualMachine: VirtualMachine
    private var rootPage: BTreePage?
    private var rootOffset: Int?
    
    init(virtualMachine: VirtualMachine,rootOffset: Int)
        {
        self.virtualMachine = virtualMachine
        self.rootOffset = rootOffset
        self.rootPage = BTreePage(virtualMachine: virtualMachine,pageOffset: rootOffset)
        }
        
    init(virtualMachine: VirtualMachine)
        {
        self.virtualMachine = virtualMachine
        self.rootOffset = nil
        }
        
    public func initTree()
        {
        let page = BTreePage(virtualMachine: self.virtualMachine,pageOffset: 0)
        self.virtualMachine.pageServer.load(into: page, atOffset: 0)
        }
    }
