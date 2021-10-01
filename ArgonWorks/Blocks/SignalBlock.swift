//
//  SignalBlock.swift
//  SignalBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class SignalBlock: Block
    {
    private let symbol:String
    
    public init(symbol: String)
        {
        self.symbol = symbol
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        fatalError()
        }
        
 
    }

