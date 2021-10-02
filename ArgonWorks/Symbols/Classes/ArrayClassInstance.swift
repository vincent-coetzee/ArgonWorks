//
//  ArrayClassInstance.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 14/7/21.
//

import Foundation

public class ArrayClassInstance: GenericSystemClassInstance
    {
    public var elementType: Type
        {
        return(self.genericClassParameterInstances[0])
        }
        
    public override var isArrayClassInstance: Bool
        {
        return(true)
        }
        
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    public override var mangledName: String
        {
        let type = self.genericClassParameterInstances.first!
        return("[\(type.mangledName)]")
        }
        
    public override var memoryAddress: Word
        {
        return(self.sourceClass.memoryAddress)
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
