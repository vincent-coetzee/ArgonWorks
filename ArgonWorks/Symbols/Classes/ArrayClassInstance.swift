//
//  ArrayClassInstance.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 14/7/21.
//

import Foundation

public class ArrayClassInstance: GenericSystemClassInstance
    {
    public override var memoryAddress: Word
        {
        return(self.sourceClass.memoryAddress)
        }
        
    public func elementType() -> Class?
        {
        return(self.genericClassParameterInstances[0])
        }
        
    public override var typeCode:TypeCode
        {
        .array
        }
        
    public override var displayString: String
        {
        "Array<\(self.genericClassParameterInstances[0].displayName)>"
        }
    }
