//
//  PrimitiveClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class PrimitiveClass:Class
    {
    public override var mangledName: String
        {
        switch(self.primitiveType)
            {
            case .boolean:
                return("b")
            case .character:
                return("c")
            case .integer:
                return("i")
            case .uInteger:
                return("u")
           case .float:
                return("f")
            case .date:
                return("d")
            case .time:
                return("t")
            case .dateTime:
                return("a")
            case .byte:
                return("y")
            case .string:
                return("s")
            default:
                return("error")
            }
        }
        
    public override var nativeCType: NativeCType
        {
        switch(self.primitiveType)
            {
            case .boolean:
                return(NativeCType.booleanType)
            case .character:
                return(NativeCType.characterType)
            case .integer:
                return(NativeCType.longLongType)
            case .uInteger:
                return(NativeCType.unsignedLongLongType)
           case .float:
                return(NativeCType.doubleType)
            case .date:
                return(NativeCType.unsignedLongLongType)
            case .time:
                return(NativeCType.unsignedLongLongType)
            case .dateTime:
                return(NativeCType.unsignedLongLongType)
            case .byte:
                return(NativeCType.unsignedCharType)
            case .string:
                return(NativeCType.stringType)
            default:
                fatalError()
            }
        }
        
    public override var isPrimitiveClass: Bool
        {
        return(true)
        }
        
    public static let byteClass = PrimitiveClass(label:"Byte",primitiveType:.byte)
    public static let characterClass = PrimitiveClass(label:"Character",primitiveType:.character)
    public static let dateClass = PrimitiveClass(label:"Date",primitiveType:.date)
    public static let timeClass = PrimitiveClass(label:"Time",primitiveType:.time)
    public static let dateTimeClass = PrimitiveClass(label:"DateTime",primitiveType:.dateTime)
    public static let booleanClass = PrimitiveClass(label:"Boolean",primitiveType:.boolean)
    public static let stringClass = PrimitiveClass(label:"String",primitiveType:.string)
    public static let mutableStringClass = PrimitiveClass(label:"MutableString",primitiveType:.mutableString)
    
    public enum PrimitiveType: Int32
        {
        case boolean
        case integer
        case float
        case uInteger
        case date
        case time
        case dateTime
        case byte
        case character
        case string
        case mutableString
        }
        
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    public override var isStringClass: Bool
        {
        return(self.primitiveType == .string)
        }
        
    public override var isSystemClass: Bool
        {
        return(true)
        }
        
    internal let primitiveType:PrimitiveType
    
    init(label:Label,primitiveType:PrimitiveType)
        {
        self.primitiveType = primitiveType
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        self.primitiveType = PrimitiveType(rawValue: coder.decodeInt32(forKey: "primitiveType"))!
        super.init(coder: coder)
        }
        
    public required init(label: Label)
        {
        self.primitiveType = .integer
        super.init(label: label)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(Int32(self.primitiveType.rawValue),forKey: "primitiveType")
        super.encode(with: coder)
        }
    
    public override func layoutObjectSlots()
        {
        if self.primitiveType == .string
            {
            super.layoutObjectSlots()
            }
        }
        
    public override func printContents(_ indent: String = "")
        {
        let typeName = Swift.type(of: self)
        print("\(indent)\(typeName): \(self.label)")
        print("\(indent) INDEX: \(self.index)")
        }
        
    public override func printLayout()
        {
        if self.primitiveType == .string
            {
            super.printLayout()
            }
        }
    }
