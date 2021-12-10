//
//  TypeMetaclass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 9/12/21.
//

import Foundation

public class TypeMetaclass: Type
    {
    internal let typeClass: TypeClass
    
    init(typeClass: TypeClass)
        {
        self.typeClass = typeClass
        super.init(label: typeClass.label)
        }
    
    required init?(coder: NSCoder)
        {
        self.typeClass = coder.decodeObject(forKey: "typeClass") as! TypeClass
        super.init(coder: coder)
        }
    
    required init(label: Label)
        {
        fatalError()
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.typeClass,forKey: "typeClass")
        super.encode(with: coder)
        }
    }
