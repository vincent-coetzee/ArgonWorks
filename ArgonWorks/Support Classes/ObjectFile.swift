//
//  ObjectFile.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

public class ObjectFile
    {
    private var symbols = Symbols()
    
    public func addSymbol(_ symbol:Symbol)
        {
        self.symbols.append(symbol)
        }
    }
