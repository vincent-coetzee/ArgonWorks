//
//  TypeGenericInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/1/22.
//

import Foundation

public class TypeClassInstance: TypeConstructor
    {
    private let archetype: Type
    
    init(archetype: Type,generics: Types)
        {
        self.archetype = archetype
        super.init(label: archetype.label,generics: generics)
        }
        
    required init?(coder: NSCoder)
        {
        self.archetype = coder.decodeObject(forKey: "archetype") as! Type
        super.init(coder: coder)
        }
        
    required init(label: Label)
        {
        fatalError("init(label:) has not been implemented")
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.archetype,forKey: "archetype")
        super.encode(with: coder)
        }
    }
