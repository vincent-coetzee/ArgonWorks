//
//  InnerStringKeyDictionaryPointer.swift
//  InnerStringKeyDictionaryPointer
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

extension Int
    {
    var isPrime: Bool
        {
        for loop in 2..<self
            {
            if self % loop == 0
                {
                print("\(self) is not prime")
                return(false)
                }
            }
        return(true)
        }
    }
    
public class InnerStringKeyDictionaryPointer: InnerDictionaryPointer
    {
    public class func allocate(size:Int,in vm: VirtualMachine) -> InnerStringKeyDictionaryPointer
        {
        var prime = size * 5 / 2
        while !prime.isPrime
            {
            prime += 13
            }
        let extraSize = prime * 8
        let totalSize = Self.kDictionarySizeInBytes + extraSize
        print("ALLOCATING \(totalSize) BYES FOR DICTIONARY OF EXTRA BYTES \(extraSize)")
        let address = vm.managedSegment.allocateObject(sizeInBytes: totalSize)
        let pointer = InnerStringKeyDictionaryPointer(address: address)
        pointer.prime = prime
//        pointer.assignSystemSlots(from: vm.topModule.argonModule.dictionary)
        pointer.virtualMachine = vm
        assert(pointer.prime == prime,"Pointer.prime != prime")
        return(pointer)
        }

    public var keys:Array<String>
        {
        var theKeys = Array<String>()
        for index in 0..<self.prime
            {
            var bucketAddress = self.bucketPointer[index]
            while bucketAddress != 0
                {
                let bucket = InnerDictionaryBucketPointer(address: bucketAddress)
                theKeys.append(InnerStringPointer(address: bucket.key).string)
                bucketAddress = bucket.next
                }
            }
        return(theKeys)
        }
        
    private var bucketPointer: WordPointer
    private var virtualMachine: VirtualMachine?
    
    required init(address: Word)
        {
        self.bucketPointer = WordPointer(address: address + UInt64(Self.kDictionarySizeInBytes))!
        super.init(address: address)
        }
        
    public subscript(_ key:String) -> Word?
        {
        fatalError()
//        get
//            {
//            let hash = key.djb2Hash
//            let index = hash % self.prime
//            var bucketAddress = self.bucketPointer[index]
//            if bucketAddress == 0
//                {
//                return(nil)
//                }
//            while bucketAddress != 0
//                {
//                let bucket = InnerDictionaryBucketPointer(address: bucketAddress)
//                if InnerStringPointer(address: bucket.key).string == key
//                    {
//                    return(bucket.value)
//                    }
//                bucketAddress = bucket.next
//                }
//            return(nil)
//            }
//        set
//            {
//            let hash = key.djb2Hash
//            let index = hash % self.prime
//            print("KEY \(key) GIVES INDEX \(index)")
//            var bucketAddress = self.bucketPointer[index]
//            print("BUCKET ADDRESS \(bucketAddress.addressString)")
//            if bucketAddress == 0
//                {
//                let keyAddress = InnerStringPointer.allocateString(key, in: VirtualMachine.shared.managedSegment)
//                let bucket = InnerDictionaryBucketPointer.allocate(key: keyAddress.address, value: (newValue ?? 0), next: 0, in: self.virtualMachine!)
//                self.bucketPointer[index] = bucket.address
//                self.count += 1
//                return
//                }
//            var lastBucket:InnerDictionaryBucketPointer!
//            while bucketAddress != 0
//                {
//                let bucket = InnerDictionaryBucketPointer(address: bucketAddress)
//                if InnerStringPointer(address: bucket.key).string == key
//                    {
//                    bucket.value = newValue ?? 0
//                    return
//                    }
//                lastBucket = bucket
//                bucketAddress = bucket.next
//                }
//            let keyAddress = InnerStringPointer.allocateString(key, in: VirtualMachine.shared.managedSegment)
//            let bucket = InnerDictionaryBucketPointer.allocate(key: keyAddress.address, value: newValue ?? 0, next: 0, in: self.virtualMachine!)
//            lastBucket.next = bucket.address
//            self.count += 1
//            }
        }
    }
