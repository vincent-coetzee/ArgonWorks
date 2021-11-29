//
//  NullReportingContext.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct NullReporter:Reporter
    {
    public static let shared = NullReporter()

    public func resetReporting()
        {
        }
        
    public func cancelCompletion()
        {
        }
        
    public func dispatchWarning(at: Location, message: String)
        {
        print("Warning line \(at.line):\(message)")
        }
    
    public func dispatchError(at: Location, message: String)
        {
        print("Error Line \(at.line): \(message)")
        }
        
    public func status(_ string: String)
        {
        }
        
    public func pushIssues()
        {
        }
    }
