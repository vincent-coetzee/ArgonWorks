//
//  CompilerPass.swift
//  CompilerPass
//
//  Created by Vincent Coetzee on 15/8/21.
//

import Foundation

public protocol CompilerPass
    {
    var virtualMachine: VirtualMachine { get }
    var compiler: Compiler { get }
    func dispatchError(at: Location,message: String)
    func cancelCompletion()
    }
    
extension CompilerPass
    {
    public func dispatchError(at: Location,message: String)
        {
        self.compiler.reportingContext.dispatchError(at: at,message: message)
        }
    }
