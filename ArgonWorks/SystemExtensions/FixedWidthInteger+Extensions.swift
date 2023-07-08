//
//  FixedWidthInteger+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 30/9/21.
//

import Foundation

extension FixedWidthInteger
    {
    var bytes: [UInt8]
        {
        let capacity = MemoryLayout<Self>.size
        var mutableValue = self.bigEndian
        return(withUnsafePointer(to: &mutableValue)
            {
            return($0.withMemoryRebound(to: UInt8.self,capacity: capacity)
                {
                return(Array(UnsafeBufferPointer(start: $0,count: capacity)))
                })
            })
        }
    }
