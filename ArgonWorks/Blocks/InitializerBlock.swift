//
//  InitializerBlock.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 2/10/21.
//

import Foundation

public class InitializerBlock: Block,Scope
    {
    private let initializer: Initializer
    
    public init(initializer: Initializer)
        {
        self.initializer = initializer
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.initializer = coder.decodeObject(forKey: "initializer") as! Initializer
        super.init(coder: coder)
        }
        
    public required init()
        {
        self.initializer = Initializer(label: "")
        super.init()
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.initializer,forKey: "initializer")
        super.encode(with: coder)
        }
    }
