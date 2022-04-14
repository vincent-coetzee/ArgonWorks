//
//  ProjectModuleItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 31/3/22.
//

import Cocoa

public class ProjectModuleItem: ProjectGroupItem
    {
    public override var controller: ArgonBrowserViewController!
        {
        didSet
            {
            self.module.type = self.controller.argonModule.moduleType
            }
        }
        
    public override var module: Module
        {
        self._module
        }
        
    private let _module: Module
    
    public override init(label: Label)
        {
        self._module = Module(label: label)
        super.init(label: label)
        self.icon = NSImage(named: "IconModule")!
        self.iconTintIdentifier = .moduleColor
        }
        
    public required init?(coder: NSCoder)
        {
        self._module = coder.decodeObject(forKey: "module") as! Module
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self._module,forKey: "module")
        super.encode(with: coder)
        }
        
    public override func labelChanged(to label: Label)
        {
        self.label = label
        self._module.setLabel(label)
        }
    }
