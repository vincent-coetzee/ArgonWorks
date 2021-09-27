//
//  ArrayClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class ArrayClass:GenericSystemClass
    {
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
    }
