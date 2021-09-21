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
        return([])
        }
        
    public override var displayString: String
        {
        let string = "<" + self.genericClassParameterInstances.map{$0.displayString}.joined(separator: ",") + ">"
        return("\(self.label)\(string)")
        }
        
    internal let genericClassParameterInstances: Types
    internal let sourceClass:GenericClass
    
    init(label:Label,sourceClass:GenericClass,genericClassParameterInstances: Types)
        {
        self.sourceClass = sourceClass
        self.genericClassParameterInstances = genericClassParameterInstances
        super.init(label:label)
        }
        

    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
