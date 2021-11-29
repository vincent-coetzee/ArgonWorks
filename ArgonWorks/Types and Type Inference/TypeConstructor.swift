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
        
    public override func deepCopy() -> Self
        {
        TypeConstructor(label: self.label,generics: self.generics.map{$0.deepCopy()}) as! Self
        }
        
    public override func contains(_ typeVariable: TypeVariable) -> Bool
        {
        for type in self.generics
            {
            if type.contains(typeVariable)
                {
                return(true)
                }
            }
        return(false)
        }
        
    public override func substitute(from context: TypeContext) -> Type
        {
        self.generics = self.generics.map{$0.substitute(from: context)}
        return(self)
        }
    }
