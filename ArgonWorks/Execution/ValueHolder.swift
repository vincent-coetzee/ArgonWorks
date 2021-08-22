//
//  ValueHolder.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

public enum ValueHolder
    {
    case none
    case integer(Int)
    case uInteger(Word)
    case string(Word,String)
    
    public var displayString: String
        {
        switch(self)
            {
            case .none:
                return("nil")
            case .integer(let value):
                return("integer(\(value))")
            case .uInteger(let value):
                return("uInteger(\(value))")
            case .string(let address,let string):
                let addressString = String(format:"%08X",address)
                return("string(\(addressString),\(string))")
            }
        }
    }
