//
//  SymbolWrapper.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 23/10/21.
//

import Foundation

public class SymbolWrapper
    {
    private var children: SymbolWrappers
        {
        let kids = self.symbol.children.filter{self.constraints.contains($0.typeCode)}
        return(kids.map{SymbolWrapper(symbol: $0,constraints: self.constraints)})
        }
        
    private let symbol: Symbol
    private let constraints: Set<TypeCode>
    
    init(symbol: Symbol,constraints: Set<TypeCode>)
        {
        self.symbol = symbol
        self.constraints = constraints
        }
    }
    
public typealias SymbolWrappers = Array<SymbolWrapper>
