//
//  ArrayAccessExpression.swift
//  ArrayAccessExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ArrayAccessExpression: Expression
    {
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
    
    public override func becomeLValue()
        {
        self.isLValue = true
        }
        
    public override var type: Type
        {
        if self.array.type.isUnknown
            {
            return(.unknown)
            }
        return((self.array.type.classValue as! ArrayClassInstance).elementType)
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
        
    public override func realize(using realizer:Realizer)
        {
        self.array.realize(using: realizer)
        self.index.realize(using: realizer)
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
        self._place = offset
        }
        
    public override func emitAddressCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
//        fatalError("This should have been implemented")
        }
    }
