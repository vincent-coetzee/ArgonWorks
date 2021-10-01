//
//  LetBlock.swift
//  LetBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class LetBlock: Block
    {
    private enum CodingKeys: String, CodingKey
        {
        case name
        case value
        case location
        case slot
        }
    
    private let name: Name
    private let value:Expression
    private let location:Location
    private var namingContext: NamingContext?
    private let slot: Slot
    
    public init(name:Name,slot:Slot,location:Location,namingContext: NamingContext,value:Expression)
        {
        self.slot = slot
        self.name = name
        self.value = value
        if Swift.type(of: self.value) == Expression.self
            {
            print("halt")
            }
        self.location = location
        self.namingContext = namingContext
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        fatalError()
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        let valueType = self.value.resultType
        let slotType = slot.type
        if !valueType.isSubtype(of: slotType)
            {
            analyzer.compiler.reportingContext.dispatchError(at: self.location, message: "An instance of class \(valueType) can not be assigned to an instance of \(slotType).")
            }
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.value.emitCode(into: buffer, using: generator)
        let place = self.value.place
        buffer.append(.STORE,place,.none,self.slot.addresses.mostEfficientAddress.operand)
        }
    }
