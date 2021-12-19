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
        
    private static var allInstances = Array<ArrayClass>()
    
    public override var mangledName: String
        {
        fatalError()
        }
        
    public override var nativeCType: NativeCType
        {
        return(NativeCType.arrayPointerType)
        }
//
//    public override var internalClass: Class
//        {
//        return(ArgonModule.shared.generic)
//        }
        
    public override var isArrayClass: Bool
        {
        return(true)
        }
        
    public func withElement(_ type: Type) -> Type
        {
        TypeClass(class: self,generics: [type])
        }
        
   public override func of(_ type:Type) -> Type
        {
        TypeClass(class: self,generics: [type])
        }
        
    public override func instanciate(withTypes types: Types,reportingContext: Reporter) -> Type
        {
        TypeClass(class: self,generics: types)
//        if self.types.count != types.count
//            {
//            let location = self.declaration.isNil ? Location(line: 0, lineStart: 0, lineStop: 0, tokenStart: 0, tokenStop: 0) : self.declaration!
//            reportingContext.dispatchError(at: location, message: "The given number of generic parameters(\(types.count)) does not match the number required by the class(\(self.types.count)) '\(self.label)'.")
//            let instance = self.deepCopy()
//            instance.types = types
//            return(TypeClass(class: instance))
//            }
//        let classInstance = self.deepCopy()
//        classInstance.types = types
//        self.instances.append(classInstance)
//        return(TypeClass(label: classInstance.label,class: classInstance))
        }
    }
