//
//  ImpportedMethod.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportedMethod: Method
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Import?
    }

extension Method
    {
    public override class func classForKeyedUnarchiver() -> AnyClass
        {
        return(ImportedMethod.self)
        }
    }
