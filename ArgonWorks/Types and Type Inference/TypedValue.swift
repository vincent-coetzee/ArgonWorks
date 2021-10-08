//
//  TypedValue.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/10/21.
//

import Foundation

public protocol TypedValue
    {
    var type: Type { get }
    
    func setType(_ type: Type)
    }
