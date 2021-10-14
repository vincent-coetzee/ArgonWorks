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
    private var symbolsByLabel: Dictionary<Label,Symbol> = [:]
    
    init(label: Label,path: String?,loadPath: Bool)
        {
        self.path = path
        super.init(label: label)
        if loadPath
            {
            self.loadImportPath()
            }
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
        
    public static func tryLoadingPath(_ path: String?,reportingContext: ReportingContext,location: Location) -> Bool
        {
        guard let filePath = path else
            {
            return(false)
            }
        let manager = FileManager.default
        var isDirectory:ObjCBool = false
        guard manager.fileExists(atPath: filePath,isDirectory: &isDirectory),!isDirectory.boolValue else
            {
            reportingContext.dispatchWarning(at: location,message: "Invalid import path.")
            return(false)
            }
        let url = URL(fileURLWithPath: filePath)
        guard let data = try? Data(contentsOf: url) else
            {
            reportingContext.dispatchWarning(at: location,message: "Invalid path, file at path can not be loaded.")
            return(false)
            }
        guard let objectFile = try? ImportUnarchiver.unarchiveTopLevelObjectWithData(data) as? ObjectFile else
            {
            reportingContext.dispatchWarning(at: location,message: "Invalid path, file at path can not be loaded as an Argon object file.")
            return(false)
            }
        guard objectFile.module.symbolsByLabel.count > 0 else
            {
            reportingContext.dispatchWarning(at: location,message: "Invalid object file at path, object file is empty.")
            return(false)
            }
        return(true)
        }
        
    public func loadImportPath()
        {
        guard let filePath = self.path else
            {
            return
            }
        let manager = FileManager.default
        var isDirectory:ObjCBool = false
        guard manager.fileExists(atPath: filePath,isDirectory: &isDirectory),!isDirectory.boolValue else
            {
            return
            }
        let url = URL(fileURLWithPath: filePath)
        guard let data = try? Data(contentsOf: url) else
            {
            return
            }
        guard let objectFile = try? ImportUnarchiver.unarchiveTopLevelObjectWithData(data) as? ObjectFile else
            {
            return
            }
        for symbol in objectFile.module.symbolsByLabel.values
            {
            if !symbol.isSystemModule
                {
                self.symbolsByLabel[symbol.label] = symbol
                }
            }
        }
        
    ///
    ///
    /// NOTE: lookup(label:) in Import must not search the parent of the
    /// Import because the parent of an Import is a Module and a Module
    /// searches all of it's Imports which would result in an infinite loop.
    ///
    ///
    public override func lookup(label: Label) -> Symbol?
        {
        if let symbol = self.symbolsByLabel[label]
            {
            return(symbol)
            }
        return(nil)
        }
        
    public override func lookup(name: Name) -> Symbol?
        {
        if name.isEmpty
            {
            return(nil)
            }
        else if name.isRooted
            {
            if name.count == 1
                {
                return(nil)
                }
            if let start = name.topModule.lookup(label: name.first)
                {
                if let symbol = start.lookup(name: name.withoutFirst)
                    {
                    return(symbol)
                    }
                }
            }
        else if name.count == 1
            {
            if let symbol = self.lookup(label: name.first)
                {
                return(symbol)
                }
            }
        else if let start = self.lookup(label: name.first)
            {
            if let symbol = start.lookup(name: name.withoutFirst)
                {
                return(symbol)
                }
            }
        return(self.parent.lookup(name: name))
        }
    }
