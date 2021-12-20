//
//  Int+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

extension Int
    {
    init(bitPattern: Word)
        {
        self.init(bitPattern: UInt(bitPattern))
        }
    }