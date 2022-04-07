//
//  TypeSurrogate.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/4/22.
//

import Foundation

public class TypeSurrogate: Type
    {
    private let kind: Int
    private let name: Name
    private let number: Int
    
    init(type: Type)
        {
        if type is TypeVariable
            {
            self.kind = 0
            self.name = Name()
            self.number = (type as! TypeVariable).id
            }
        else if type is TypeClass
            {
            self.kind = 1
            self.name = (type as! TypeClass).fullName
            self.number = -1
            }
        else if type is TypeEnumeration
            {
            self.kind = 2
            self.name = (type as! TypeEnumeration).fullName
            self.number = -1
            }
        else
            {
            fatalError()
            }
        super.init(label: "")
        }
        
    required init?(coder: NSCoder)
        {
        self.kind = coder.decodeInteger(forKey: "kind")
        self.name = coder.decodeName(forKey: "name")
        self.number = coder.decodeInteger(forKey: "number")
        super.init(coder: coder)
        }
        
    required init(label: Label)
        {
        fatalError()
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.kind,forKey: "kind")
        coder.encodeName(self.name,forKey: "name")
        coder.encode(self.number,forKey: "number")
        super.encode(with: coder)
        }
        
    public override func patchType(topModule: TopModule) -> Type?
        {
        switch(self.kind)
            {
            case 1,2:
                return(topModule.lookup(name: self.name) as? Type)
            case 0:
                return(TypeContext.freshTypeVariable(withId: self.number))
            default:
                fatalError("Should not happen")
            }
        }
        
    public override func patchClass(topModule: TopModule) -> Type
        {
        if self.kind != 1
            {
            fatalError("Invalid kind detected when converting TypeSurrogate to TypeClass")
            }
        return(topModule.lookup(name: self.name) as! Type)
        }
    }
