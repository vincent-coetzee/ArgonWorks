//
//  ModuleImport.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Import:Symbol
    {
    private let path: String?
    
    init(label: Label,path: String?)
        {
        self.path = path
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
