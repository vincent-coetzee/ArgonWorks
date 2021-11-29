//
//  Type.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 15/11/21.
//

import Foundation

public class Type: Symbol
    {
    public static let unknown = TypeUnknown()
    
    private static var typeMappings = Dictionary<Name,Type>()
    
    internal static func of(_ aClass: Class) -> Type
        {
        if let type = self.typeMappings[aClass.fullName]
            {
            return(type)
            }
        let type = TypeClass(class: aClass)
        self.typeMappings[aClass.fullName] = type
        return(type)
        }
        
    internal static func of(_ aClass: GenericClass) -> Type
        {
        if let type = self.typeMappings[aClass.fullName] as? TypeClass
            {
            if type.isGenericClass && type.rawGenericClass.types == aClass.types
                {
                return(type)
                }
            }
        let type = TypeClass(class: aClass,generics: aClass.types)
        self.typeMappings[aClass.fullName] = type
        return(type)
        }
        
    internal static func of(_ enumeration: Enumeration) -> Type
        {
        if let type = self.typeMappings[enumeration.fullName]
            {
            return(type)
            }
        let type = TypeEnumeration(label: enumeration.label,enumeration: enumeration)
        self.typeMappings[enumeration.fullName] = type
        return(type)
        }
        
    public static func tvar(_ name: String) -> Type
        {
        TypeContext.freshTypeVariable(named: name)
        }
        
    public static func ==(lhs: Type,rhs: Type) -> Bool
        {
        lhs === rhs
        }
        
    public override var description: String
        {
        self.displayString
        }
        
    public var typeVariables: TypeVariables
        {
        []
        }
        
    public var isUnknown: Bool
        {
        false
        }
        
    public var inferredType: Type
        {
        self
        }
        
    public var rawClass: Class
        {
        fatalError()
        }

    public var literal: Literal
        {
        fatalError()
        }
        
    public var isTypeVariable: Bool
        {
        false
        }
        
    public var isTypeConstructor: Bool
        {
        false
        }
        
    public var isLambda: Bool
        {
        false
        }
        
    public var isGenericClass: Bool
        {
        false
        }
        
    public var rawGenericClass: GenericClass
        {
        fatalError()
        }
        
    public var mangledName: String
        {
        fatalError()
        }
        
    public override var displayString: String
        {
        "Type()"
        }

    public var localAndInheritedSlots: Slots
        {
        Slots()
        }
        
    public var depth: Int
        {
        return(0)
        }
        
    public var allSubclasses: Types
        {
        Types()
        }
        
    public override var type: Type
        {
        get
            {
            self
            }
        set
            {
            }
        }
        
    required init(label: Label)
        {
        super.init(label: label)
        }
        
    init()
        {
        super.init(label: "")
        }
        
    required init?(coder: NSCoder)
        {
        fatalError()
        }
        
    public func of(_ type: Type) -> Type
        {
        fatalError("of should not have been sent to a non generic class")
        }
        
    public override func encode(with coder: NSCoder)
        {
        fatalError()
        }
        
    internal func freshType(inContext: TypeContext) -> Type
        {
        return(self)
        }
        
    public override func deepCopy() -> Self
        {
        Type(label: self.label) as! Self
        }
        
    public func isSubtype(of: Type) -> Bool
        {
        false
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(nil)
        }
        
    public func contains(_ typeVariable: TypeVariable) -> Bool
        {
        false
        }
        
    public func instanciate(withType: Type) -> Type
        {
        fatalError()
        }
        
    public func instanciate(withTypes: Types) -> Type
        {
        fatalError()
        }
        
    public func substitute(from context: TypeContext) -> Type
        {
        self
        }
        
    public func freshTypeVariable(inContext context:TypeContext) -> Type
        {
        self
        }
        
    public func replace(_ id:Int,with: Type)
        {
        }
    }

public typealias Types = Array<Type>
