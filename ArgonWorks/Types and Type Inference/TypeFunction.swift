//
//  TypeFunction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/11/21.
//

import Foundation

public class TypeFunction: Type
    {
    internal let types: Types
    internal var returnType: Type
    
    init(types: Types,returnType: Type)
        {
        self.types = types
        self.returnType = returnType
        super.init()
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
        
    public override func replace(_ id:Int,with: Type)
        {
        self.types.forEach{$0.replace(id,with: with)}
        if self.returnType.isTypeVariable && (self.returnType as! TypeVariable).id == id
            {
            self.returnType = with
            }
        }
    }
