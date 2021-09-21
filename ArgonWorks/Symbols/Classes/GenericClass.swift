//
//  ParameterizedClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class GenericClass:Class
    {
    public override var isGenericClass: Bool
        {
        return(true)
        }
        
    public override var typeCode:TypeCode
        {
        _typeCode
        }
        
    public override var parametricClasses: Classes?
        {
        return(self.genericClassParameters)
        }
        
    public override var containedClassParameters: Array<GenericClassParameter>
        {
        var parameters = Array<GenericClassParameter>()
        for slot in self.symbols.values.filter({$0 is Slot}).map({$0 as! Slot})
            {
            parameters.append(contentsOf: slot.containedClassParameters)
            }
        return(parameters)
        }
        
    public override var containsUninstanciatedParameterics: Bool
        {
        return(true)
        }

    private var instances = Array<GenericClassInstance>()
    public private(set) var genericClassParameters = Array<Class>()
    private let _typeCode:TypeCode
    
    init(label: Label,typeCode: TypeCode)
        {
        self._typeCode = typeCode
        super.init(label: label)
        }
        
    override init(label: Label)
        {
        self._typeCode = .other
        super.init(label: label)
        }
        
    init(label: Label,genericClassParameters: Array<Class>)
        {
        self.genericClassParameters = genericClassParameters
        self._typeCode = .other
        super.init(label: label)
        }
        
    ///
    ///
    /// Don't mess with the names of this method or the next one because they are here solely
    /// for the use of the ArgonModule.
    ///
    ///
    init(label:Label,superclasses:Array<Label>,parameters: Classes,typeCode:TypeCode = .other)
        {
        self._typeCode = typeCode
        super.init(label:label)
        self.genericClassParameters = parameters
        self.superclassReferences = superclasses.map{ForwardReferenceClass(name:Name($0))}
        for parameter in parameters
            {
            self.addSymbol(parameter)
            }
        }
    ///
    ///
    /// See the comment above
    ///
    /// 
    convenience init(label:Label,superclasses:Array<Label>,parameters: Array<String>,typeCode:TypeCode = .other)
        {
        self.init(label:label,typeCode: .other)
        self.genericClassParameters = parameters.map{GenericClassParameter(label: $0)}
        self.superclassReferences = superclasses.map{ForwardReferenceClass(name:Name($0))}
        }
        
   public func of(_ type:Class) -> GenericClassInstance
        {
        let classParameter = GenericClassParameter(label: "ELEMENT")
        let concreteClass = classParameter.instanciate(withType: type.type)
        let instance = GenericClassInstance(label: Argon.nextName("_PARAMCLASS"), sourceClass: self, genericClassParameterInstances: [concreteClass])
        self.instances.append(instance)
        return(instance)
        }
        
    public override func instanciate(withTypes types: Types,reportingContext: ReportingContext) -> Type
        {
        if self.genericClassParameters.count != types.count
            {
            reportingContext.dispatchError(at: self.declaration!, message: "The given number of generic parameters does not match the number required by the class '\(self.label)'.")
            return(.class(GenericClassInstance(label: self.label, sourceClass: self, genericClassParameterInstances: [])))
            }
        let typeMappings:[Type] = zip(types,self.genericClassParameters).map{$0.1.instanciate(withType: $0.0)}
        for instance in self.instances
            {
            if instance.genericClassParameterInstances == typeMappings
                {
                return(.class(instance))
                }
            }
        let classInstance = GenericClassInstance(label: self.label, sourceClass: self, genericClassParameterInstances: typeMappings)
        self.instances.append(classInstance)
        return(.class(classInstance))
        }
    }
