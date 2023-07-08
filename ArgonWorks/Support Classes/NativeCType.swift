//
//  NativeCType.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/9/21.
//

import Foundation

public class NativeCType
    {
    public static let intType = NativeCType(type: "int")
    public static let shortType = NativeCType(type: "short")
    public static let longType = NativeCType(type: "long")
    public static let unsignedIntType = NativeCType(type: "unsigned int")
    public static let unsignedCharType = NativeCType(type: "unsigned char")
    public static let stringType = NativeCType(type: "char")
    public static let doubleType = NativeCType(type: "double")
    public static let voidType = NativeCType(type: "void")
    public static let booleanType = NativeCType(type: "_Bool")
    public static let characterType = NativeCType(type: "char")
    public static let unsignedLongLongType = NativeCType(type: "unsigned long long")
    public static let longLongType = NativeCType(type: "long long")
    public static let objectPointerType = NativeCPointer(target: NativeCType(type: "Object"))
    public static let arrayPointerType = NativeCPointer(target: NativeCType(type: "Array"))
    
    public var displayString: String
        {
        return(self.type)
        }
        
    private let type: String
    
    init(type: String)
        {
        self.type = type
        }
        
    public func asPointer() -> NativeCType
        {
        return(NativeCType(type: self.type + "*"))
        }
    }

public class NativeCPointer: NativeCType
    {
    public override var displayString: String
        {
        return("\(self.target.displayString)*")
        }
        
    private let target: NativeCType
    
    init(target: NativeCType)
        {
        self.target = target
        super.init(type:"")
        }
    }
