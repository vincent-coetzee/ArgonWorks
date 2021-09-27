//
//  TaggedPrimitiveClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class TaggedPrimitiveClass:PrimitiveClass
    {
    public override func printContents(_ indent: String = "")
        {
        let typeName = Swift.type(of: self)
        print("\(indent)\(typeName): \(self.label)")
        }
        
    public static let floatClass = TaggedPrimitiveClass(label:"Float",primitiveType:.float)
    public static let integerClass = TaggedPrimitiveClass(label:"Integer",primitiveType:.integer)
    public static let uIntegerClass = TaggedPrimitiveClass(label:"UInteger",primitiveType:.uInteger)
    }
