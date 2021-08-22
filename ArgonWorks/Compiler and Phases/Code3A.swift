//
//  Instruction3A.swift
//  Instruction3A
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class Code3A
    {
    public enum Operation
        {
        case none
        case add,sub,mul,div,mod
        
        }
        
    public enum Address
        {
        public static var newTemporary: Address
            {
            return(.temporary(Argon.nextSymbolIndex()))
            }
            
        case none
        case temporary(Int)
        case float(Argon.Float)
        case integer(Argon.Float)
        case string(String)
        case label(Int)
        }
        
    private let label: Int?
    private let index: Int = Argon.nextSymbolIndex()
    private let operation: Operation
    private let address1: Address
    private let address2: Address
    private let result: Address
    
    init(_ label:Int? = nil,_ operation:Operation,address1:Address = .none,address2:Address = .none,result:Address = .none)
        {
        self.label = label
        self.operation = operation
        self.address1 = address1
        self.address2 = address2
        self.result = result
        }
    }
