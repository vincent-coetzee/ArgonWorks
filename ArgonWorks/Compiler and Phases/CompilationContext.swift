//
//  CompilationContext.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 24/3/22.
//

import Foundation

public class CompilationContext: Module
    {
    public override var argonModule: ArgonModule
        {
        self._argonModule
        }
        
    public override var enclosingModule: Module
        {
        self.module
        }
        
    private let _argonModule: ArgonModule
    
    public init(module: Module,argonModule: ArgonModule)
        {
        self._argonModule = argonModule
        super.init(label: "")
        self.setModule(module)
        }
        
    public required init(label: Label)
        {
        fatalError("Not implemented.")
        }
        
    public required init?(coder: NSCoder)
        {
        self._argonModule = coder.decodeObject(forKey: "argonModule") as! ArgonModule
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self._argonModule,forKey: "argonModule")
        super.encode(with: coder)
        }
    }
