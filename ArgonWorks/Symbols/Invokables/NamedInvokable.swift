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
    public let invokable: Invokable
    
    init(fullName: Name,invokable: Invokable)
        {
        self.fullName = fullName
        self.invokable = invokable
        }
    }
