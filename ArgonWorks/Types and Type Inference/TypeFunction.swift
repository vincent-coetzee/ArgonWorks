//
//  TypeFunction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/11/21.
//

import Foundation

public class TypeFunction: TypeConstructor
    {
    internal let types: Types
    internal var returnType: Type
    
    init(label: Label,types: Types,returnType: Type)
        {
        self.types = types
        self.returnType = returnType
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        self.types = coder.decodeObject(forKey: "types") as! Types
        self.returnType = coder.decodeObject(forKey: "returnType") as! Type
        super.init(coder: coder)
        }
        
    required init(label: Label)
        {
        self.types = Types()
        self.returnType = Type()
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.types,forKey: "types")
        coder.encode(self.returnType,forKey: "returnType")
        super.encode(with: coder)
        }
    }
