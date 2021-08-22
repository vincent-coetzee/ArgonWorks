//
//  Optional+Extensions.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 12/7/21.
//

import Foundation

extension Optional
    {
    public var isNotNil: Bool
        {
        switch(self)
            {
            case .some:
                return(true)
            case .none:
                return(false)
            }
        }
        
    public var isNil: Bool
        {
        switch(self)
            {
            case .some:
                return(false)
            case .none:
                return(true)
            }
        }
    }
