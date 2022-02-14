//
//  TypeMetaclass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/1/22.
//

import Foundation

public class TypeMetaclass: TypeClass
    {
    public static func ==(lhs:TypeMetaclass,rhs:TypeMetaclass) -> Bool
        {
        return(lhs.fullName == rhs.fullName && lhs.generics == rhs.generics)
        }
        
    public override var sizeInBytes: Int
        {
        ArgonModule.shared.metaclassType.instanceSizeInBytes
        }
        
    public override var classType: TypeClass
        {
        ArgonModule.shared.metaclassType as! TypeClass
        }
        
    public override var objectType: Argon.ObjectType
        {
        .metaclass
        }
    }
