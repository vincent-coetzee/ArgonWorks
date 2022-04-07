//
//  BucketPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/1/22.
//

import Foundation

public class BucketPointer: ClassBasedPointer
    {
    public var nextBucketAddress: Address?
        {
        get
            {
            self.address(atSlot: "nextBucket")
            }
        set
            {
            self.setAddress(newValue,atSlot: "nextBucket")
            }
        }
        
    public var bucketValueAddress: Address?
        {
        get
            {
            self.address(atSlot: "bucketValue")
            }
        set
            {
            self.setAddress(newValue,atSlot: "bucketValue")
            }
        }
        
    public var bucketKey: Word
        {
        get
            {
            self.word(atSlot: "bucketKey")
            }
        set
            {
            self.setWord(newValue,atSlot: "bucketKey")
            }
        }
        
    public init(address: Address,argonModule: ArgonModule)
        {
        super.init(address: address, class: argonModule.bucket as! TypeClass,argonModule: argonModule)
        }
    }
