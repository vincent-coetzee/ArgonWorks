//
//  TypeInferencer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

public class TypeTerm
    {
    }
    
public class ApplyTypeTerm: TypeTerm
    {
    public let name: String
    public let arguments: Array<TypeTerm>
    
    init(_ name: String,_ arguments: Array<TypeTerm>)
        {
        self.name = name
        self.arguments = arguments
        }
    }
    
public class VariableTypeTerm: TypeTerm
    {
    public let name: String
    
    init(_ name: String)
        {
        self.name = name
        }
    }
    
public class ConstantTypeTerm: TypeTerm
    {
    public let value: Class
    
    init(_ value: Class)
        {
        self.value = value
        }
    }
    
public struct TypeInferencer
    {
    }
