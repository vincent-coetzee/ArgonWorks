//
//  ImportedClassPlaceholder.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/10/21.
//

import Foundation

public class ImportedSymbolPlaceholder: NSObject, NSCoding
    {
    private let originalName: Name
    private let originalImportPath: String
    
    init(original: Symbol)
        {
        self.originalName = original.fullName
        self.originalImportPath = original.loader!.canonicalPath
        super.init()
        }
        
    public required init(coder: NSCoder)
        {
        self.originalName = Name(coder: coder,forKey: "originalName")
        self.originalImportPath = coder.decodeString(forKey: "originalImportPath")!
        super.init()
        }
        
    public func encode(with coder:NSCoder)
        {
        self.originalName.encode(with: coder,forKey: "originalName")
        coder.encode(self.originalImportPath,forKey: "originalImportPath")
        }
        
    public override func awakeAfter(using coder: NSCoder) -> Any?
        {
        if let importer = coder as? ImportUnarchiver
            {
            if let object = importer.topModule.lookup(name: self.originalName)
                {
                return(object)
                }
            importer.noteMissingSymbol(named: self.originalName, path: self.originalImportPath)
            }
        return(self)
        }
    }
