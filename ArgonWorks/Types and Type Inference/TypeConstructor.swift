//
//  TypeConstructor.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeConstructor: Type
    {
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
        fatalError()
        }
        
    public override func encode(with coder: NSCoder)
        {
        fatalError()
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
    }
