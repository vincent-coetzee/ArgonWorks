//
//  AspectAdaptor.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Foundation

public class AspectAdaptor: ValueModel,Dependent
    {
    public var value: Any?
        {
        get
            {
            self.model.value(forAspect: self.aspect)
            }
        set
            {
            }
        }
        
    public let dependents = DependentSet()
    public let dependentKey = DependentSet.nextDependentKey
    private let model: AspectModel
    private let aspect: String
    
    public init(on: AspectModel,aspect: String)
        {
        self.model = on
        self.aspect = aspect
        self.model.addDependent(self)
        }
        
    public func update(aspect: String,with argument: Any?,from aModel: Model)
        {
        if aModel.dependentKey == self.model.dependentKey && self.aspect == aspect
            {
            self.changed(aspect: "value",with: argument,from: self)
            }
        }
    }
