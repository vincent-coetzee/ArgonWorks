//
//  InnerByteArrayPointer.swift
//  InnerByteArrayPointer
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class InnerByteArrayPointer:InnerArrayPointer
    {
    public class func with(_ bytes:Array<UInt8>) -> InnerByteArrayPointer
        {
        fatalError()
//        let neededWords = (bytes.count / 7) + 7
//        let address = super.allocate(arraySize: neededWords, in: VirtualMachine.shared.managedSegment)
//        let pointer = InnerByteArrayPointer(address: address.address)
//        pointer.headerTypeCode = .byteArray
//        pointer.copyBytes(bytes)
//        return(pointer)
        }
        
    private func copyBytes(_ bytes:Array<UInt8>)
        {
        self.count = bytes.count
        let pointerAddress = UInt(bitPattern: self.basePointer)
        let pointer = UnsafeMutablePointer<UInt8>(bitPattern: pointerAddress)!
        var offset = 0
        for byte in bytes
            {
            pointer[offset] = byte
            offset += 1
            }
        }
        
    private var bytePointer:UnsafeMutablePointer<UInt8>!
    
    required init(address:Word)
        {
        self.bytePointer = UnsafeMutablePointer<UInt8>(bitPattern: UInt(bitPattern: 0))
        super.init(address: address)
        self.bytePointer = UnsafeMutablePointer<UInt8>(bitPattern: UInt(bitPattern: super.basePointer))
        }
        
    public subscript(_ index:Int) -> UInt8
        {
        return(self.bytePointer[index])
        }
        
    public var bytes:Array<Argon.Byte>
        {
        var bytes = Array<Argon.Byte>()
        for index in 0..<self.count
            {
            bytes.append(self[index])
            }
        return(bytes)
        }
    }
