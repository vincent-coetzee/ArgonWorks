//
//  ReportingContext.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public protocol ReportingContext
    {
    func resetReporting()
    func status(_ string:String)
    func dispatchWarning(at:Location,message:String)
    func dispatchError(at:Location,message:String)
    }
