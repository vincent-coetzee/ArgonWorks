//
//  TypeError.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/11/21.
//

import Foundation

public enum TypeError: Error
    {
    case unificationFailed(Type,Type)
    case typeMismatch(Type,Type)
    case notImplemented
    case invalidSlotType
    case undefinedMethod(String)
    }
