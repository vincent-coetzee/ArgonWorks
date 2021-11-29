//
//  CompilerIssue.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 24/11/21.
//

import Foundation

public struct CompilerIssue: Error
    {
    public var isError: Bool
        {
        !self.isWarning
        }
        
    public let location: Location
    public let message: String
    public let isWarning: Bool
    
    init(location: Location,message: String,isWarning: Bool = false)
        {
        self.location = location
        self.message = message
        self.isWarning = isWarning
        }
    }

public typealias CompilerIssues = Array<CompilerIssue>

extension CompilerIssues where Element == CompilerIssue
    {
    public mutating func appendIssue(at: Location,message: String,isWarning:Bool = false)
        {
        self.append(CompilerIssue(location: at,message: message,isWarning: isWarning))
        }
    
    public mutating func appendIssue(at: Location,_ message: String,isWarning: Bool = false)
        {
        self.append(CompilerIssue(location: at,message: message,isWarning: isWarning))
        }
    }
