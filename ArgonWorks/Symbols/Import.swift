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
        
    public override func lookup(label: Label) -> Symbol?
        {
        if let symbol = self.symbolsByLabel[label]
            {
            return(symbol)
            }
        return(self.parent.lookup(label: label))
        }
    }
