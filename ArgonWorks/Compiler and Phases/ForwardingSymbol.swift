//
//  ForwardingSymbol.swift
//  ForwardingSymbol
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class ForwardingSymbol: Symbol
    {
    @discardableResult
    public override func addSymbol(_ symbol:Symbol) -> Self
        {
        self.parent.addSymbol(symbol)
        return(self)
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        return(self.parent.lookup(label: label))
        }
    }
