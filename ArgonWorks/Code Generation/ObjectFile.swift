//
//  ObjectFile.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/9/21.
//

import Foundation

public class ObjectFile: NSObject,NSCoding
    {
    public let version: SemanticVersion
    public let date: Date
    public let module: Module
    public let filename: String
    public let root: Symbol
    
    init(filename: String,module: Module,root: Symbol,date:Date = Date(),version: SemanticVersion = SemanticVersion(major: 1, minor: 0, patch: 0))
        {
        self.module = module
        self.date = date
        self.version = version
        self.filename = filename
        self.root = root
        }
        
    public required init(coder: NSCoder)
        {
        self.version = coder.decodeObject(forKey: "version") as! SemanticVersion
        self.module = coder.decodeObject(forKey: "module") as! Module
        self.root = coder.decodeObject(forKey: "root") as! Symbol
        self.date = (coder.decodeObject(forKey: "date") as! NSDate) as Date
        self.filename = coder.decodeString(forKey: "filename")!
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(version,forKey: "version")
        coder.encode(module,forKey: "module")
        coder.encode(date as NSDate,forKey: "date")
        coder.encode(filename,forKey: "filename")
        coder.encode(root,forKey: "root")
        }
    }
