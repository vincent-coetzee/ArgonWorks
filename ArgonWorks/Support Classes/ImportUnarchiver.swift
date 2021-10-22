//
//  ImportUnarchiver.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportUnarchiver: NSKeyedUnarchiver
    {
    public static var domain = Domain(label: "")
    public static var loader: Loader = ImportUnarchiver.domain
    public static var topModule: TopModule = ImportUnarchiver.domain.topModule
    
    public private(set) var missingSymbols = Array<(String?,Name)>()
    public var loader: Loader
        {
        Self.loader
        }
    public var topModule: TopModule
        {
        Self.topModule
        }
        
    public override init(forReadingWith data: Data)
        {
        super.init(forReadingWith: data)
        }
        
    public override init()
        {
        super.init()
        }
        
    public func noteMissingSymbol(named: Name,path: String?)
        {
        self.missingSymbols.append((path,named))
        }
    }
