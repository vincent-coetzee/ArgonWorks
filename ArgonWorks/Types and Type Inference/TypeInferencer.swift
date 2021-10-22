//
//  TypeInferencer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

public class TypeConstraint
    {
    private let name: String
    private let type: Type?
    
    init(name: String,type: Type?)
        {
        self.name = name
        self.type = type
        }
    }
    
public class TypeSubstitution
    {
    private var variables = Dictionary<String,Class>()
    }
    
public class TypeInferencer
    {
    private var constraintStack:Array<TypeConstraint> = []
    private var typeSubstitution: TypeSubstitution = TypeSubstitution()
    
    public func push(constraint: TypeConstraint)
        {
        self.constraintStack.append(constraint)
        }
        
    public func unify() -> TypeSubstitution
        {
        while !self.constraintStack.isEmpty
            {
//            let constraint = self.constraintStack.popLast()
            
            }
        return(self.typeSubstitution)
        }
    }
