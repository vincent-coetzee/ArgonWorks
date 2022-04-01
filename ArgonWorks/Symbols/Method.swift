//
//  Method.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 3/3/22.
//

import Cocoa

public class Method: Symbol
    {
    public override var iconName: String
        {
        "IconMethod"
        }
        
    public override var iconTint: NSColor
        {
        SyntaxColorPalette.methodColor
        }
        
    public override var isMethod: Bool
        {
        true
        }
        
    public var returnType: Type
        {
        self.instances.first!.returnType
        }
        
    public override var children: Symbols
        {
        self.instances
        }
        
    public private(set) var instances = MethodInstances()
    
    public func addMethodInstance(_ methodInstance: MethodInstance)
        {
        self.instances.append(methodInstance)
        methodInstance.argonMethod = self
        }
        
    public func methodWithout(methodInstance: MethodInstance) -> Method
        {
        var copy = self.instances
        copy.remove(methodInstance)
        let newMethod = Method(label: self.label)
        newMethod.instances = copy
        return(newMethod)
        }
        
    public func appendMethodInstance(_ instance: MethodInstance)
        {
        self.instances.append(instance)
        instance.argonMethod = self
        }
        
    public override func display(indent: String)
        {
        for instance in self.instances
            {
            instance.display(indent: indent)
            }
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let method = Method(label: self.label)
        let newInstances = self.instances.map{$0.freshTypeVariable(inContext: context)}
        method.instances = newInstances
        method.type = self.type
        return(method as! Self)
        }
        
    public func instancesWithArity(_ arity: Int) -> MethodInstances
        {
        self.instances.filter{$0.arity == arity}
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        for instance in self.instances
            {
            instance.initializeType(inContext: context)
            }
        self.type = ArgonModule.shared.void
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        for instance in self.instances
            {
            instance.initializeTypeConstraints(inContext: context)
            }
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let copy = super.substitute(from: substitution)
        copy.instances = self.instances.map{$0.substitute(from: substitution)}
        return(copy)
        }
        
    public func instanceWithTypes(_ types: Types,returnType: Type) -> MethodInstance?
        {
        for instance in self.instances
            {
            if instance.parameters.map{$0.type} == types && instance.returnType == returnType
                {
                return(instance)
                }
            }
        return(nil)
        }
    }
