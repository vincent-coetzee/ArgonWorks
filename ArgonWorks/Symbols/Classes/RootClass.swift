//
//  RootClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 15/10/21.
//

import Foundation

public class RootClass: SystemClass
    {
    public override var depth: Int
        {
        return(1)
        }
        
    public override var isRootClass: Bool
        {
        return(true)
        }
        
//    public override class func classForKeyedUnarchiver() -> AnyClass
//        {
//        return(ImportedRootClass.self)
//        }
    }

public class ImportedRootClass: RootClass
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Importer?
    }
