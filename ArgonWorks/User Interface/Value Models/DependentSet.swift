//
//  DependentSet.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/3/22.
//

import Foundation

public struct WeakDependent
    {
    internal weak var dependent: Dependent? = nil
    
    init(dependent: Dependent)
        {
        self.dependent = dependent
        }
    }

public class DependentSet
    {
    private static var _nextDependentKey = 1
    
    public static var nextDependentKey: Int
        {
        let key = Self._nextDependentKey
        Self._nextDependentKey += 1
        return(key)
        }
    
    private var dependents: Dictionary<Int,WeakDependent> = [:]
    
    public func addDependent(_ dependent: Dependent)
        {
        self.dependents[dependent.dependentKey] = WeakDependent(dependent: dependent)
        }
        
    public func removeDependent(_ dependent: Dependent)
        {
        self.dependents[dependent.dependentKey] = nil
        }
        
    public func changed(aspect: String,with: Any?,from: Model)
        {
        for dependent in self.dependents.values
            {
            dependent.dependent?.update(aspect: aspect,with: with,from: from)
            }
        }
    }


    




