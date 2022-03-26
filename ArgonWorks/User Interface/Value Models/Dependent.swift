//
//  Dependent.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Foundation

public protocol Dependent: AnyObject
    {
    var dependentKey: Int { get }
    func update(aspect: String,with: Any?,from: Model)
    }
