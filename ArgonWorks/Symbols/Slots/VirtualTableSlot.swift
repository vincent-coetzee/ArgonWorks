//
//  OffsetSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/2/22.
//

import Foundation
import MachMemory

public class VirtualTable
    {
    public struct VirtualTableEntry
        {
        public let clazz: TypeClass
        public let offset: Int
        
        init(class clazz: TypeClass,offset: Int)
            {
            self.clazz = clazz
            self.offset = offset
            }
        }
        
    public let forClass: TypeClass
    public var entries = Array<VirtualTableEntry>()
    public var memoryAddress: Address = 0
    
    public init(forClass clazz: TypeClass)
        {
        self.forClass = clazz
        }
        
    public func allocateAddresses(using allocator: AddressAllocator)
        {
        self.memoryAddress = allocator.allocateVirtualTable(self)
        }
        
    public func layoutInMemory()
        {
        var address = self.memoryAddress
        for entry in self.entries
            {
            SetWordAtAddress(Word(integer: entry.offset),address)
            address += Argon.kWordSizeInBytesWord
            }
        }
    }
    
public class VirtualTableSlot: Slot
    {
    public var virtualTable: VirtualTable!
    
    public override func layoutInMemory(using allocator: AddressAllocator)
        {
        super.layoutInMemory(using: allocator)
        self.virtualTable.layoutInMemory()
        }
    }
