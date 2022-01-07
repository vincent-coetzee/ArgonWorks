//
//  SymbolTerm.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/12/21.
//

import Foundation

public class SymbolTerm: Expression
    {
    private enum TermType
        {
        case type(Type)
        case module(Module)
        case constant(Constant)
        }
        
    private let termType: TermType
    
    init(type: Type)
        {
        self.termType = .type(type)
        super.init()
        }
        
    init(module: Module)
        {
        self.termType = .module(module)
        super.init()
        }
        
    init(constant: Constant)
        {
        self.termType = .constant(constant)
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        switch(coder.decodeInteger(forKey: "kind"))
            {
            case 1:
                self.termType = .type(coder.decodeObject(forKey: "type") as! Type)
            case 2:
                self.termType = .module(coder.decodeObject(forKey: "module") as! Module)
            case 3:
                self.termType = .constant(coder.decodeObject(forKey: "constant") as! Constant)
            default:
                fatalError()
            }
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        switch(self.termType)
            {
            case .type(let type):
                coder.encode(1,forKey: "kind")
                coder.encode(type,forKey: "type")
            case .module(let type):
                coder.encode(2,forKey: "kind")
                coder.encode(type,forKey: "module")
            case .constant(let type):
                coder.encode(3,forKey: "kind")
                coder.encode(type,forKey: "constant")
            }
        super.encode(with: coder)
        }
        
    public override func emitValueCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
        
    public override func emitPointerCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        switch(self.termType)
            {
            case .type(let type):
                fatalError()
            default:
                fatalError()
            }
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        switch(self.termType)
            {
            case .type(let type):
                self.type = type
            case .module(let module):
                self.type = TypeModule(module: module)
            default:
                fatalError()
            }
        }
        
    public override func initializeTypeConstraints(inContext context: TypeContext)
        {
        }
    }
