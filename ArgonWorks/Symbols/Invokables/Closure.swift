//
//  Closure.swift
//  Closure
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class Closure:Symbol
    {
    public let block: Block
    
    override init(label:Label)
        {
        self.block = Block()
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
