//
//  ClassParameter.swift
//  GenericClass
//
//  Created by Vincent Coetzee on 16/8/21.
//

///
///
/// A ClassParameter instance can be used whereever a Class instance
/// would normally be used but it represents a Class that will be placed
/// whereever the ClassParameter appears when the Class that contains
/// the ClassParameter is instanciated. In essence then a ClassParameter
/// is a parameter to a Class definition and takes on a concrete value
/// at instanciation time.
///
import Foundation

public class GenericClassParameter: Class
    {
    public override var containedClassParameters: Array<GenericClassParameter>
        {
        return(super.containedClassParameters.appending(self))
        }
        
    public init(_ name: Label)
        {
        super.init(label: name)
        }
        
    public override init(label name: Label)
        {
        super.init(label: name)
        }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func ==(lhs:GenericClassParameter,rhs:GenericClassParameter) -> Bool
        {
        return(lhs.label == rhs.label)
        }
        
    public override var isGenericClassParameter: Bool
        {
        return(true)
        }
        
    public override func instanciate(withType: Type) -> Type
        {
        if withType.isGenericClassParameter
            {
            return(withType)
            }
        let instance = GenericClassParameterInstance(label: self.label,classParameter: self,type: withType)
        return(.class(instance))
        }
    }

///
///
/// A ConcreteClass is created when a ClassParameter is instanciated.
/// What that means is at point a concrete class is substituted for the ClassParameter
/// in a Class that is being concretized, a ConcreteClass is created and
/// that instance holds the concrete class that is being substituted for the
/// ClassParameter.
///
///
public class GenericClassParameterInstance: Class
    {
    public static func ==(lhs:GenericClassParameterInstance,rhs:GenericClassParameterInstance) -> Bool
        {
        return(lhs.theType == rhs.theType && lhs.classParameter == rhs.classParameter)
        }
        
    public override var containsUninstanciatedParameterics: Bool
        {
        return(false)
        }
        
    private let theType: Type
    private let classParameter: GenericClassParameter
    
    init(label: Label,classParameter: GenericClassParameter,type: Type)
        {
        self.classParameter = classParameter
        self.theType = type
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    }

public typealias GenericClassParameters = Array<GenericClassParameter>

public typealias GenericClassParameterInstances = Array<GenericClassParameterInstance>

extension Array
    {
    public func appending(_ element:Element) -> Self
        {
        var newArray = self
        newArray.append(element)
        return(newArray)
        }
    }
