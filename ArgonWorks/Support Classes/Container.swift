//
//  Container.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/12/21.
//

import Foundation

public enum Container
    {
    case none
    case block(Block)
    case expression(Expression)
    case symbol(Symbol)
    
    public var argonModule: ArgonModule
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .block(let block):
                return(block.container.argonModule)
            case .expression(let expression):
                return(expression.container.argonModule)
            case .symbol(let symbol):
                return(symbol.argonModule)
            }
        }
    }
