//
//  InstanceSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/12/21.
//

import Foundation

public class InstanceSlot: Slot
    {
    public override var isSystemSymbol: Bool
        {
        return(self.parentClass.isSystemSymbol)
        }
        
    public var parentClass: Class
        {
        if case let Parent.node(node) = self.parent
            {
            return(node as! Class)
            }
        fatalError("The parent of this instance slot is not a class")
        }
    }
