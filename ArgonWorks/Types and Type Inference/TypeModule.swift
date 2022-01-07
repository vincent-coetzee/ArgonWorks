//
//  TypeModule.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/1/22.
//

import Foundation

public class TypeModule: Type
    {
    init(module: Module)
        {
        super.init(label: module.label)
        self.module = module
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        required init(label: Label) {
            fatalError("init(label:) has not been implemented")
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        if let symbol = self.module.lookup(label: label)
            {
            return(symbol)
            }
        return(self.container.lookup(label: label))
        }
    }
