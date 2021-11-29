//
//  TypeClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeClass: TypeConstructor
    {
    public override var rawGenericClass: GenericClass
        {
        self.theClass as! GenericClass
        }
        
    public override var displayString: String
        {
        var names = self.generics.map{$0.displayString}.joined(separator: ",")
        if !names.isEmpty
            {
            names = "<" + names + ">"
            }
        return("TypeClass(\(self.theClass.label)\(names))")
        }
        
    public override var isGenericClass: Bool
        {
        self.theClass.isGenericClass
        }
        
    public override var localAndInheritedSlots: Slots
        {
        self.theClass.localAndInheritedSlots
        }
        
    public override var literal: Literal
        {
        .class(self.theClass)
        }
        
    public override var depth: Int
        {
        self.theClass.depth
        }
        
    public override var allSubclasses: Types
        {
        self.theClass.allSubclasses
        }
        
    public override  var isClass: Bool
        {
        true
        }
        
    public override var isSystemClass: Bool
        {
        self.theClass.isSystemClass
        }
        
    public override var rawClass: Class
        {
        self.theClass
        }
        
    public override var type: Type
        {
        get
            {
            TypeClass(class: self.theClass,generics: self.generics.map{$0.type})
            }
        set
            {
            }
        }
        
    internal let theClass: Class
    
    init(class aClass: Class)
        {
        if aClass.label == "String"
            {
            print("halt")
            }
        self.theClass = aClass
        super.init(label: aClass.label,generics: [])
        }
        
    init(class aClass: Class,generics: Types)
        {
        self.theClass = aClass
        super.init(label: aClass.label,generics: generics)
        }
        
    required init(label: Label)
        {
        if label == "String"
            {
            print("halt")
            }
        self.theClass = Class(label: "")
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        fatalError()
        }
        
    public override func of(_ type: Type) -> Type
        {
        self.rawGenericClass.of(type)
        }
        
    public override func encode(with coder: NSCoder)
        {
        fatalError()
        }
        
    public override func deepCopy() -> Self
        {
        TypeClass(class: self.theClass,generics: self.generics.map{$0.deepCopy()}) as! Self
        }
        
    public override func isSubtype(of type: Type) -> Bool
        {
        type is TypeClass && (self.theClass.isSubclass(of: (type as! TypeClass).theClass))
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        self.theClass.lookup(label: label)
        }
    }
