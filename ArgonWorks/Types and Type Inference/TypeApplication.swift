//
//  TypeApplication.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 30/11/21.
//

import Foundation

public class TypeApplication: Type
    {
    public override var hasVariableTypes: Bool
        {
        for type in self.types
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
        
    internal let function: TypeFunction
    internal let types: Types
    internal let returnType: Type
    
    init(function: TypeFunction,types: Types,returnType: Type)
        {
        self.function = function
        self.types = types
        self.returnType = returnType
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.function = coder.decodeObject(forKey: "function") as! TypeFunction
        self.types = coder.decodeObject(forKey: "types") as! Types
        self.returnType = coder.decodeObject(forKey: "returnType") as! Type
        super.init(coder: coder)
        }
        
    required init(label: Label)
        {
        self.types = []
        self.returnType = Type()
        self.function = TypeFunction(label: "", types: [], returnType: Type())
        super.init()
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.function,forKey: "function")
        coder.encode(self.types,forKey: "types")
        coder.encode(self.returnType,forKey: "returnType")
        super.encode(with: coder)
        }
    }
