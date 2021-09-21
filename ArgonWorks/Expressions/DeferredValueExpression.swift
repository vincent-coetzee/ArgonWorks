//
//  DeferredValueExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/9/21.
//

import Foundation

public class DeferredValueExpression: Expression
    {
    public override var resultType: Type
        {
        return(self.type)
        }
        
    private let name: Label
    private let type: Type
    
    init(_ name:Label,type:Type)
        {
        self.name = name
        self.type = type
        }
    }
