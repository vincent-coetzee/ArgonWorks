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
        
    public override var displayString: String
        {
        var names = self.generics.map{$0.displayString}.joined(separator: ",")
        if !names.isEmpty
            {
            names = "<" + names + ">"
            }
        else
            {
            names = "<none>"
            }
        return("TypeMetaclass(\(self.label)\(names))")
        }
        
    public override var isMetaclass: Bool
        {
        true
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
        
    public func resetInheritance()
        {
        self.supertypes = []
        }
        
    public override func addSupertype(_ type: Type)
        {
        if type.label == "Class"
            {
            print("HALT")
            }
        if let aType = type as? TypeMetaclass
            {
            super.addSupertype(type)
            return
            }
        self.supertypes.append(type)
        }
        
    @discardableResult
    public override func makeMetaclass() -> TypeClass
        {
        self.metaclass = ArgonModule.shared.metaclassType as? TypeClass
        self.type = self.metaclass
        return(self.metaclass as! TypeClass)
        }
        
    public override func configureMetaclass()
        {
        self.metaclass.type = ArgonModule.shared.metaclassType
        }
    }
