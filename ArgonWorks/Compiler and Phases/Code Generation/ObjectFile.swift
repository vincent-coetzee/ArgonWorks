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
    
    public static func write(module: Module,topModule: TopModule,atPath: String) throws
        {
        let objectFile = ObjectFile(filename: atPath,module: module,root: topModule,date: Date())
        if let url = URL(string: atPath)
            {
            ImportArchiver.isSwappingSystemTypes = true
            let data = try ImportArchiver.archivedData(withRootObject: objectFile, requiringSecureCoding: false)
            try data.write(to: url)
            }
        }
        
    public static func read(atPath: String,topModule: TopModule) throws -> ObjectFile?
        {
        if let url = URL(string: atPath)
            {
            let data = try Data(contentsOf: url)
            ImportUnarchiver.topModule = topModule
            let result = try ImportUnarchiver.unarchiveTopLevelObjectWithData(data)
            if let objectFile = result as? ObjectFile
                {
                return(objectFile)
                }
            throw(CompilerIssue(location: .zero, message: "Expected an ObjectFile but did not find one."))
            }
        throw(CompilerIssue(location: .zero,message: "The path '\(atPath)' can not be accessed."))
        }
        
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
