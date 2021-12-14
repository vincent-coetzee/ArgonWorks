//
//  TypeModule.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/12/21.
//

import Foundation

public class TypeModule: Type
    {
    public override var displayString: String
        {
        "TypeModule(\(self.module.label))"
        }
        
    public static func ==(lhs: TypeModule,rhs: TypeModule) -> Bool
        {
        lhs.module === rhs.module
        }
        
    internal let module: Module
    
    init(module: Module)
        {
        self.module = module
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        self.module = coder.decodeObject(forKey: "module") as! Module
        super.init(coder: coder)
        }
        
    required init(label: Label)
        {
        fatalError("init(label:) has not been implemented")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.module,forKey: "module")
        super.encode(with: coder)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        if let node = self.module.lookup(label: label)
            {
            return(node)
            }
        return(super.lookup(label: label))
        }
    }
