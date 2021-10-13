//
//  ImportedClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportedClass: Class
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Import?
    }
    
extension Class
    {
    public override class func classForKeyedUnarchiver() -> AnyClass
        {
        return(ImportedClass.self)
        }
    }

public class ImportedGenericClass: GenericClass
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Import?
    }
    
extension GenericClass
    {
    public override class func classForKeyedUnarchiver() -> AnyClass
        {
        return(ImportedGenericClass.self)
        }
    }
    
public class ImportedGenericClassInstance: GenericClassInstance
    {
    public override var isImported: Bool
        {
        return(true)
        }
        
    public var importSymbol: Import?
    }
    
extension GenericClassInstance
    {
    public override class func classForKeyedUnarchiver() -> AnyClass
        {
        return(ImportedGenericClassInstance.self)
        }
    }
