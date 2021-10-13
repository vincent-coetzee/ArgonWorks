//
//  ImportedConstant.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportedConstant: Constant
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Import?
    }
    
extension Constant
    {
    public override class func classForKeyedUnarchiver() -> AnyClass
        {
        return(ImportedConstant.self)
        }
    }
