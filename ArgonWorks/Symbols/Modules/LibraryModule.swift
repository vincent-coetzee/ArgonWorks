//
//  LibraryModule.swift
//  LibraryModule
//
//  Created by Vincent Coetzee on 5/8/21.
//

import Foundation

public class LibraryModule: Module
    {
    public var functions: Array<Function>
        {
        let functions = self.symbols.filter{$0 is Function}.map{$0 as! Function}
        return(functions)
        }
        
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
