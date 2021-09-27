//
//  ArrayClassInstance.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 14/7/21.
//

import Foundation

public class ArrayClassInstance: GenericSystemClassInstance
    {
    public override var mangledName: String
        {
        let type = self.genericClassParameterInstances.first!
        return("[\(type.mangledName)]")
        }
        
    public override var memoryAddress: Word
        {
        return(self.sourceClass.memoryAddress)
        }
        
    public func elementType() -> Type?
        {
        return(self.genericClassParameterInstances[0])
        }
        
    public override var typeCode:TypeCode
        {
        .array
        }
        
    public override var displayString: String
        {
        "Array<\(self.genericClassParameterInstances[0].displayString)>"
        }
    }
