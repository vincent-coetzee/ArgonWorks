//
//  TypeConstructor.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeConstructor: Type
    {
//    public static func ==(lhs: TypeConstructor,rhs: TypeConstructor) -> Bool
//        {
//        lhs.index == rhs.index && lhs.generics == rhs.generics
//        }
//        
    public override var isTypeConstructor: Bool
        {
        true
        }
        
    public override var displayString: String
        {
        let names = self.generics.map{$0.displayString}.joined(separator: ",")
        return("TypeConstructor(\(self.label),[\(names)])")
        }

    public static func ==(lhs: TypeConstructor,rhs: Type) -> Bool
        {
        if !(rhs is TypeConstructor)
            {
            return(false)
            }
        let right = rhs as! TypeConstructor
        return(lhs.label == right.label && lhs.generics == right.generics)
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
        return(false)
        }
        
    public override var argonHash: Int
        {
        var hasher = Hasher()
        hasher.combine("\(Swift.type(of: self))")
        hasher.combine(self.label)
        for type in self.generics
            {
            hasher.combine(type.argonHash)
            }
        let hashValue = hasher.finalize()
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
    public override var typeVariables: TypeVariables
        {
        self.generics.flatMap{$0.typeVariables}
        }
        
    internal var generics: Array<Type> = []
    
    init(label: Label,generics: Types)
        {
        self.generics = generics
        super.init(label: label)
        }
        
    required init(label: Label)
        {
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        print("START DECODE TYPE CONSTRUCTOR")
        self.generics = coder.decodeObject(forKey: "generics") as! Types
        super.init(coder: coder)
        print("END DECODE TYPE CONSTRUCTOR")
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.generics,forKey:"generics")
        super.encode(with: coder)
        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? TypeConstructor
            {
            return(self.label == second.label && self.generics == second.generics)
            }
        return(super.isEqual(object))
        }
        
    public override func contains(_ type:Type) -> Bool
        {
        for inner in self.generics
            {
            if inner == type
                {
                return(true)
                }
            if inner.contains(type)
                {
                return(true)
                }
            }
        return(false)
        }
        
    @discardableResult
    public override func typeVar(_ label: Label) -> TypeVariable
        {
        let typeVariable = TypeContext.freshTypeVariable(named: label)
        self.generics.append(typeVariable)
        return(typeVariable)
        }
    }
