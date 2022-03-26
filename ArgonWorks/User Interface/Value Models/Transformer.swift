//
//  Transformer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Foundation

public class Transformer: ValueModel,Dependent
    {
    public var value: Any?
        {
        get
            {
            if let aValue = self.lastValue
                {
                return(aValue)
                }
            self.lastValue = self.closure(self.model.value)
            return(self.lastValue)
            }
        set
            {
            }
        }
        
    public let dependents = DependentSet()
    public let dependentKey = DependentSet.nextDependentKey
    private var model: ValueModel
    private let closure: (Any?) -> Any?
    private var lastValue: Any?
    
    public init(model: ValueModel,closure: @escaping (Any) -> Any)
        {
        self.model = model
        self.closure = closure
        model.addDependent(self)
        }
        
    public func update(aspect: String,with argument: Any?,from aModel: Model)
        {
        if aspect == "value" && argument.isNotNil
            {
            let newValue = self.closure(argument!)
            self.lastValue = newValue
            self.changed(aspect: "value",with: newValue,from: self)
            }
        }
    }
