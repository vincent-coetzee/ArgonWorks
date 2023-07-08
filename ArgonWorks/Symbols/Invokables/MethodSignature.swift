//
//  MethodSignature.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/12/21.
//

import Foundation

public class MethodSignature
    {
    public let label: Label
    public var parameters: Parameters = Parameters()
    public var returnType: Type = Type()
    public let methodInstance: MethodInstance
    
    init(label:Label,methodInstance:MethodInstance)
        {
        self.label = label
        self.methodInstance = methodInstance
        }
        
    public func moreSpecific(than instance:MethodInstance,forTypes types: Types) -> Bool
        {
        var orderings = Array<SpecificOrdering>()
        for index in 0..<types.count
            {
            let argumentType = types[index]
            let typeA = self.parameters[index].type!
            let typeB = instance.parameters[index].type!
            if typeA.isSubtype(of: typeB)
                {
                orderings.append(.more)
                }
            else if typeA.isClass && typeB.isClass && argumentType.isClass
                {
                let argumentClassList = (argumentType as! TypeClass).precedenceList
                if let typeAIndex = argumentClassList.firstIndex(of: (typeA as! TypeClass)),let typeBIndex = argumentClassList.firstIndex(of: (typeB as! TypeClass))
                    {
                    orderings.append(typeAIndex > typeBIndex ? .more : .less)
                    }
                else
                    {
                    orderings.append(.unordered)
                    }
                }
            else
                {
                orderings.append(.unordered)
                }
            }
        for ordering in orderings
            {
            if ordering == .more
                {
                return(true)
                }
            }
        return(false)
        }
        
    public func parameterTypesAreSupertypes(ofTypes types: Types) -> Bool
        {
        for (inType,myType) in zip(types,self.parameters.map{$0.type!})
            {
            if !inType.isSubtype(of: myType)
                {
                return(false)
                }
            }
        return(true)
        }
    }
