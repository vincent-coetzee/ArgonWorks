//
//  Type.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 15/11/21.
//

import Foundation

public class Type: Symbol,Displayable,UserDisplayable
    {
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

    public static func ==(lhs: Type,rhs: Type) -> Bool
        {
        lhs === rhs
        }
        
    public var userString: String
        {
        "Type"
        }
        
    public override var description: String
        {
        self.displayString
        }
        
    public var typeVariables: TypeVariables
        {
        []
        }
        
    public var hasVariableTypes: Bool
        {
        false
        }
        
    public var rawClass: Class
        {
        fatalError()
        }

    public var literal: Literal
        {
        fatalError()
        }
        
    public var arrayElementType: Type
        {
        fatalError()
        }
        
    public var isArray: Bool
        {
        false
        }
        
    public var isTypeVariable: Bool
        {
        false
        }
        
    public var isFunction: Bool
        {
        false
        }
        
    public var isTypeConstructor: Bool
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
        
    public var enumerationValue: Enumeration
        {
        fatalError()
        }
        
    public override var type: Type?
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
        print("START DECODE TYPE")
        super.init(coder: coder)
        print("END DECODE TYPE")
        }
        
    public func of(_ type: Type) -> Type
        {
        fatalError("of should not have been sent to a non generic class")
        }
        
    public override func encode(with coder: NSCoder)
        {
        print("START ENCODE TYPE \(self.label)")
        super.encode(with: coder)
        print("END ENCODE TYPE")
        }
        
    internal func freshType(inContext: TypeContext) -> Type
        {
        return(self)
        }
        
    public func initializer(_ primitiveIndex: Int,_ args:Type...)
        {
        fatalError()
        }
        
    public func isSubtype(of: Type) -> Bool
        {
        false
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        substitution.substitute(self) as! Self
        }
        
    public override func typeCheck() throws
        {
        }
        
    public override func freshTypeVariable(inContext: TypeContext) -> Self
        {
        self
        }
        
    public func contains(_ type:Type) -> Bool
        {
        false
        }
    }

public typealias Types = Array<Type>
