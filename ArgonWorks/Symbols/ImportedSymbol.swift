//
//  ImportedSymbol.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 13/7/21.
//

import Foundation

public class ImportedSymbol<Base>: Symbol
    {
    private let baseSymbol:Base
    
    init(base:Base)
        {
        self.baseSymbol = base
        super.init(label:Argon.nextName("_IMPORT"))
        }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
