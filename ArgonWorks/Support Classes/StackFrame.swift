//
//  StackFrame.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/10/21.
//

import Foundation

public protocol StackFrame
    {
    func addSlot(_ local: Slot)
    func addParameterSlot(_ paramater: Parameter)
    }
