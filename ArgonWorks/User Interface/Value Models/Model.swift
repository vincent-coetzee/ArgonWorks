//
//  Model.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Foundation

public protocol Model: AnyObject
    {
    var dependentKey: Int { get }
    var dependents: DependentSet { get }
    }

extension Model
    {
    public func addDependent(_ dependent: Dependent)
        {
        self.dependents.addDependent(dependent)
        }
        
    public func removeDependent(_ dependent: Dependent)
        {
        self.dependents.removeDependent(dependent)
        }
        
    public func changed()
        {
        self.changed(aspect: "value")
        }
        
    public func changed(aspect: String)
        {
        self.changed(aspect: aspect,with: nil)
        }
        
    public func changed(aspect: String,with: Any?)
        {
        self.changed(aspect: aspect,with: with,from: self)
        }
        
    public func changed(aspect: String,with: Any?,from: Model)
        {
        self.dependents.changed(aspect: aspect,with: with,from: from)
        }
        
    public func retractInterest(of dependent: Dependent,during closure: () -> Void)
        {
        self.dependents.removeDependent(dependent)
        closure()
        self.dependents.addDependent(dependent)
        }
    }

public typealias Models = Array<Model>
