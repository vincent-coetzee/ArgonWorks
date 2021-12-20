//
//  TypeEnumeration.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeEnumeration: TypeConstructor
    {
    public override var displayString: String
        {
        var names = self.generics.map{$0.displayString}.joined(separator: ",")
        if !names.isEmpty
            {
            names = "<" + names + ">"
            }
        return("TypeEnumeration(\(self.enumeration.label)\(names))")
        }
    
    public override var literal: Literal
        {
        .enumeration(self.enumeration)
        }
        
    public override var userString: String
        {
        self.enumeration.fullName.displayString
        }
        
    public override var enumerationValue: Enumeration
        {
        self.enumeration
        }
        
    public override var memoryAddress: Address
        {
        get
            {
            self.enumeration.memoryAddress
            }
        set
            {
            self.enumeration.memoryAddress = newValue
            }
        }
        
    public override var instanceSizeInBytes: Int
        {
        self.enumeration.instanceSizeInBytes
        }
        
    public override var sizeInBytes: Int
        {
        fatalError()
        }
        
    public override var argonHash: Int
        {
        var hasher = Hasher()
        hasher.combine(super.argonHash)
        hasher.combine(self.enumeration.argonHash)
        for type in self.generics
            {
            hasher.combine(type.argonHash)
            }
        let hashValue = hasher.finalize()
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
//    public override var type: Type?
//        {
//        get
//            {
//            let anEnum = TypeEnumeration(enumeration: self.enumeration,generics: self.generics.map{$0.type!})
//            anEnum.setParent(self.parent)
//            return(anEnum)
//            }
//        set
//            {
//            }
//        }
        
    internal let enumeration: Enumeration
    
    init(label: Label,enumeration: Enumeration)
        {
        self.enumeration = enumeration
        super.init(label: label,generics: [])
        self.enumeration.setParent(self)
        }
        
    init(enumeration: Enumeration,generics: Types)
        {
        self.enumeration = enumeration
        super.init(label: enumeration.label,generics: generics)
        self.enumeration.setParent(self)
        }
        
    required init(label: Label)
        {
        self.enumeration = Enumeration(label: "")
        super.init(label: label)
        self.enumeration.setParent(self)
        }
        
    required init?(coder: NSCoder)
        {
        self.enumeration = coder.decodeObject(forKey: "enumeration") as! Enumeration
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.enumeration,forKey: "enumeration")
        super.encode(with: coder)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        self.enumeration.lookup(label: label)
        }
        
    public override func layoutObjectSlots(using: AddressAllocator)
        {
        self.enumeration.layoutObjectSlots(using: using)
        }
        
    public override func allocateAddresses(using allocator: AddressAllocator) throws
        {
        try self.enumeration.allocateAddresses(using: allocator)
        }
        
    public override func layoutInMemory(using: AddressAllocator)
        {
        self.enumeration.layoutInMemory(using: using)
        }
    }
