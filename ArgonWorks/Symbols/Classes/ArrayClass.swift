//
//  ArrayClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class ArrayClass:GenericSystemClass
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    private static var allInstances = Array<ArrayClassInstance>()
    
    public override var mangledName: String
        {
        fatalError()
        }
        
    public override var nativeCType: NativeCType
        {
        return(NativeCType.arrayPointerType)
        }
        
    public override var internalClass: Class
        {
        return(self.topModule.argonModule.generic)
        }
        
    public override var isArrayClass: Bool
        {
        return(true)
        }
        
    public func withElement(_ type: Type) -> ArrayClassInstance
        {
        let parameter = GenericClassParameter(label: "ELEMENT")
        let concreteClass = parameter.instanciate(withType: type)
        let instance = ArrayClassInstance(label: Argon.nextName("_ARRAY"), sourceClass: self, genericClassParameterInstances: [concreteClass])
        Self.allInstances.append(instance)
        return(instance)
        }
        
   public override func of(_ type:Class) -> ArrayClassInstance
        {
        let parameter = GenericClassParameter(label: "ELEMENT")
        let concreteClass = parameter.instanciate(withType: type.type)
        let instance = ArrayClassInstance(label: Argon.nextName("_ARRAY"), sourceClass: self, genericClassParameterInstances: [concreteClass])
        instance.slotClassType = self.slotClassType
        Self.allInstances.append(instance)
        return(instance)
        }
        
    public override func instanciate(withTypes types: Types,reportingContext: ReportingContext) -> Type
        {
        if self.genericClassParameters.count != types.count
            {
            reportingContext.dispatchError(at: self.declaration!, message: "The given number of generic parameters(\(types.count)) does not match the number required by the class(\(self.genericClassParameters.count)) '\(self.label)'.")
            return(.class(ArrayClassInstance(label: self.label, sourceClass: self, genericClassParameterInstances: [])))
            }
        let typeMappings:[Type] = zip(types,self.genericClassParameters).map{$0.1.instanciate(withType: $0.0)}
        for instance in self.instances
            {
            if instance.genericClassParameterInstances == typeMappings
                {
                return(.class(instance))
                }
            }
        let classInstance = ArrayClassInstance(label: self.label, sourceClass: self, genericClassParameterInstances: typeMappings)
        self.instances.append(classInstance)
        return(.class(classInstance))
        }
    }
