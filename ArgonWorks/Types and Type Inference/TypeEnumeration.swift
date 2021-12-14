//
//  TypeEnumeration.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeEnumeration: TypeConstructor
    {
    public override var displayString: String
        {
        var names = self.generics.map{$0.displayString}.joined(separator: ",")
        if !names.isEmpty
            {
            names = "<" + names + ">"
            }
        return("TypeEnumeration(\(self.enumeration.label)\(names))")
        }
    
    public override var literal: Literal
        {
        .enumeration(self.enumeration)
        }
        
    public override var userString: String
        {
        self.enumeration.fullName.displayString
        }
        
    public override var enumerationValue: Enumeration
        {
        self.enumeration
        }
        
//    public override var type: Type?
//        {
//        get
//            {
//            let anEnum = TypeEnumeration(enumeration: self.enumeration,generics: self.generics.map{$0.type!})
//            anEnum.setParent(self.parent)
//            return(anEnum)
//            }
//        set
//            {
//            }
//        }
        
    internal let enumeration: Enumeration
    
    init(label: Label,enumeration: Enumeration)
        {
        self.enumeration = enumeration
        super.init(label: label,generics: [])
        self.enumeration.setParent(self)
        }
        
    init(enumeration: Enumeration,generics: Types)
        {
        self.enumeration = enumeration
        super.init(label: enumeration.label,generics: generics)
        self.enumeration.setParent(self)
        }
        
    required init(label: Label)
        {
        self.enumeration = Enumeration(label: "")
        super.init(label: label)
        self.enumeration.setParent(self)
        }
        
    required init?(coder: NSCoder)
        {
        self.enumeration = coder.decodeObject(forKey: "enumeration") as! Enumeration
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.enumeration,forKey: "enumeration")
        super.encode(with: coder)
        }
        
    public override func typeCheck() throws
        {
        fatalError()
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        self.enumeration.lookup(label: label)
        }
        
    public override func layoutInMemory(withAddressAllocator: AddressAllocator)
        {
        self.enumeration.layoutInMemory(withAddressAllocator: withAddressAllocator)
        }
    }
