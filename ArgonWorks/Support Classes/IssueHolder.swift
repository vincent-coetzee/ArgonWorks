//
//  IssueHolder.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/12/21.
//

import Foundation

public protocol IssueHolder
    {
    func appendIssue(at: Location,message: String)
    func appendWarningIssue(at: Location,message: String)
    }
