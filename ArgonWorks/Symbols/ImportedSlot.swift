//
//  ImportedSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportedSlot: Slot
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Import?
    }

