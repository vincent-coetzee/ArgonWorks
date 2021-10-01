//
//  Float.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 30/9/21.
//

import Foundation

extension Float
    {
    var bytes: [UInt8]
        {
        return(self.bitPattern.bytes)
        }
    }
