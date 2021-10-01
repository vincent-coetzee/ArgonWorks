//
//  ForBlock.swift
//  ForBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ForBlock: Block
    {
    public let name:String
    
    init(name:String)
        {
        self.name = name
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        fatalError()
        }
        
 
    }
