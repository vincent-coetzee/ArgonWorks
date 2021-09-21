//
//  PrimitiveClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class PrimitiveClass:Class
    {
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
    
    public enum PrimitiveType
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
        
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutObjectSlots()
        {
        if self.primitiveType == .string
            {
            super.layoutObjectSlots()
            }
        }
        
    public override func realizeSuperclasses(in vm: VirtualMachine)
        {
        super.realizeSuperclasses(in: vm)
        if self.superclasses.map({$0.label}).contains("Magnitude")
            {
            print("INDEX OF MAGNITUDE = \(self.superclasses[0].index)")
            print("VM INDEX = \(self.superclasses[0].topModule.virtualMachine.index)")
            }
        }
        
    public override func printLayout()
        {
        if self.primitiveType == .string
            {
            super.printLayout()
            }
        }
    }
