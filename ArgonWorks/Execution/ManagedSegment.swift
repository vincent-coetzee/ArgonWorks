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
        internal let nextAddress: Address
        internal let lastAddress: Address
        internal let sizeInBytes: Word
        
        init(baseAddress: Address,sizeInBytes: Word)
            {
            self.baseAddress = baseAddress
            self.nextAddress = baseAddress
            self.lastAddress = baseAddress + sizeInBytes
            self.sizeInBytes = sizeInBytes
            }
            
        internal func allocateSizeInBytes(_ size: Word) -> Address?
            {
            return(nil)
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
            throw(RuntimeIssue("Requested space address and allocated space address are different."))
            }
        self.fromSpace = Space(baseAddress: fromSpaceAddress,sizeInBytes: Word(aSize))
        let toSpaceAddress = AllocateSegment(toSpaceBaseAddress,UInt(aSize))
        if toSpaceAddress != toSpaceBaseAddress
            {
            throw(RuntimeIssue("Requested space address and allocated space address are different."))
            }
        self.toSpace = Space(baseAddress: toSpaceAddress,sizeInBytes: Word(aSize))
        self.currentSpace = fromSpace
        }
        
    public func allocateObject(ofClass someClass: Class) -> Address
        {
        let sizeInBytes = self.align(someClass.instanceSizeInBytes + someClass.extraSizeInBytes)
        if let address = self.currentSpace.allocateSizeInBytes(sizeInBytes)
            {
            let pointer = ObjectPointer(dirtyAddress: address)!
            pointer.sizeInBytes = Word(sizeInBytes)
            pointer.tag = .header
            pointer.classAddress = someClass.memoryAddress
            pointer.magicNumber = someClass.magicNumber
            return(Word(object: address))
            }
        // do swap and gc
        return(0)
        }
    }
