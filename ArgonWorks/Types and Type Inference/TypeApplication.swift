//
//  TypeApplication.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 30/11/21.
//

import Foundation

public class TypeApplication: Type
    {
    private let types: Types
    private let returnType: Type
    
    init(types: Types,returnType: Type)
        {
        self.types = types
        self.returnType = returnType
        super.init()
        }
        
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    required init(label: Label)
        {
        self.types = []
        self.returnType = Type()
        super.init()
        }
    }
