//
//  AsExpression.swift
//  AsExpression
//
//  Created by Vincent Coetzee on 19/8/21.
//

import Foundation

public class AsExpression: Expression
    {
    public override var type: Type
        {
        return(into)
        }
        
    private let lhs: Expression
    private let into: Type
    
    public required init?(coder: NSCoder)
        {
        self.lhs = coder.decodeObject(forKey: "lhs") as! Expression
        self.into = coder.decodeType(forKey: "into")!
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.lhs,forKey: "lhs")
        coder.encodeType(self.into,forKey: "into")
        }
        
    init(_ lhs:Expression,into: Type)
        {
        self.lhs = lhs
        self.into = into
        super.init()
        }
        
 
        
    public override var displayString: String
        {
        return("\(self.lhs.displayString) as \(self.into.displayString)")
        }

    public override func realize(using realizer:Realizer)
        {
        self.lhs.realize(using: realizer)
        self.into.realize(using: realizer)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.lhs.analyzeSemantics(using: analyzer)
//        self.into.analyzeSemantics(using: analyzer)
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        print("AsExpression NEEDS TO GENERATE CODE")
        }
    }
