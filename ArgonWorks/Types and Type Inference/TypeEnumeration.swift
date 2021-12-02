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
        
    public override var type: Type
        {
        get
            {
            TypeEnumeration(enumeration: self.enumeration,generics: self.generics.map{$0.type})
            }
        set
            {
            }
        }
        
    internal let enumeration: Enumeration
    
    init(label: Label,enumeration: Enumeration)
        {
        self.enumeration = enumeration
        super.init(label: label,generics: [])
        }
        
    init(enumeration: Enumeration,generics: Types)
        {
        self.enumeration = enumeration
        super.init(label: enumeration.label,generics: generics)
        }
        
    required init(label: Label)
        {
        self.enumeration = Enumeration(label: "")
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        fatalError()
        }
        
    public override func encode(with coder: NSCoder)
        {
        fatalError()
        }
        
    public override var inferredType: Type
        {
        TypeEnumeration(enumeration: self.enumeration,generics: self.generics.map{$0.inferredType})
        }
        
    public override func deepCopy() -> Self
        {
        TypeEnumeration(label: self.label,enumeration: self.enumeration) as! Self
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        self.enumeration.lookup(label: label)
        }
    }
