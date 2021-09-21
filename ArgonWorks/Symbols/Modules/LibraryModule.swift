//
//  LibraryModule.swift
//  LibraryModule
//
//  Created by Vincent Coetzee on 5/8/21.
//

import Foundation

public class LibraryModule: Module
    {
    public override var typeCode:TypeCode
        {
        .libraryModule
        }
        
    private var path: String?
    
    init(label:Label,path:String)
        {
        self.path = path
        super.init(label: label)
        }
        
    public required init?(coder: NSCoder)
        {
        self.path = coder.decodeString(forKey: "path")!
        super.init(coder: coder)
        }
    }
