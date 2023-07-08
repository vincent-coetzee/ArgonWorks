//
//  BlockContext.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/10/21.
//

import Foundation

public protocol StackFrame
    {
    func addLocalSlot(_ local: LocalSlot)
    func addParameterSlot(_ paramater: Parameter)
    }
