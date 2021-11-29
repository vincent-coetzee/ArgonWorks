//
//  Displayable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/11/21.
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
        return("[" + self.map{$0.displayString}.joined(separator: ", ") + "]")
        }
    }

extension Array where Element:Block
    {
    public var displayString: String
        {
        self.map{$0.displayString}.joined(separator: "; ")
        }
    }
