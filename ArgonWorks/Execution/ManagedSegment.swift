//
//  ManagedSegment.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation
import MachMemory

public class ManagedSegment: Segment
    {
    public class Space: Equatable
        {
        public static func ==(lhs: Space,rhs: Space) -> Bool
            {
            lhs.baseAddress == rhs.baseAddress
            }
            
        internal let baseAddress: Address
        internal var nextAddress: Address
        internal let lastAddress: Address
        internal let sizeInBytes: Word
        
        init(baseAddress: Address,sizeInBytes: Word)
            {
            self.baseAddress = baseAddress
            self.nextAddress = baseAddress
            self.lastAddress = baseAddress + sizeInBytes
            self.sizeInBytes = sizeInBytes
            }
            
        public func reset()
            {
            ResetMemory(self.baseAddress,self.sizeInBytes)
            self.nextAddress = self.baseAddress
            }
            
        internal func write(toStream stream: UnsafeMutablePointer<FILE>) throws
            {
            var address = self.baseAddress
            fwrite(&address,MemoryLayout<Address>.size,1,stream)
            address = self.nextAddress
            fwrite(&address,MemoryLayout<Address>.size,1,stream)
            address = self.lastAddress
            fwrite(&address,MemoryLayout<Address>.size,1,stream)
            address = self.sizeInBytes
            fwrite(&address,MemoryLayout<Address>.size,1,stream)
            address = self.nextAddress - self.baseAddress
            fwrite(&address,MemoryLayout<Address>.size,1,stream)
            fwrite(UnsafeMutableRawPointer(bitPattern: self.baseAddress),Int(address),1,stream)
            }
            
        internal func allocateSizeInBytes(_ size: Word) throws -> Address
            {
            if self.nextAddress + size >= self.lastAddress
                {
                throw(RuntimeIssue.outOfFlipSpace)
                }
            let address = self.nextAddress
            self.nextAddress += size
            return(address)
            }
            
        deinit
            {
            let errorCode = DeallocateSegment(self.baseAddress,vm_size_t(self.sizeInBytes))
            if errorCode != 0
                {
                print("ERROR: \(errorCode) deallocating segment at address \(String(format: "%X",self.baseAddress)) of size \(self.sizeInBytes).")
                }
            }
        }
        
    public override class var segmentType: SegmentType
        {
        .managed
        }
        
    private var fromSpace: Space!
    private var toSpace: Space!
    private var currentSpace: Space!
    
    public override init(memorySize: MemorySize,argonModule: ArgonModule) throws
        {
        try super.init(memorySize: memorySize,argonModule: argonModule)
        let errorCode = DeallocateSegment(self.baseAddress,vm_size_t(self.segmentSizeInBytes))
        if errorCode != 0
            {
            print("ERROR: \(errorCode) deallocating segment at address \(String(format: "%X",self.baseAddress)) of size \(self.segmentSizeInBytes).")
            }
        let spacesBaseAddress = Self.segmentType.rawValue
        let aSize = memorySize.inBytes
        let fromSpaceBaseAddress = spacesBaseAddress
        let toSpaceBaseAddress = fromSpaceBaseAddress + Word(aSize)
        let fromSpaceAddress = AllocateSegment(fromSpaceBaseAddress,UInt(aSize))
        if fromSpaceAddress != fromSpaceBaseAddress
            {
            throw(RuntimeIssue.requestedAddressDiffersFromActualAddress)
            }
        self.fromSpace = Space(baseAddress: fromSpaceAddress,sizeInBytes: Word(aSize))
        let toSpaceAddress = AllocateSegment(toSpaceBaseAddress,UInt(aSize))
        if toSpaceAddress != toSpaceBaseAddress
            {
            throw(RuntimeIssue.requestedAddressDiffersFromActualAddress)
            }
        self.toSpace = Space(baseAddress: toSpaceAddress,sizeInBytes: Word(aSize))
        self.currentSpace = fromSpace
        }
        
    internal override func reset()
        {
        self.fromSpace.reset()
        self.toSpace.reset()
        }
        
    public override func write(toStream: UnsafeMutablePointer<FILE>) throws
        {
        try self.fromSpace.write(toStream: toStream)
        try self.toSpace.write(toStream: toStream)
        if self.currentSpace == self.fromSpace
            {
            var value:Word = 0
            fwrite(&value,MemoryLayout<Word>.size,1,toStream)
            }
        else
            {
            var value:Word = 1
            fwrite(&value,MemoryLayout<Word>.size,1,toStream)
            }
        }
        
    public func allocateObject(ofClass someClass: TypeClass) throws -> Address
        {
        let sizeInBytes = self.align(someClass.instanceSizeInBytes + someClass.extraSizeInBytes)
        let address = try self.currentSpace.allocateSizeInBytes(sizeInBytes)
        let pointer = ClassBasedPointer(address: address,type: someClass,argonModule: self.argonModule)
        pointer.setClass(someClass)
        pointer.sizeInBytes = Word(sizeInBytes)
        return(Word(pointer: address))
        }
        
    public override func allocateMemoryAddress(for symbol: Symbol)
        {
        fatalError()
        }
        
    public override func allocateWords(count:Int) -> Address
        {
        fatalError()
        }
        
    public override func allocateMemoryAddress(for aStatic: StaticObject)
        {
        fatalError()
        }
        
    public override func allocateMemoryAddress(for methodInstance: MethodInstance)
        {
        fatalError()
        }
        
    public override func allocateInstructionBlock(for methodInstance: MethodInstance) -> Address
        {
        fatalError()
        }
        
    public override func allocateObject(ofType type: Type,extraSizeInBytes: Int) -> Address
        {
        try! self.allocateObject(ofClass: type as! TypeClass)
        }
        
    public override func allocateSymbol(_ string: String) -> Address
        {
        fatalError()
        }
        
    public override func allocateBucket(nextBucketAddress: Address?,bucketValue: Address?,bucketKey: Word) -> Address
        {
        fatalError()
        }
        
    public override func allocateString(_ string: String) -> Address
        {
        fatalError()
        }
        
    public override func allocateArray(size: Int) -> Address
        {
        return(self.allocateArray(size: size,elements: [] as Array<Address>))
        }
        
    public override func allocateArray(size: Int,elements: Addresses) -> Address
        {
        fatalError()
        }
        
    public override func allocateArray(size: Int,elements: Addressables) -> Address
        {
        fatalError()
        }
    }
