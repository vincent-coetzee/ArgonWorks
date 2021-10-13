//
//  ImportedEnumeration.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportedEnumeration: Enumeration
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Import?
    }

extension Enumeration
    {
    public override class func classForKeyedUnarchiver() -> AnyClass
        {
        return(ImportedEnumeration.self)
        }
    }
