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
        
    public class func open(atPath: String) throws -> Project
        {
        var isDirectory:ObjCBool = false
        if !(FileManager.default.fileExists(atPath: atPath, isDirectory: &isDirectory) && isDirectory.boolValue)
            {
            throw(CompilerIssue(message: "The file at '\(atPath)' is not a valid project file."))
            }
        let itemsPath = (atPath as NSString).appendingPathComponent("items.bin")
        if !FileManager.default.fileExists(atPath: itemsPath)
            {
            throw(CompilerIssue(message: "The project file at '\(atPath)' is not a valid Argon project file."))
            }
        let project = NSKeyedUnarchiver.unarchiveObject(withFile: itemsPath) as! Project
        project.basePath = atPath
        return(project)
        }
        
    public var targetType: TargetType = .none
    public var hasBeenSavedOnce = false
    public var path: String?
    public var _nextItemKey = 1001
    public var basePath: String!
    public var module: Module
    
    public override init(label: Label)
        {
        self.targetType = .none
        self.module = Module(label: label)
        TopModule.shared.addSymbol(self.module)
        super.init(label: label)
        self.icon = NSImage(named: "IconProject")!
        self.icon.isTemplate = true
        self.iconTint = SyntaxColorPalette.projectColor
        self.itemKey = 1000
        }
        
    public required init?(coder: NSCoder)
        {
        self.targetType = TargetType(rawValue: coder.decodeInteger(forKey: "targetType"))!
        self.hasBeenSavedOnce = coder.decodeBool(forKey: "hasBeenSavedOnce")
        self.path = coder.decodeObject(forKey: "path") as? String
        self.module = coder.decodeObject(forKey: "module") as! Module
        self._nextItemKey = coder.decodeInteger(forKey: "nextItemKey")
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.targetType.rawValue,forKey: "targetType")
        coder.encode(self.hasBeenSavedOnce,forKey: "hasBeenSavedOnce")
        coder.encode(self.path,forKey: "path")
        coder.encode(self.module,forKey: "module")
        coder.encode(self._nextItemKey,forKey: "nextItemKey")
        super.encode(with: coder)
        }
        
    public func update(aspect: String, with: Any?, from: Model)
        {
        print("halt")
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
        
    public func updateProjectBundle(withSource source: String,forItem key: Int)
        {
        }
        
    public func save()
        {
        if self.hasBeenSavedOnce
            {
            let path = self.path!
            NSKeyedArchiver.archiveRootObject(self, toFile: path)
            return
            }
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["arpro"]
        panel.message = "Please select the name and destination for this project."
        panel.nameFieldLabel = "Enter the name of the file"
        panel.nameFieldStringValue = self.label
        if panel.runModal() == .OK
            {
            let url = panel.url!
            self.path = url.path
            self.hasBeenSavedOnce = true
            NSKeyedArchiver.archiveRootObject(self, toFile: self.path!)
            }
        }
    }
