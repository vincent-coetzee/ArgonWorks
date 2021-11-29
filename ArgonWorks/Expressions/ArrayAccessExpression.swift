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
        coder.encode(self.index,forKey: "indexx")
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
        
    public override func deepCopy() -> Self
        {
        return(ArrayAccessExpression(array: self.array.deepCopy(),index: self.index.deepCopy()) as! Self)
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext) throws
        {
        try self.array.initializeTypeConstraints(inContext: context)
        try self.index.initializeTypeConstraints(inContext: context)
        context.append(TypeConstraint(left: index.type,right: context.integerType,origin: .expression(self)))
//        guard let typeClass = self.array.type as? TypeClass else
//            {
//            throw(CompilerIssue(location: self.declaration!, message: "Array access type should be an array but is not."))
//            }
//        guard typeClass.theClass.fullName.displayString == "\\\\Argon\\Array" else
//            {
//            throw(CompilerIssue(location: self.declaration!, message: "The target of an array access must be an instance of \\\\Argon\\Array and this is not."))
//            }
        context.append(TypeConstraint(left: self.type,right: self.array.type,origin: .expression(self)))
        }
        
    public override func initializeType(inContext context: TypeContext) throws
        {
        try self.array.initializeType(inContext: context)
        try self.index.initializeType(inContext: context)
        self.type = self.array.type
        }
        
    public override func becomeLValue()
        {
        self.isLValue = true
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
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type.lookup(label: label))
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        if let location = self.declaration
            {
            instance.append(lineNumber: location.lineNumber.line)
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
