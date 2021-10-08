//
//  ParameterizedClassInstance.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public class GenericClassInstance:Class
    {
    public override var completeName: String
        {
        let names = self.genericClassParameterInstances.map{$0.displayString}
        let string = names.isEmpty ? "" : "<" + names.joined(separator: ",") + ">"
        return("\(self.label)\(string)")
        }
        
    public override var isGenericClassInstance: Bool
        {
        return(true)
        }
        
    public override var mangledName: String
        {
        let typeNames = "<" + self.genericClassParameterInstances.map{$0.mangledName}.joined(separator: ",") + ">"
        return("\(self.label)\(typeNames)")
        }
        
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
    
    required init?(coder: NSCoder)
        {
        self.genericClassParameterInstances = coder.decodeTypes(forKey: "genericClassParameterInstances")
        self.sourceClass = coder.decodeObject(forKey: "sourceClass") as! GenericClass
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encodeTypes(self.genericClassParameterInstances,forKey: "genericClassParameterInstances")
        coder.encode(self.sourceClass,forKey: "sourceClass")
        super.encode(with: coder)
        }
        
    init(label:Label,sourceClass:GenericClass,genericClassParameterInstances: Types)
        {
        self.sourceClass = sourceClass
        self.genericClassParameterInstances = genericClassParameterInstances
        super.init(label:label)
        }
        
 
    }
