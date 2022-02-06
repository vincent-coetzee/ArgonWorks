//
//  SystemSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/2/22.
//

import Foundation

public class GlobalSlot: Slot
    {
    public var globalSymbol: String
        {
        "#" + self.label.withoutDollar().uppercased()
        }
    }
