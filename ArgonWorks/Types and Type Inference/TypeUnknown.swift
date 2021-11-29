//
//  TypeUnknown.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/11/21.
//

import Foundation

public class TypeUnknown: Type
    {
    public override var isUnknown: Bool
        {
        true
        }
        
    public override var displayString: String
        {
        return("TypeUnknown")
        }
        
    public override func deepCopy() -> Self
        {
        Type.unknown as! Self
        }
    }
