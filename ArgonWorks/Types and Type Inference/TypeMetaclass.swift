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
        self.container.argonModule.metaclassType.instanceSizeInBytes
        }
        
    public override var classType: TypeClass
        {
        self.container.argonModule.metaclassType as! TypeClass
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
        if (type as? TypeMetaclass).isNotNil
            {
            super.addSupertype(type)
            return
            }
        self.supertypes.append(type)
        }
        
    @discardableResult
    public override func makeMetaclass() -> TypeClass
        {
        self.type = self.container.argonModule.metaclassType
        return(self.type as! TypeClass)
        }
        
    public override func configureMetaclass(argonModule: ArgonModule)
        {
        }
        
    public override func encode(with coder: NSCoder)
        {
        let oldType = self.type
        self.type = nil
        super.encode(with: coder)
        self.type = oldType
        }
        
    public override func patchSymbols(topModule: TopModule)
        {
        guard !self.wasSymbolPatchingDone else
            {
            return
            }
        self.wasSymbolPatchingDone = true
        self.type = topModule.argonModule.metaclassType
        self.supertypes = self.supertypes.map{$0 as! TypeSurrogate}.map{$0.patchClass(topModule: topModule)}
        for slot in self.instanceSlots
            {
            slot.patchSymbols(topModule: topModule)
            }
        for slot in self.layoutSlots
            {
            slot.patchSymbols(topModule: topModule)
            }
        for aType in self.supertypes
            {
            aType.patchSymbols(topModule: topModule)
            }
        }
    }
