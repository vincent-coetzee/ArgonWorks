//
//  Sequence+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/11/21.
//

import Foundation

extension Sequence
    {
    public func hasNils<T>() -> Bool where Element == Optional<T>
        {
        for element in self
            {
            switch(element)
                {
                case .some:
                    break
                case .none:
                    return(true)
                }
            }
        return(false)
        }
    }
