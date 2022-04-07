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
        
    public override var diagnosticString: String
        {
        "self.array<\(self.array.type)>[self.index<\(self.index.type)>]"
        }
        
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
        self.array.container = .expression(self)
        self.index.container = .expression(self)
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
        print("\(indent)\tARRAY: \(self.array.type.displayString)")
        self.array.display(indent: indent + "\t\t")
        print("\(indent)\tINDEX: \(self.index.type.displayString)")
        self.index.display(indent: indent + "\t\t")
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = ArrayAccessExpression(array: self.array.freshTypeVariable(inContext: context),index: self.index.freshTypeVariable(inContext: context))
        expression.type = self.type.freshTypeVariable(inContext: context)
        expression.locations = self.locations
        return(expression as! Self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = ArrayAccessExpression(array: substitution.substitute(self.array),index: substitution.substitute(self.index))
        expression.type = substitution.substitute(self.type)
        expression.issues = self.issues
        return(expression as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        self.array.initializeTypeConstraints(inContext: context)
        self.index.initializeTypeConstraints(inContext: context)
        let arrayType = context.arrayType.withGenerics([self.type])
        context.append(TypeConstraint(left: self.array.type,right: arrayType,origin: .expression(self)))
        context.append(TypeConstraint(left: self.index.type,right: context.integerType,origin: .expression(self)))
        if self.array.type is TypeConstructor
            {
            context.append(TypeConstraint(left: self.type,right: (self.array.type as! TypeConstructor).generics[0],origin: .expression(self)))
            }
        }
        
    public override func inferType(inContext context: TypeContext)
        {
        self.array.inferType(inContext: context)
        self.index.inferType(inContext: context)
        if self.array.type.isArray
            {
            self.type = (self.array.type as! TypeConstructor).generics[0]
            }
        else
            {
            self.type = context.freshTypeVariable()
            }
        let arrayType = context.arrayType.withGenerics([self.type])
        context.append(TypeConstraint(left: self.array.type,right: arrayType,origin: .expression(self)))
        context.append(TypeConstraint(left: self.index.type,right: context.integerType,origin: .expression(self)))
        }

    public override func initializeType(inContext context: TypeContext)
        {
        self.array.initializeType(inContext: context)
        self.index.initializeType(inContext: context)
        let arrayType = self.array.type
        if arrayType.isArray
            {
            self.type = (arrayType as! TypeConstructor).generics[0]
            }
        else
            {
            self.type  = context.freshTypeVariable()
            }
        }
        
    public override func emitAddressCode(into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.array.emitAddressCode(into: buffer,using: using)
        try self.index.emitValueCode(into: buffer,using: using)
        let temporary = buffer.nextTemporary
        buffer.add(.i64,.MUL,self.index.place,.integer(8),temporary)
        buffer.add(.i64,.ADD,temporary,self.array.place,temporary)
        self._place = temporary
        }
        
    public override func emitValueCode(into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.array.emitAddressCode(into: buffer,using: using)
        try self.index.emitValueCode(into: buffer,using: using)
        let temporary = buffer.nextTemporary
        buffer.add(.i64,.MUL,self.index.place,.integer(8),temporary)
        buffer.add(.i64,.ADD,temporary,self.array.place,temporary)
        buffer.add(.i64,.LOADP,temporary,.integer(0), temporary)
        self._place = temporary
        }
        
    public override func assign(from expression: Expression,into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        try expression.emitValueCode(into: buffer,using: using)
        try self.emitAddressCode(into: buffer,using: using)
        buffer.add(.i64,.STOREP,expression.place,.integer(0),self.place)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.array.analyzeSemantics(using: analyzer)
        self.index.analyzeSemantics(using: analyzer)
        let arrayType = self.array.type
        if !arrayType.isArrayClassInstance
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The type of object indexed is invalid.")
            }
        }
    }
