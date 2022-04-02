//
//  Project.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 7/3/22.
//

import Cocoa

public class Project: ProjectGroupItem,Dependent
    {
    public var allSourceRecords: SourceRecords
        {
        self.allItems.compactMap{$0 as? ProjectSourceItem}.map{$0.sourceRecord}
        }
        
    public var allIssues: CompilerIssues
        {
        self.allSourceRecords.reduce([],{$0 + $1.issues})
        }

    public override var isProject: Bool
        {
        true
        }
        
    public override var module: Module
        {
        self._module
        }
        
    public enum TargetType: Int
        {
        case module
        case carton
        case none
        }
        
    public var nextItemKey: Int
        {
        let key = self._nextItemKey
        self._nextItemKey += 1
        return(key)
        }
        
    public var targetType: TargetType = .none
    public var hasBeenSavedOnce = false
    public var url: URL?
    public var _nextItemKey = 1001
    public var _module: Module
    
    public override init(label: Label)
        {
        self.targetType = .none
        self._module = Module(label: label)
        TopModule.shared.addSymbol(self._module)
        super.init(label: label)
        self.icon = NSImage(named: "IconProject")!
        self.icon.isTemplate = true
        self.iconTintIdentifier = .projectColor
        self.itemKey = 1000
        }
        
    public required init?(coder: NSCoder)
        {
        self.targetType = TargetType(rawValue: coder.decodeInteger(forKey: "targetType"))!
        self.hasBeenSavedOnce = coder.decodeBool(forKey: "hasBeenSavedOnce")
        self.url = coder.decodeObject(forKey: "url") as? URL
        self._module = coder.decodeObject(forKey: "module") as! Module
        self._nextItemKey = coder.decodeInteger(forKey: "nextItemKey")
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.targetType.rawValue,forKey: "targetType")
        coder.encode(self.hasBeenSavedOnce,forKey: "hasBeenSavedOnce")
        coder.encode(self.url,forKey: "url")
        coder.encode(self._module,forKey: "module")
        coder.encode(self._nextItemKey,forKey: "nextItemKey")
        super.encode(with: coder)
        }
        
    public override func initValidActions() -> BrowserActionSet
        {
        var set = super.initValidActions()
        set.remove(.deleteItemAction)
        return(set)
        }
        
    public func update(aspect: String, with: Any?, from: Model)
        {
        print("halt")
        }
    
    public override func labelChanged(to aLabel: Label)
        {
        self.label = aLabel
        self._module.setLabel(aLabel)
        self.changed(aspect: "label",with: self.label,from: self)
        }
        
    public func changeHeight(inOutliner outliner: NSOutlineView)
        {
        let someItems = self.allItems
        var indexSet = IndexSet()
        for anItem in someItems
            {
            let index = outliner.row(forItem: anItem)
            if index != -1
                {
                indexSet.insert(index)
                }
            }
        outliner.noteHeightOfRows(withIndexesChanged: indexSet)
        }
        
    public override func value(forAspect aspect: String) -> Any?
        {
        if aspect == "warningCount"
            {
            return(self.allIssues.filter{$0.isWarning}.count)
            }
        else if aspect == "errorCount"
            {
            return(self.allIssues.filter{!$0.isWarning}.count)
            }
        else if aspect == "label"
            {
            return(self.label)
            }
        else if aspect == "itemCount"
            {
            return(self.itemCount)
            }
        return(super.value(forAspect: aspect))
        }
        
    public override func updateMenu(_ menu: NSMenu,forTarget: ArgonBrowserViewController)
        {
        menu.addItem(withTitle: "Module", action: #selector(ArgonBrowserViewController.onModuleClicked), keyEquivalent: "").target = forTarget
        menu.addItem(withTitle: "Carton", action: #selector(ArgonBrowserViewController.onCartonClicked), keyEquivalent: "").target = forTarget
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "New Symbol", action: #selector(ArgonBrowserViewController.onNewSymbolClicked), keyEquivalent: "").target = forTarget
        menu.addItem(withTitle: "New Module", action: #selector(ArgonBrowserViewController.onNewModuleClicked), keyEquivalent: "").target = forTarget
        menu.addItem(withTitle: "New Group", action: #selector(ArgonBrowserViewController.onNewGroupClicked), keyEquivalent: "").target = forTarget
        }
    }
