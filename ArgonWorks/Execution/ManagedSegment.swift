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
    public class Space
        {
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
        
    public func allocateObject(ofClass someClass: TypeClass) throws -> Address
        {
        let sizeInBytes = self.align(someClass.instanceSizeInBytes + someClass.extraSizeInBytes)
        let address = try self.currentSpace.allocateSizeInBytes(sizeInBytes)
        let pointer = ClassBasedPointer(address: address,type: someClass)
        pointer.setClass(someClass)
        pointer.sizeInBytes = Word(sizeInBytes)
        pointer.tag = .header
        pointer.classAddress = someClass.memoryAddress
        pointer.magicNumber = someClass.magicNumber
        return(Word(object: address))
        }
    }
