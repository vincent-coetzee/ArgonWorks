//
//  TypeVoid.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 2/12/21.
//

import Foundation

public class TypeVoid: TypeClass
    {
    public static func ==(lhs:TypeVoid,rhs:TypeVoid) -> Bool
        {
        true
        }
        
    init()
        {
        super.init(class: Class(label: "Void"),generics: [])
        }
        
    init(generics: Types)
        {
        super.init(class: Class(label: "Void"),generics: [])
        }
        
    required init(label: Label)
        {
        super.init(class: Class(label: "Void"),generics: [])
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
