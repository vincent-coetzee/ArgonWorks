//
//  Double+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 30/9/21.
//

import Foundation

extension Double
    {
    var bytes: [UInt8]
        {
        return(self.bitPattern.bytes)
        }
    }
