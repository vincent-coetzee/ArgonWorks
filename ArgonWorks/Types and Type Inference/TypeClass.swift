//
//  TypeClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeClass: TypeConstructor
    {
    public static func ==(lhs: TypeClass,rhs:TypeClass) -> Bool
        {
        return(lhs.theClass == rhs.theClass && lhs.generics == rhs.generics)
        }
        
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
        if self.theClass.isSystemClass
            {
            return("TypeClass(SystemClass(\(self.theClass.label))\(names))")
            }
        return("TypeClass(\(self.theClass.label)\(names))")
        }
        
    public override var arrayElementType: Type
        {
        self.generics[0]
        }
        
    public override var isArray: Bool
        {
        self.theClass.fullName == Name("\\\\Argon\\Array")
        }
        
    public override var isSystemType: Bool
        {
        self.theClass.isSystemClass
        }
        
    public override var isSystemClass: Bool
        {
        self.theClass.isSystemClass
        }
        
    public override var isGenericClass: Bool
        {
        self.theClass.isGenericClass
        }
        
    public override var classValue: Class
        {
        self.theClass
        }
        
    public override var localAndInheritedSlots: Slots
        {
        self.theClass.localAndInheritedSlots
        }
        
    public override var literal: Literal
        {
        .class(self.theClass)
        }
        
    public override var userString: String
        {
        self.theClass.fullName.displayString
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
                
    public override var rawClass: Class
        {
        self.theClass
        }
        
//    public override var type: Type?
//        {
//        get
//            {
//            return(self)
//            }
//        set
//            {
//            }
//        }
        
    internal let theClass: Class
    
    init(class aClass: Class)
        {
        if aClass is SystemClass
            {
            fatalError("This is not allowed")
            }
        self.theClass = aClass
        super.init(label: aClass.label,generics: [])
        self.theClass.setParent(self)
        }
        
    init(systemClass aClass: Class)
        {
        self.theClass = aClass
        super.init(label: aClass.label,generics: [])
        self.theClass.setParent(self)
        }
        
    init(class aClass: Class,generics: Types)
        {
        if aClass is SystemClass
            {
            fatalError("This is not allowed")
            }
        self.theClass = aClass
        super.init(label: aClass.label,generics: generics)
        self.theClass.setParent(self)
        }
        
    init(systemClass aClass: Class,generics: Types)
        {
        self.theClass = aClass
        super.init(label: aClass.label,generics: generics)
        self.theClass.setParent(self)
        }
        
    public override func setParent(_ parent:Parent)
        {
        if case let Parent.node(node) = parent,node is Type
            {
            fatalError()
            }
        super.setParent(parent)
        }
        
    public override func setParent(_ symbol:Symbol)
        {
        if symbol is TypeClass
            {
            fatalError()
            }
        super.setParent(symbol)
        }
        
    required init(label: Label)
        {
        self.theClass = Class(label: "")
        super.init(label: label)
        self.theClass.setParent(self)
        }
        
    required init?(coder: NSCoder)
        {
        print("START DECODE TYPE CLASS")
        let object = coder.decodeObject(forKey: "aClass")
        self.theClass = object as! Class
        super.init(coder: coder)
        print("END DECODE TYPE CLASS")
        }
        
    public override func of(_ type: Type) -> Type
        {
        self.rawGenericClass.of(type)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.theClass,forKey: "aClass")
        super.encode(with: coder)
        }
        
    public override func isSubtype(of type: Type) -> Bool
        {
        type is TypeClass && (self.theClass.isSubclass(of: (type as! TypeClass).theClass))
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        if let node = self.theClass.localLookup(label: label)
            {
            return(node)
            }
        return(super.lookup(label: label))
        }
        
    public override func initializer(_ primitiveIndex: Int,_ args:Type...)
        {
        self.theClass.initializer(primitiveIndex, args)
        }
        
    public override func typeCheck() throws
        {
        try self.theClass.typeCheck()
        }
    }
