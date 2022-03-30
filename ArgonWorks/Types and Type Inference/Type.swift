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
//    public static func ==(lhs: Type,rhs: Type) -> Bool
//        {
//        lhs.index == rhs.index
//        }

    public override var argonHash: Int
        {
        self.displayString.polynomialRollingHash
        }
        
    public var slotCount: Int
        {
        0
        }
        
    public override var isType: Bool
        {
        true
        }
        
    public var isSetClass: Bool
        {
        false
        }
        
    public var isArrayClass: Bool
        {
        false
        }
        
    public var isListClass: Bool
        {
        false
        }
        
    public var isDictionaryClass: Bool
        {
        false
        }
        
    public var isBitSetClass: Bool
        {
        false
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
        
    public var layoutSlotCount: Int
        {
        0
        }
        
    public var containsTypeVariable: Bool
        {
        false
        }
        
    public override var description: String
        {
        self.displayString
        }
        
    public var typeVariables: TypeVariables
        {
        []
        }
        
    public override var segmentType: Segment.SegmentType
        {
        .static
        }
        
    public var hasVariableTypes: Bool
        {
        false
        }
        
    public var arrayElementType: Type
        {
        fatalError()
        }
        
    public var isArray: Bool
        {
        false
        }
        
    public var classValue: TypeClass
        {
        fatalError()
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
        
    public var isClassType: Bool
        {
        false
        }
        
    public var isEnumerationType: Bool
        {
        false
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
        get
            {
            self._flags.contains(.kSystemTypeFlag)
            }
        set
            {
            self._flags.insert(.kSystemTypeFlag)
            }
        }
        
    public var isValueType: Bool
        {
        self._flags.contains(.kValueTypeFlag)
        }
        
    public var isRootType: Bool
        {
        self._flags.contains(.kRootTypeFlag)
        }
        
    public var isArrayType: Bool
        {
        self._flags.contains(.kArrayTypeFlag)
        }
        
    public var isStringType: Bool
        {
        self._flags.contains(.kStringTypeFlag)
        }
        
    public var isFloatType: Bool
        {
        false
        }
        
    public var isIntegerType: Bool
        {
        false
        }
        
    public var isMetaclassType: Bool
        {
        self._flags.contains(.kMetaclassFlag)
        }
        
    public override var isPrimitiveType: Bool
        {
        self._flags.contains(.kPrimitiveTypeFlag)
        }
        
    public var magicNumber: Int
        {
        self.label.polynomialRollingHash
        }
        
    public var isArcheType: Bool
        {
        self._flags.contains(.kArcheTypeFlag)
        }
        
    public var superclassType: Type
        {
        fatalError()
        }
        
    public var typeFlags: TypeFlags
        {
        self._flags
        }
        
    private var _flags: TypeFlags = []
    
    required init(label: Label)
        {
        super.init(label: label)
        }
        
    init()
        {
        fatalError()
        super.init(label: "")
        }
        
    required init?(coder: NSCoder)
        {
        print("START DECODE TYPE")
        self._flags = TypeFlags(rawValue: UInt16(coder.decodeInteger(forKey: "flags")))
        super.init(coder: coder)
        print("END DECODE TYPE")
        }
        
    public func isSubclass(of: Type) -> Bool
        {
        return(false)
        }
        
    public func of(_ type: Type) -> Type
        {
        fatalError("of should not have been sent to a non generic class")
        }
        
    public override func encode(with coder: NSCoder)
        {
        print("START ENCODE TYPE \(self.label)")
        coder.encode(Int(self._flags.rawValue),forKey: "flags")
        super.encode(with: coder)
        print("END ENCODE TYPE")
        }
        
    @discardableResult
    public func flags(_ flag: TypeFlags) -> Self
        {
        self._flags = self._flags.union(flag)
        return(self)
        }
        
    public func
    isSubtype(of: Type) -> Bool
        {
        false
        }
        
    public func isEquivalent(_ rhs: Type) -> Bool
        {
        return(true)
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
        
    public func addInstanceSlot(_ slot: Slot)
        {
        fatalError()
        }
        
    public func addClassSlot(_ slot: Slot)
        {
        fatalError()
        }
        
    @discardableResult
    public func slot(_ label: Label,_ type: Type) -> Type
        {
        fatalError()
        }
        
    @discardableResult
    public func slot(_ label: Label,mandatory:Argon.Symbol,_ type: Type) -> Type
        {
        fatalError()
        }
        
    @discardableResult
    public func setHasBytes(_ bool:Bool) -> Type
        {
        fatalError()
        }
        
    public func printLayout()
        {
        }
        
    public func initNonHierarchyMetaclass(inModule: Module)
        {
        }
        
    public func addSubtype(_ type: Type)
        {
        fatalError()
        }
        
    @discardableResult
    public func typeVar(_ label: Label) -> TypeVariable
        {
        fatalError()
        }
        
    @discardableResult
    public func typeVar(_ typeVar: TypeVariable) -> Type
        {
        fatalError()
        }
        
    public func typeVar(atId: Int) -> TypeVariable?
        {
        nil
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
