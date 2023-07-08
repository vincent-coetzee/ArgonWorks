//
//  UnsafeMutableRawPointer+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/12/21.
//

import Foundation

extension UnsafeMutableRawPointer
    {
    public init?(bitPattern: Word)
        {
        self.init(bitPattern: UInt(bitPattern))
        }
    }
