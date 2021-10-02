//
//  LetBlock.swift
//  LetBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class LetBlock: Block
    {
    private let expression:Expression
    private let location:Location
    
    public init(location:Location,expression:Expression)
        {
        self.location = location
        self.expression = expression
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.location = coder.decodeLocation(forKey: "location")
        self.expression = coder.decodeObject(forKey: "lhs") as! Expression
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encodeLocation(self.location,forKey: "location")
        coder.encode(self.expression,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        let valueType = self.expression.resultType
//        if !valueType.isSubtype(of: slotType)
//            {
//            analyzer.compiler.reportingContext.dispatchError(at: self.location, message: "An instance of class \(valueType) can not be assigned to an instance of \(slotType).")
//            }
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.expression.emitCode(into: buffer, using: generator)
//        let place = self.value.place
//        buffer.append(.STORE,place,.none,self.slot.addresses.mostEfficientAddress.operand)
        }
    }
