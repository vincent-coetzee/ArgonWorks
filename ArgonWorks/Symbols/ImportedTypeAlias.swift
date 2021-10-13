//
//  ImportedTypeAlias.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportedTypeAlias: TypeAlias
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Import?
    }
    
extension TypeAlias
    {
    public override class func classForKeyedUnarchiver() -> AnyClass
        {
        return(ImportedTypeAlias.self)
        }
    }
