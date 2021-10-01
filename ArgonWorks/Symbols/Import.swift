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
    
    public required init?(coder: NSCoder)
        {
        self.path = coder.decodeObject(forKey: "path") as? String
        super.init(coder: coder)
        }

    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.path,forKey: "path")
        }
        
 
    }
