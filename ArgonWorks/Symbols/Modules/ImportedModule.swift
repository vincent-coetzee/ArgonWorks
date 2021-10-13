//
//  ImportedModule.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportedModule: Module
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Import?
    }

extension Module
    {
    public override class func classForKeyedUnarchiver() -> AnyClass
        {
        return(ImportedModule.self)
        }
    }
