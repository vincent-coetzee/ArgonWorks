//
//  TypeFunction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/11/21.
//

import Foundation

public class TypeFunction: TypeConstructor
    {
    public override var isFunction: Bool
        {
        true
        }
        
    public override var hasVariableTypes: Bool
        {
        for type in self.generics
            {
            if type.hasVariableTypes
                {
                return(true)
                }
            }
        if self.returnType.hasVariableTypes
            {
            return(true)
            }
        return(false)
        }
        
    public override var argonHash: Int
        {
        var hashValue = "\(Swift.type(of: self))".polynomialRollingHash
        hashValue = hashValue << 13 ^ self.label.polynomialRollingHash
        hashValue = hashValue << 13 ^ self.returnType.argonHash
        for type in self.generics
            {
            hashValue = hashValue << 13 ^ type.argonHash
            }
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
    internal var returnType: Type
    
    init(label: Label,types: Types,returnType: Type)
        {
        self.returnType = returnType
        super.init(label: label,generics:types)
        }
        
    required init?(coder: NSCoder)
        {
        self.returnType = coder.decodeObject(forKey: "returnType") as! Type
        super.init(coder: coder)
        }
        
    init(label: Label,argonModule: ArgonModule)
        {
        self.returnType = argonModule.void
        super.init(label: label)
        }
        
    required init(label: Label)
        {
        fatalError()
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.returnType,forKey: "returnType")
        super.encode(with: coder)
        }
    }
