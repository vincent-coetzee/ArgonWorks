//
//  MethodInstanceSet.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/1/22.
//

import Foundation

public class MethodInstanceSet
    {
    public var hasGenericInstances: Bool
        {
        for instance in self.instances
            {
            if instance.hasVariableTypes
                {
                return(true)
                }
            }
        return(false)
        }
        
    private var instances = MethodInstances()
    
    init()
        {
        }
        
    init(instances: MethodInstances?)
        {
        if instances.isNotNil
            {
            self.instances = instances!
            }
        }
        
    public func addInstance(_ instance: MethodInstance)
        {
        self.instances.append(instance)
        }
        
    public func instancesWithArity(_ arity: Int) -> MethodInstanceSet
        {
        MethodInstanceSet(instances: self.instances.filter{$0.arity == arity})
        }
        
    public func mostSpecificInstance(forTypes types: Types) -> MethodInstance?
        {
        var selectedInstances = self.instances.filter{$0.parameterTypesAreSupertypes(ofTypes: types)}
        if selectedInstances.isEmpty
            {
            return(nil)
            }
        selectedInstances = selectedInstances.sorted{$0.moreSpecific(than: $1, forTypes: types)}
//        print("SORTED INSTANCES ==============================")
        print(selectedInstances)
//        print("===============================================")
        return(selectedInstances.first)
        }
        
    public func display()
        {
        for instance in self.instances
            {
            print(instance)
            }
        }
    }
