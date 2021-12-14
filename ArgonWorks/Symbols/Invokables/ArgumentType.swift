//
//  Method.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import AppKit

public enum ArgumentType
    {
    case type(Type)
    case generic(String)
    case void
    
    public func parameter(_ random:Int) -> Parameter
        {
        switch(self)
            {
            case .type(let type):
                return(Parameter(label: "\(random)", relabel: nil, type: type, isVisible: false, isVariadic: false))
            case .generic(let label):
                return(Parameter(label: "\(random)", relabel: nil, type: TypeContext.freshTypeVariable(named: "\(random)\(label)"), isVisible: false, isVariadic: false))
            case .void:
                fatalError()
            }
        }
        
    public func value(_ random:Int,_ argonModule: ArgonModule) -> Type
        {
        switch(self)
            {
            case .type(let type):
                return(type)
            case .generic(let number):
                return(TypeContext.freshTypeVariable(named:"\(random)\(number)"))
            case .void:
                return(argonModule.void)
            }
        }
    }
