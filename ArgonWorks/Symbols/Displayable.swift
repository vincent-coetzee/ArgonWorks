//
//  Displayable.swift
//  Displayable
//
//  Created by Vincent Coetzee on 18/8/21.
//

import Foundation

public protocol Displayable
    {
    var displayString: String { get }
    }

extension Array where Element:Displayable
    {
    public var displayString: String
        {
        return("[" + self.map{$0.displayString}.joined(separator: ",") + "]")
        }
    }
