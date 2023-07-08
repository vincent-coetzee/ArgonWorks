//
//  InfixOperatorInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/12/21.
//

import Foundation

public class InfixOperatorInstance: StandardMethodInstance
    {
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = InfixOperatorInstance(label: self.label)
        instance.block = (substitution.substitute(self.block) as! MethodInstanceBlock)
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }
    }

public typealias InfixOperatorInstances = Array<InfixOperatorInstance>

public class PostfixOperatorInstance: StandardMethodInstance
    {
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = PostfixOperatorInstance(label: self.label)
        instance.block = (substitution.substitute(self.block) as! MethodInstanceBlock)
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }
    }

public typealias PostfixOperatorInstances = Array<PostfixOperatorInstance>

public class PrefixOperatorInstance: StandardMethodInstance
    {
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = PrefixOperatorInstance(label: self.label)
        instance.block = (substitution.substitute(self.block) as! MethodInstanceBlock)
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }
    }

public typealias PrefixOperatorInstances = Array<PrefixOperatorInstance>

public class PrimitiveInfixOperatorInstance: InfixOperatorInstance
    {
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = PrimitiveInfixOperatorInstance(label: self.label)
        instance.block = (substitution.substitute(self.block) as! MethodInstanceBlock)
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }
    }

public typealias PrimitiveInfixOperatorInstances = Array<PrimitiveInfixOperatorInstance>

public class PrimitivePostfixOperatorInstance: PostfixOperatorInstance
    {
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = PrimitivePostfixOperatorInstance(label: self.label)
        instance.block = (substitution.substitute(self.block) as! MethodInstanceBlock)
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }
    }

public typealias PrimitivePostfixOperatorInstances = Array<PrimitivePostfixOperatorInstance>

public class PrimitivePrefixOperatorInstance: PrefixOperatorInstance
    {
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let instance = PrimitivePrefixOperatorInstance(label: self.label)
        instance.block = (substitution.substitute(self.block) as! MethodInstanceBlock)
        instance.parameters = self.parameters.map{$0.substitute(from: substitution)}
        instance.returnType = substitution.substitute(self.returnType)
        return(instance as! Self)
        }
    }

public typealias PrimitivePrefixOperatorInstances = Array<PrimitivePrefixOperatorInstance>

