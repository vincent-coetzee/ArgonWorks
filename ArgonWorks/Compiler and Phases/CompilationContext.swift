//
//  CompilationContext.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 24/3/22.
//

import Foundation

public class CompilationContext: Module
    {
    public override var enclosingModule: Module
        {
        self.module
        }
        
    public init(module: Module)
        {
        super.init(label: "")
        self.setModule(module)
        }
        
    public required init(label: Label)
        {
        fatalError("Not implemented.")
        }
        
    public required init?(coder: NSCoder)
        {
        fatalError("Not implemented.")
        }
    }
