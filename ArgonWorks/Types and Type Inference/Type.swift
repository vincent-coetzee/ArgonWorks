//
//  Type.swift
//  Type
//
//  Created by Vincent Coetzee on 16/8/21.
//

import Foundation
import FFI

public enum TypeError: Error,Equatable
    {
    case mismatch
    case undefined
    }
    
public indirect enum Type: Equatable
    {
    public static func ==(lhs:Type,rhs:Type) -> Bool
        {
        switch(lhs,rhs)
            {
            case (.error(let error1),.error(let error2)):
                return(error1 == error2)
            case (.class(let error1),.class(let error2)):
                return(error1 == error2)
            case (.enumeration(let error1),.enumeration(let error2)):
                return(error1 == error2)
            case (.method(let label1,let types1,let type1),.method(let label2,let types2,let type2)):
                return(label1 == label2 && types1 == types2 && type1 == type2)
            case (.methodApplication(let error1),.methodApplication(let error2)):
                return(error1 == error2)
            default:
                return(false)
            }
        }
        
    public static func +(lhs:Type,rhs:Type) -> Type
        {
        switch(lhs,rhs)
            {
            case (.class(let class1),.class(let class2)):
                if class1 == class2
                    {
                    return(.class(class1))
                    }
                return(.error(.mismatch))
            default:
                return(.error(.mismatch))
            }
        }
        
    case error(TypeError)
    case `class`(Class)
    case enumeration(Enumeration)
    case method(Label,Types,Type)
    case methodApplication(MethodInstance)
    case forwardReference(Name,Context)
    
    public var displayString: String
        {
        switch(self)
            {
            case .error:
                return("error")
            case .class(let aClass):
                return(aClass.displayString)
            case .enumeration(let enumeration):
                return(enumeration.displayString)
            case .method(let label,_,_):
                return(label)
            default:
                return("somthings wrong")
            }
        }
        
    public var nativeCType: NativeCType
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.nativeCType)
            case .enumeration(let enumeration):
                return(enumeration.nativeCType)
            default:
                fatalError("somthings wrong")
            }
        }
        
    public var mangledName: String
        {
        switch(self)
            {
            case .error:
                return("error")
            case .class(let aClass):
                return(aClass.mangledName)
            case .enumeration(let enumeration):
                return(enumeration.label)
            case .method:
                fatalError()
            case .methodApplication:
                fatalError()
            case .forwardReference:
                fatalError()
            }
        }
        
    public var isGenericClassParameter: Bool
        {
        return(false)
        }
        
    public var isError: Bool
        {
        switch(self)
            {
            case .error:
                return(true)
            default:
                return(false)
            }
        }
        
    public var label: Label
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.label)
            case .enumeration(let aClass):
                return(aClass.label)
            case .method(let label,_,_):
                return(label)
            case .methodApplication(let aClass):
                return(aClass.label)
            default:
                return("")
            }
        }
        
    public var `class`: Class
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass)
            default:
                fatalError()
            }
        }
        
    public var memoryAddress: Word
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.memoryAddress)
            case .enumeration(let aClass):
                return(aClass.memoryAddress)
            case .method:
                fatalError()
            case .methodApplication(let aClass):
                return(aClass.memoryAddress)
            default:
                return(0)
            }
        }
        
    public var typeCode: TypeCode
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.typeCode)
            case .enumeration(let aClass):
                return(aClass.typeCode)
            case .method:
                return(.method)
            case .methodApplication(let aClass):
                return(aClass.typeCode)
            default:
                return(.none)
            }
        }
        
    public var depth: Int
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.depth)
            default:
                return(0)
            }
        }
        
    public var isGenericClass: Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isGenericClass)
            default:
                return(false)
            }
        }
        
    public var isStringClass: Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isStringClass)
            default:
                return(false)
            }
        }
        
    public var isPrimitiveClass: Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isPrimitiveClass)
            default:
                return(false)
            }
        }
        
    public var isObjectClass: Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isObjectClass)
            default:
                return(false)
            }
        }
        
    public var isEnumeration: Bool
        {
        switch(self)
            {
            case .enumeration:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isNotClass: Bool
        {
        switch(self)
            {
            case .class:
                return(false)
            default:
                return(true)
            }
        }
        
    public func isSameClass(_ aClass:Class) -> Bool
        {
        switch(self)
            {
            case .class(let theClass):
                return(theClass == aClass)
            default:
                return(true)
            }
        }
        
    public var ffiType: ffi_type
        {
        return(ffi_type_uint64)
        }
        
    public var isVoidType: Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass == VoidClass.voidClass)
            default:
                return(false)
            }
        }
        
    public func isEquivalent(to type:Type) -> Bool
        {
        switch(self,type)
            {
            case (.class(let class1),.class(let class2)):
                return(class1.isInclusiveSubclass(of: class2))
            case (.enumeration(let enum1),.enumeration(let enum2)):
                return(enum1 == enum2)
            case (.method(let label1,let types1,let type1),.method(let label2,let types2,let type2)):
                return(label1 == label2 && types1 == types2 && type1 == type2)
            case (.methodApplication(let m1),.methodApplication(let m2)):
                return(m1 == m2)
            default:
                return(false)
            }
        }
        
    public func isSubtype(of type:Type) -> Bool
        {
        switch(self,type)
            {
            case (.class(let class1),.class(let class2)):
                return(class1.isInclusiveSubclass(of: class2))
            case (.enumeration(let enum1),.enumeration(let enum2)):
                return(enum1 == enum2)
            default:
                return(false)
            }
        }
        
    public func realize(using realizer: Realizer)
        {
        switch(self)
            {
            case .class(let aClass):
                aClass.realize(using: realizer)
            case .enumeration(let aClass):
                aClass.realize(using: realizer)
            case .method:
                break
            case .methodApplication(let aClass):
                aClass.realize(using: realizer)
            default:
                break
            }
        }
        
    public func instanciate(withTypes: Types,reportingContext: ReportingContext) -> Type
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.instanciate(withTypes: withTypes,reportingContext: reportingContext))
            case .enumeration:
                fatalError("Need to define a subclass of Enumeration for Generic Enumerations")
            case .method:
                break
            case .methodApplication:
                break
            default:
                break
            }
        return(.error(.undefined))
        }
    
    }

public typealias Types = Array<Type>
