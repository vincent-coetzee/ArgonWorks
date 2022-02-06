//
//  CompilerPass.swift
//  CompilerPass
//
//  Created by Vincent Coetzee on 15/8/21.
//

import Foundation

public protocol CompilerPass
    {
    func dispatchError(at: Location,message: String)
    func cancelCompletion()
    @discardableResult
    func processModule(_ module: Module?) -> Module?
    }

extension CompilerPass
    {
    public func dispatchError(at: Location,message: String)
        {
        }
    }
