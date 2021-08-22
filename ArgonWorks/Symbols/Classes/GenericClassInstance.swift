//
//  ParameterizedClassInstance.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public class GenericClassInstance:Class
    {
    public override var containedClassParameters: Array<GenericClassParameter>
        {
        var parameters = Array<GenericClassParameter>()
        for slot in self.symbols.values.filter({$0 is Slot}).map({$0 as! Slot})
            {
            parameters.append(contentsOf: slot.containedClassParameters)
            }
        for parameter in self.genericClassParameterInstances
            {
            parameters.append(contentsOf: parameter.containedClassParameters)
            }
        return(parameters)
        }
        
    public override var displayString: String
        {
        let string = "<" + self.genericClassParameterInstances.map{$0.displayString}.joined(separator: ",") + ">"
        return("\(self.label)\(string)")
        }
        
    internal let genericClassParameterInstances: Classes
    internal let sourceClass:GenericClass
    
    init(label:Label,sourceClass:GenericClass,genericClassParameterInstances: Classes)
        {
        self.sourceClass = sourceClass
        self.genericClassParameterInstances = genericClassParameterInstances
        super.init(label:label)
        }
}
