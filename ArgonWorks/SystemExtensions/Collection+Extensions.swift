//
//  Collection+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/12/21.
//

import Foundation

extension Collection
    {
    public var nilIfEmpty: Self?
        {
        if self.isEmpty
            {
            return(nil)
            }
        return(self)
        }
        
    public func detect(_ closure: (Element) -> Bool) -> Bool
        {
        for element in self
            {
            if closure(element)
                {
                return(true)
                }
            }
        return(false)
        }
    }
