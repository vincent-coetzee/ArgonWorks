//
//  ArrayAccessExpression.swift
//  ArrayAccessExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ArrayAccessExpression: Expression
    {
//    public override var typeConstraints: TypeTerms
//        {
//        return(self.array.typeConstraints)
//        }
        
    public override var displayString: String
        {
        return("\(self.array.displayString)[\(self.index.displayString)]")
        }

    private let array:Expression
    private let index:Expression
    private var isLValue = false
    
    public required init?(coder: NSCoder)
        {
        self.array = coder.decodeObject(forKey: "array") as! Expression
        self.index = coder.decodeObject(forKey: "index") as! Expression
        self.isLValue = coder.decodeBool(forKey: "isLValue")
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.isLValue,forKey: "isLValue")
        coder.encode(self.array,forKey: "array")
        coder.encode(self.index,forKey: "index")
        }
        
    init(array:Expression,index:Expression)
        {
        self.array = array
        self.index = index
        super.init()
        self.array.setParent(self)
        self.index.setParent(self)
        }
        
    public override func visit(visitor: Visitor) throws
        {
        try self.array.visit(visitor: visitor)
        try self.index.visit(visitor: visitor)
        try visitor.accept(self)
        }
        
    public override func display(indent: String)
        {
        print("\(indent)ARRAY ACCESS:")
        print("\(indent)\tARRAY: \(self.array.type!.displayString)")
        self.array.display(indent: indent + "\t\t")
        print("\(indent)\tINDEX: \(self.index.type!.displayString)")
        self.index.display(indent: indent + "\t\t")
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = ArrayAccessExpression(array: self.array.freshTypeVariable(inContext: context),index: self.index.freshTypeVariable(inContext: context))
        expression.type = self.type!.freshTypeVariable(inContext: context)
        return(expression as! Self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = ArrayAccessExpression(array: substitution.substitute(self.array),index: substitution.substitute(self.index))
        expression.type = substitution.substitute(self.type!)
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.array.initializeTypeConstraints(inContext: context)
        try self.index.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: self.index.type,right: context.integerType,origin: .expression(self)))
//        let arrayClass = (context.arrayType as! TypeClass).theClass
//        let variable = context.freshTypeVariable()
//        let arrayType = TypeClass(class: arrayClass,generics:[variable])
//        context.append(TypeConstraint(left: self.array.type,right: arrayType,origin: .expression(self)))
//        context.append(TypeConstraint(left: self.type,right: variable,origin: .expression(self)))
        }

    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.array.initializeType(inContext: context)
        try self.index.initializeType(inContext: context)
        if let arrayType = self.array.type,arrayType.isArray
            {
            self.type = arrayType.arrayElementType
            }
        else
            {
            self.type  = context.freshTypeVariable()
            }
        }
        
    public override func becomeLValue()
        {
        self.isLValue = true
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.array.analyzeSemantics(using: analyzer)
        self.index.analyzeSemantics(using: analyzer)
        let arrayType = self.array.type!
        if !arrayType.isArrayClassInstance
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The type of object indexed is invalid.")
            }
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type!.lookup(label: label))
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.line)
            }
        let temp = instance.nextTemporary()
        try self.array.emitCode(into: instance,using: generator)
        instance.append(nil,"MOV",self.array.place,.none,temp)
        let offset = instance.nextTemporary()
        try self.index.emitCode(into: instance,using: generator)
        instance.append(nil,"MOV",self.index.place,.none,offset)
        instance.append(nil,"MUL",offset,.literal(.integer(8)),offset)
        instance.append(nil,"IADD",offset,temp,temp)
        self._place = temp
        }
        
    public override func emitAddressCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
//        fatalError("This should have been implemented")
        }
    }
