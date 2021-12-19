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
    func processModule(_ module: Module?) -> Module?
    }
    
extension CompilerPass
    {
    public func cancelCompletion()
        {
        self.compiler.cancelCompletion()
        }
        
    public var argonModule: ArgonModule
        {
        TopModule.shared.argonModule
        }
        
    public func dispatchError(at: Location,message: String)
        {
//        self.compiler.reportingContext.dispatchError(at: at,message: message)
        }
    }
