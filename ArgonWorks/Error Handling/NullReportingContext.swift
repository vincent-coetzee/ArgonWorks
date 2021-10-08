//
//  NullReportingContext.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct NullReportingContext:ReportingContext
    {
    public static let shared = NullReportingContext()

    public func dispatchWarning(at: Location, message: String)
        {
        print("Warning line \(at.line):\(message)")
        }
    
    public func dispatchError(at: Location, message: String)
        {
        print("Error Line \(at.line): \(message)")
        }
    }
