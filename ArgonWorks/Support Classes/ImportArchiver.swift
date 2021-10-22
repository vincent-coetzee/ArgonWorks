//
//  ImportArchiver.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/10/21.
//

import Foundation

public class ImportArchiver: NSKeyedArchiver
    {
    public static var isSwappingSystemSymbols: Bool = false
    public static var isSwappingImportedSymbols: Bool = false
    
    public private(set) var swappedSystemSymbolNames = Array<String>()
    public private(set) var swappedImportedSymbolNames = Array<String>()
    
    public var isSwappingSystemSymbols: Bool
        {
        Self.isSwappingSystemSymbols
        }
        
    public var isSwappingImportedSymbols: Bool
        {
        Self.isSwappingImportedSymbols
        }
        
    public override init(requiringSecureCoding: Bool)
        {
        super.init(requiringSecureCoding: requiringSecureCoding)
        }
        
    public override init()
        {
        super.init()
        }
        
    public func noteSwappedSystemSymbol(_ symbol: Symbol)
        {
        self.swappedSystemSymbolNames.append(symbol.fullName.displayString)
        }
        
    public func noteSwappedImportedSymbol(_ symbol: Symbol)
        {
        self.swappedSystemSymbolNames.append(symbol.fullName.displayString)
        }
    }
