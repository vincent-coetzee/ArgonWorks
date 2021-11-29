//
//  NamedInvokable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/10/21.
//

import Foundation

public struct NamedInvokable
    {
    public var instructions: Array<T3AInstruction>
        {
        return(self.invokable.instructions)
        }
        
    public let fullName: Name
    public let invokable: Invocable
    
    init(fullName: Name,invokable: Invocable)
        {
        self.fullName = fullName
        self.invokable = invokable
        }
    }
