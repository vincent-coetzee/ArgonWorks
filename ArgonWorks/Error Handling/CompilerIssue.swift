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
    
extension NSCoder
    {
    public func encodeCompilerIssue(_ compilerIssue: CompilerIssue,forKey: String)
        {
        self.encodeLocation(compilerIssue.location,forKey: forKey + "location")
        self.encode(compilerIssue.message,forKey: forKey + "message")
        self.encode(compilerIssue.isWarning,forKey: forKey + "isWarning")
        }
        
    public func decodeCompilerIssue(forKey: String) -> CompilerIssue
        {
        let location = self.decodeLocation(forKey: forKey + "location")
        let message = self.decodeObject(forKey: forKey + "message") as! String
        let isWarning = self.decodeBool(forKey: forKey + "isWarning")
        return(CompilerIssue(location: location,message: message,isWarning: isWarning))
        }
        
    public func encodeCompilerIssues(_ issues: CompilerIssues,forKey: String)
        {
        self.encode(issues.count,forKey: forKey + "count")
        var index = 0
        for issue in issues
            {
            self.encodeCompilerIssue(issue,forKey: forKey + "\(index)")
            index += 1
            }
        }
        
    public func decodeCompilerIssues(forKey: String) -> CompilerIssues
        {
        let count = self.decodeInteger(forKey: forKey + "count")
        var issues = CompilerIssues()
        for index in 0..<count
            {
            issues.append(self.decodeCompilerIssue(forKey: forKey + "\(index)"))
            }
        return(issues)
        }
    }
