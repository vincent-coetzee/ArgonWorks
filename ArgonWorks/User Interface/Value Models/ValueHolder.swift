//
//  ValueHolder.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Foundation

public class ValueHolder: ValueModel
    {
    public let dependentKey = DependentSet.nextDependentKey
    public let dependents = DependentSet()
    
    public var value: Any?
        {
        didSet
            {
            self.changed(aspect: "value",with: self.value,from: self)
            }
        }
    
    public init(value: Any?)
        {
        self.value = value
        }
    }
