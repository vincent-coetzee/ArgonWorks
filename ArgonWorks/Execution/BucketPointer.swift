//
//  BucketPointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/1/22.
//

import Foundation

public class BucketPointer: ObjectPointer
    {
    public var nextBucketAddress: Address?
        {
        get
            {
            self.address(atIndex: 7)
            }
        set
            {
            self.setAddress(newValue,atIndex: 7)
            }
        }
        
    public var bucketValueAddress: Address?
        {
        get
            {
            self.address(atIndex: 8)
            }
        set
            {
            self.setAddress(newValue,atIndex: 8)
            }
        }
        
    public var bucketKey: Word
        {
        get
            {
            self.word(atIndex: 9)
            }
        set
            {
            self.setWord(newValue,atIndex: 9)
            }
        }
    }
