//
//  ProjectImportItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/4/22.
//

import Cocoa

public class ProjectImportItem: ProjectItem
    {
    public override var label: Label
        {
        didSet
            {
            self.path = self.label
            }
        }
        
    private var path: String = NSHomeDirectory() + "/SomeModule.armod"
    
    private var importedModule: Module?
    
    public override init(label: Label)
        {
        super.init(label: label)
        self.label = self.path
        self.icon = NSImage(named: "IconImport")!
        self.iconTintIdentifier = .importColor
        }
        
    public required init?(coder: NSCoder)
        {
        self.path = coder.decodeString(forKey: "path")!
        self.importedModule = coder.decodeObject(forKey: "importedModule") as? Module
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.path,forKey: "path")
        coder.encode(self.importedModule,forKey: "importedModule")
        super.encode(with: coder)
        }
    }
