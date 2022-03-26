//
//  AspecdtModel.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Foundation

public protocol AspectModel: Model
    {
    func value(forAspect: String) -> Any?
    }
