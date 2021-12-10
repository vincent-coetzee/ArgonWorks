//
//  TypeFunction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/11/21.
//

import Foundation

public class TypeFunction: TypeConstructor
    {
    public override var isFunction: Bool
        {
        true
        }
        
    public override var hasVariableTypes: Bool
        {
        for type in self.generics
            {
            if type.hasVariableTypes
                {
                return(true)
                }
            }
        if self.returnType.hasVariableTypes
            {
            return(true)
            }
        return(false)
        }
        
    internal var returnType: Type
    
    init(label: Label,types: Types,returnType: Type)
        {
        self.returnType = returnType
        super.init(label: label,generics:types)
        }
        
    required init?(coder: NSCoder)
        {
        self.returnType = coder.decodeObject(forKey: "returnType") as! Type
        super.init(coder: coder)
        }
        
    required init(label: Label)
        {
        self.returnType = Type()
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.returnType,forKey: "returnType")
        super.encode(with: coder)
        }
    }
