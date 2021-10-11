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
    
    init(label: Label,path: String?)
        {
        self.path = path
        super.init(label: label)
        self.tryLoadingPath()
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
        
    private func tryLoadingPath()
        {
        if let filePath = self.path
            {
            let manager = FileManager.default
            var isDirectory:ObjCBool = false
            if manager.fileExists(atPath: filePath,isDirectory: &isDirectory)
                {
                let url = URL(fileURLWithPath: filePath)
                if !isDirectory.boolValue,let data = try? Data(contentsOf: url)
                    {
                    let topModule = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! TopModule
                    for symbol in topModule.symbolsByLabel.values
                        {
                        if !symbol.isSystemModule
                            {
                            self.symbolsByLabel[symbol.label] = symbol
                            }
                        }
                    }
                }
            }
        }
    }
