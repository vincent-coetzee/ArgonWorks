//
//  Character+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/1/22.
//

import Foundation

extension Character
    {
    public init?(_  value: Unicode.Scalar?)
        {
        if value.isNil
            {
            return(nil)
            }
        self.init(value!)
        }
    }
