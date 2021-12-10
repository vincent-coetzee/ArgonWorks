//
//  ImportArchiver.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/10/21.
//

import Foundation

public class ImportArchiver: NSKeyedArchiver
    {
    public static var isSwappingSystemTypes: Bool = false
    public static var isSwappingImportedSymbols: Bool = false
    
    public private(set) var swappedSystemTypeNames = Array<String>()
    public private(set) var swappedImportedSymbolNames = Array<String>()
    
    public var isSwappingSystemTypes: Bool
        {
        Self.isSwappingSystemTypes
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
        
    public func noteSwappedSystemType(_ symbol: Symbol)
        {
        self.swappedSystemTypeNames.append(symbol.fullName.displayString)
        }
        
    public func noteSwappedImportedSymbol(_ symbol: Symbol)
        {
        self.swappedImportedSymbolNames.append(symbol.fullName.displayString)
        }
    }
