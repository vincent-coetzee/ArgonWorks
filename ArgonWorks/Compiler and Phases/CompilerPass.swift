//
//  CompilerPass.swift
//  CompilerPass
//
//  Created by Vincent Coetzee on 15/8/21.
//

import Foundation

public protocol CompilerPass
    {
    var argonModule: ArgonModule { get }
    var compiler: Compiler { get }
    func dispatchError(at: Location,message: String)
    func cancelCompletion()
    }
    
extension CompilerPass
    {
    public func cancelCompletion()
        {
        self.compiler.cancelCompletion()
        }
        
    public var argonModule: ArgonModule
        {
        self.compiler.argonModule
        }
        
    public func dispatchError(at: Location,message: String)
        {
        self.compiler.reportingContext.dispatchError(at: at,message: message)
        }
    }
