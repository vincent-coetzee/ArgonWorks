//
//  PrimitiveTable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 10/1/22.
//

import Foundation
import MachMemory

public class PrimitiveVectorTable
    {
    private static let kAddress: Address = 17592186044416
    private static let kEntryCount: Word = 5000
    
    private let baseAddress: Address
    private let sizeInBytes: vm_size_t
    
    init() throws
        {
        let address = Self.kAddress
        let size = vm_size_t(Self.kEntryCount * Argon.kWordSizeInBytesWord)
        self.baseAddress = AllocateSegment(address,size)
        if self.baseAddress != address
            {
            throw(RuntimeIssue.requestedAddressDiffersFromActualAddress)
            }
        self.sizeInBytes = size
        }
        
    deinit
        {
        DeallocateSegment(self.baseAddress,self.sizeInBytes)
        }
        
    public func address(forIndex: Int) -> Address
        {
        return(self.baseAddress + Word(forIndex) * Argon.kWordSizeInBytesWord)
        }
        
    public func write(toStream file: UnsafeMutablePointer<FILE>)
        {
        var address = self.baseAddress
        var size = Word(self.sizeInBytes)
        fwrite(&address,MemoryLayout<Address>.size,1,file)
        fwrite(&size,MemoryLayout<Word>.size,1,file)
        }
    }
