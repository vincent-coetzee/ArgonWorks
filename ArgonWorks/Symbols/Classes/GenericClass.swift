//
//  ParameterizedClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class GenericClass:Class
    {
    public override var completeName: String
        {
        let names = self.types.map{$0.displayString}
        let string = names.isEmpty ? "" : "<" + names.joined(separator: ",") + ">"
        return("\(self.label)\(string)")
        }
        
    public override var isGenericClass: Bool
        {
        return(true)
        }
        
    public override var genericTypes: Types
        {
        self.types
        }
        
    public override var typeCode:TypeCode
        {
        _typeCode
        }

    public override var displayString: String
        {
        let names = self.types.map{$0.displayString}
        let string = names.isEmpty ? "" : "<" + names.joined(separator: ",") + ">"
        return("\(self.label)\(string)")
        }
//        
//    public override var containedClassParameters: Array<Type>
//        {
//        var parameters = Array<GenericType>()
//        for slot in self.symbols.filter({$0 is Slot}).map({$0 as! Slot})
//            {
//            parameters.append(contentsOf: slot.containedClassParameters)
//            }
//        return(parameters)
//        }
        
    public override var containsUninstanciatedParameterics: Bool
        {
        return(true)
        }
        
    internal var instances = Array<GenericClass>()
    internal var types = Types()
    private var _typeCode:TypeCode
    
    init(label: Label,typeCode: TypeCode)
        {
        self._typeCode = typeCode
        super.init(label: label)
        }
        
    required init(label: Label)
        {
        self._typeCode = .other
        super.init(label: label)
        }
        
    init(label: Label,types: Types)
        {
        self.types = types
        self._typeCode = .other
        super.init(label: label)
        }
        
    required init?(coder: NSCoder)
        {
        self.types = coder.decodeObject(forKey: "types") as! Types
        self.instances = coder.decodeObject(forKey: "instances") as! Array<GenericClass>
        self._typeCode = .array
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.instances,forKey: "instances")
        coder.encode(self.types,forKey: "types")
        super.encode(with: coder)
        }
        
    internal override func createType() -> Type
        {
        TypeClass(class: self,generics: self.types)
        }
    ///
    ///
    /// Don't mess with the names of this method or the next one because they are here solely
    /// for the use of the ArgonModule.
    ///
    ///
    init(label:Label,superclasses: Types,types: Types,typeCode:TypeCode = .other)
        {
        self._typeCode = typeCode
        super.init(label:label)
        self.types = types
        for aClass in superclasses
            {
            self.addSuperclass(aClass)
            if aClass.isGenericClass
                {
                for newType in ((aClass as! TypeClass).theClass as! GenericClass).types
                    {
                    if !self.containsType(withLabel: newType.label)
                        {
                        self.types.append(newType)
                        }
                    }
                }
            }
        for type in self.types
            {
            if type.isGenericType
                {
                self.addSymbol(type)
                }
            }
        }
        
    private func containsType(withLabel: Label) -> Bool
        {
        for type in self.types
            {
            if type.label == withLabel
                {
                return(true)
                }
            }
        return(false)
        }
    ///
    ///
    /// See the comment above
    ///
    /// 
//    convenience init(label:Label,superclasses:Array<Label>,types: Array<String>,typeCode:TypeCode = .other)
//        {
//        self.init(label:label,typeCode: .other)
//        self.types = types.map{TypeParameterType(TypeParameter(label: $0))}
//        self.superclassReferences = superclasses.map{ForwardReferenceClass(name:Name($0))}
//        }
        
    public override func display(indent: String)
        {
        print("\(indent)\(Swift.type(of: self)): \(self.label)")
        let list = self.types.map{$0.displayString}.joined(separator: ",")
        print("\(indent)\tGENERICS: \(list)")
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let copy = super.substitute(from: substitution)
        copy.types = self.types.map{substitution.substitute($0)}
        return(copy)
        }
        
   public func of(_ innerType:Type) -> Type
        {
        if self.types == [innerType]
            {
            return(self.type!)
            }
        return(TypeClass(class: self,generics: [innerType]))
        }
        
//    public override func instanciate(withType: Type) -> Type
//        {
//        TypeClass(class: self,generics: [type])
//        }
//        
//    public override func instanciate(withTypes types: Types,reportingContext: Reporter) -> Type
//        {
//        TypeClass(class: self,generics: types)
//        }
//        
    private func congruentInstance(matchingTypes: Types) -> GenericClass?
        {
        for instance in self.instances
            {
            var matches = true
            for (instanceType,incomingType) in zip(instance.types,matchingTypes)
                {
                if instanceType != incomingType
                    {
                    matches = false
                    break
                    }
                }
            if matches
                {
                return(instance)
                }
            }
        return(nil)
        }
    }
