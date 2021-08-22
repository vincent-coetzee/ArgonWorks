//
//  RawArrayPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public struct InnerArrayPointerIterator: IteratorProtocol
    {
    private var index:Int?
    private let startIndex: Int
    private let endIndex: Int
    private let arrayPointer: InnerArrayPointer
    
    public init(array:InnerArrayPointer,start:Int,end:Int)
        {
        self.startIndex = start
        self.endIndex = end
        self.arrayPointer = array
        }
        
    private func nextIndex(for index:Int?) -> Int?
        {
        if let index = self.index, index < self.endIndex
            {
            return(index + 1)
            }
        if index.isNil, !self.arrayPointer.isEmpty
            {
            return(0)
            }
        return(nil)
        }
        
    public mutating func next() -> Word?
        {
        if let index = self.nextIndex(for: self.index)
            {
            self.index = index
            return(self.arrayPointer[index])
            }
        return(nil)
        }
    
    public typealias Element = Word
    
    }
    
public class InnerArrayPointer:InnerPointer,Collection,Sequence
    {
    public typealias Element = Word
    public typealias Index = Int
    
    public class func allocate(arraySize:Int,elementClass: Class,in vm: VirtualMachine) -> InnerArrayPointer
        {
        let extra = arraySize * MemoryLayout<Word>.size
        let totalSize = Self.kArraySizeInBytes + extra
        let address = vm.managedSegment.allocateObject(sizeInBytes: totalSize)
        let pointer = InnerArrayPointer(address: address)
        pointer.elementClassValue = elementClass.memoryAddress
        Self.allocatedArrays.insert(address)
        pointer.headerTypeCode = TypeCode.array
        pointer.setClass(vm.topModule.argonModule.array)
        pointer.count = 0
        pointer.size = arraySize
        pointer.assignSystemSlots(from: vm.topModule.argonModule.array)
        return(pointer)
        }
        
    private static var allocatedArrays = Set<Word>()
    
    public var startIndex: Int
        {
        0
        }
        
    public var endIndex: Int
        {
        self.count - 1
        }
        
    public var isEmpty: Bool
        {
        return(self.count == 0)
        }
        
    public var count:Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"count")))
            }
        set
            {
            self.setSlotValue(Word(newValue),atKey:"count")
            }
        }
        
    public var elementClass: Class?
        {
        return(Class.classesByAddress[self.elementClassValue])
        }
        
    public var elementClassValue: Word
        {
        get
            {
            self.slotValue(atKey: "elementClass")
            }
        set
            {
            self.setSlotValue(newValue,atKey:"elementClass")
            }
        }
        
    public var size:Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"size")))
            }
        set
            {
            self.setSlotValue(Word(newValue),atKey:"size")
            }
        }
    
    internal var basePointer: WordPointer
    
    required init(address:Word)
        {
        self.basePointer = WordPointer(address: address + Word(Self.kArraySizeInBytes))!
        super.init(address: address)
        self._classPointer = nil
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kArraySizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_CollectionHeader","_CollectionMagicNumber","_CollectionClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","_IterableHeader","_IterableMagicNumber","_IterableClassPointer","count","elementType","size","elementClass","elements"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
    public func makeIterator() -> InnerArrayPointerIterator
        {
        return(InnerArrayPointerIterator(array: self, start: 0, end: self.count - 1))
        }
        
    public func index(after:Int) -> Int
        {
        return(after + 1)
        }
        
    public func address(ofIndex: Int) -> Word
        {
        let baseAddress = self.basePointer.address
        return(baseAddress + Word(ofIndex * MemoryLayout<Word>.size))
        }
        
    public subscript(_ index:Int) -> Word
        {
        get
            {
            return(self.basePointer[index])
            }
        set
            {
            self.basePointer[index] = newValue
            }
        }
        
    public func append(_ word:Word)
        {
        self[self.count] = word
        self.count += 1
        }
        
    public func append(_ words:Array<Word>)
        {
        for word in words
            {
            self[self.count] = word
            self.count += 1
            }
        }
    }
