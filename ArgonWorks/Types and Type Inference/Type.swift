//
//  Type.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 15/11/21.
//

import Foundation
import FFI

public class Type: Symbol,Displayable,UserDisplayable
    {
    public static func ==(lhs: Type,rhs: Type) -> Bool
        {
        lhs.index == rhs.index
        }
        
    public var ffiType: ffi_type
        {
        fatalError()
        }
        
    public var isVoidType: Bool
        {
        false
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
        
    public var instanceSizeInBytes: Int
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
        
    public var mangledName: String
        {
        fatalError()
        }
        
    public override var sizeInBytes: Int
        {
        fatalError()
        }
        
    public var subtypes: Types
        {
        []
        }
        
    public override var displayString: String
        {
        "Type()"
        }
        
    public var isGeneric: Bool
        {
        false
        }
        
    public override var isSystemType: Bool
        {
        false
        }
    
    public override var fullName: Name
        {
        self.module.fullName
        }
        
    public override var isType: Bool
        {
        true
        }
        
    public var superclassType: Type
        {
        fatalError()
        }
        
    private var _isSystemType = false
    
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
        
    public func isSubtype(of: Type) -> Bool
        {
        false
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        substitution.substitute(self) as! Self
        }
        
    public override func freshTypeVariable(inContext: TypeContext) -> Self
        {
        self
        }
        
    public func superclass(_ type:Type) -> Type
        {
        fatalError()
        }
        
    public func contains(_ type:Type) -> Bool
        {
        false
        }
        
    public func withGenerics(_ types: Types) -> Type
        {
        self
        }
        
    public func mcode(_ string: String) -> Type
        {
        self
        }
        
    public func setType(_ objectType:Argon.ObjectType) -> Type
        {
        self
        }
        
    public func addLayoutSlot(_ slot: Slot)
        {
        fatalError()
        }
        
    @discardableResult
    public func slot(_ label: Label,_ type: Type) -> Type
        {
        fatalError()
        }
        
    @discardableResult
    public func hasBytes(_ bool:Bool) -> Type
        {
        fatalError()
        }
        
    public func printLayout()
        {
        }
        
    public func addSubtype(_ type: Type)
        {
        fatalError()
        }
        
    @discardableResult
    public func typeVar(_ label: Label) -> Type
        {
        fatalError()
        }
        
//    public override func setParent(_ parent: Parent)
//        {
//        fatalError()
//        }
//        
//    public override func setParent(_ symbol: Symbol)
//        {
//        fatalError()
//        }
//        
//    public override func setParent(_ expression: Expression)
//        {
//        fatalError()
//        }
//        
//    public override func setParent(_ block: Block)
//        {
//        fatalError()
//        }
    }

public typealias Types = Array<Type>
