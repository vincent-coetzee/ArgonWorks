//
//  PrimitiveBlock.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/10/21.
//

import Foundation

public class PrimitiveBlock: Block
    {
    private let primitiveName: String
    
    init(primitiveName: String)
        {
        self.primitiveName = primitiveName
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.primitiveName = coder.decodeString(forKey: "primitiveName")!
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.primitiveName,forKey: "primitiveName")
        super.encode(with: coder)
        }
        
    public override func hasPrimitiveBlock() -> Bool
        {
        return(true)
        }
        
    public override func emitCode(into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        buffer.append(nil,"PRIM",.literal(.string(self.primitiveName)),.none,.none)
        }
    }
