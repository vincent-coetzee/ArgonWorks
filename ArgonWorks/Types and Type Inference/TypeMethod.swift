//
//  TypeMethod.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/12/21.
//

import Foundation

public class TypeMethod: Type
    {
    internal let method: Method
    
    init(label:Label,method: Method)
        {
        self.method = method
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
        
    required init(label: Label)
        {
        self.method = Method(label: label)
        super.init(label: label)
        }
    }
