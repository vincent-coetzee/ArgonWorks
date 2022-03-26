//
//  ImportedClassPlaceholder.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/10/21.
//

import Foundation

public class ImportedSymbolPlaceholder: NSObject, NSCoding
    {
    private let originalName: Label
    private let originalImportPath: String
    
    init(original: Symbol)
        {
        self.originalName = original.label
        self.originalImportPath = original.loader!.canonicalPath
        super.init()
        }
        
    public required init(coder: NSCoder)
        {
        self.originalName = coder.decodeObject(forKey: "originalName") as! String
        self.originalImportPath = coder.decodeString(forKey: "originalImportPath")!
        super.init()
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.originalName,forKey: "originalName")
        coder.encode(self.originalImportPath,forKey: "originalImportPath")
        }
        
    public override func awakeAfter(using coder: NSCoder) -> Any?
        {
        if let importer = coder as? ImportUnarchiver
            {
            if let object = importer.topModule.lookup(label: self.originalName)
                {
                return(object)
                }
//            importer.noteMissingSymbol(named: self.originalName, path: self.originalImportPath)
            }
        return(self)
        }
    }
