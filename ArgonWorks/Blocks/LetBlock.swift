//
//  LetBlock.swift
//  LetBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class LetBlock: Block
    {
    private let lhs:Expression
    private let rhs:Expression
    private let location:Location
    
    public init(location:Location,lhs:Expression,rhs:Expression)
        {
        self.location = location
        self.lhs = lhs
        self.rhs = rhs
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.location = coder.decodeLocation(forKey: "location")
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        self.rhs = coder.decodeObject(forKey: "rhs") as! Expression
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encodeLocation(self.location,forKey: "location")
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.lhs,forKey: "rhs")
        super.encode(with: coder)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        let valueType = self.rhs.type
//        if !valueType.isSubtype(of: slotType)
//            {
//            analyzer.compiler.reportingContext.dispatchError(at: self.location, message: "An instance of class \(valueType) can not be assigned to an instance of \(slotType).")
//            }
        }
        
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        try self.lhs.emitCode(into: buffer, using: generator)
        try self.rhs.emitCode(into: buffer, using: generator)
        
//        let place = self.value.place
//        buffer.append(.STORE,place,.none,self.slot.addresses.mostEfficientAddress.operand)
        }
    }
