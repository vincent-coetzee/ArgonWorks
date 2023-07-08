//
//  TemporaryLocalScope.swift
//  TemporaryLocalScope
//
//  Created by Vincent Coetzee on 27/8/21.
//

import Foundation

public class TemporaryLocalScope: ContainerSymbol
    {
    public func addTemporary(_ symbol:Symbol)
        {
        self.addSymbol(symbol)
        }
        
    public func addTemporaries(_ someSymbols:Symbols)
        {
        for symbol in someSymbols
            {
            self.addSymbol(symbol)
            }
        }
    }
