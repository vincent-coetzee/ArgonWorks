//
//  ProjectGroupItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Cocoa

public class ProjectGroupItem: ProjectItem
    {
    public override var itemCount: Int
        {
        var count = 1
        for item in self.items
            {
            count += item.itemCount
            }
        return(count)
        }
        
    public override var allItems: ProjectItems
        {
        var kids = ProjectItems()
        for item in self.items
            {
            kids.append(contentsOf: item.allItems)
            }
        kids.append(self)
        return(kids)
        }
        
    public override var isGroup: Bool
        {
        true
        }
        
    public override var isExpandable: Bool
        {
        true
        }
        
    public override var childCount: Int
        {
        self.items.count
        }
        
    private var items = Array<ProjectItem>()
    
    override init(label: Label)
        {
        super.init(label: label)
        self.icon = NSImage(named: "IconGroup")!
        self.icon.isTemplate = true
        self.iconTintIdentifier = .groupColor
        }
        
    public required init?(coder: NSCoder)
        {
        self.items = coder.decodeObject(forKey: "items") as! Array<ProjectItem>
        super.init(coder: coder)
        }
        
    public override func setController(_ controller: ArgonBrowserViewController)
        {
        self.controller = controller
        for item in self.items
            {
            item.setController(controller)
            }
        }
        
    public override func index(of item: ProjectItem) -> Int?
        {
        return(self.items.firstIndex(of: item))
        }
        
    public override func initValidActions() -> BrowserActionSet
        {
        var set = super.initValidActions()
        set.insert([.newSymbolAction,.newModuleAction,.newGroupAction,.newCommentAction])
        return(set)
        }
        
    public override func addItem(_ item: ProjectItem)
        {
        self.items.append(item)
        item.parentItem = self
        item.itemKey = item.project.nextItemKey
        item.itemWasAdded(to: self)
        self.project.changed(aspect: "itemCount",with: self.project.itemCount,from: self.project)
        self.markVersionState(as: .modified)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.items,forKey: "items")
        super.encode(with: coder)
        }
        
    public override func markVersionState(as state: VersionState)
        {
        self.versionState = state
        self.parentItem?.markVersionState(as: .modified)
        }
        
    public override func child(atIndex:Int) -> ProjectItem
        {
        self.items[atIndex]
        }
        
    public override func removeItem(_ item: ProjectItem)
        {
        if let index = self.items.firstIndex(of: item)
            {
            item.itemWillBeRemoved(from: self)
            self.items.remove(at: index)
            }
        self.project.changed(aspect: "itemCount",with: self.project.itemCount,from: self.project)
        self.markVersionState(as: .modified)
        }
        
    public override func insertItems(_ items: Array<ProjectItem>,atIndex index:Int)
        {
        if index == -1
            {
            self.items.insert(contentsOf: items,at: 0)
            }
        else
            {
            let newIndex = index >= self.items.count ? self.items.count : index
            self.items.insert(contentsOf: items,at: newIndex)
            }
        }
        
    public override func updateMenu(_ menu: NSMenu,forTarget: ArgonBrowserViewController)
        {
        menu.addItem(withTitle: "New Symbol", action: #selector(ArgonBrowserViewController.onNewSymbolClicked), keyEquivalent: "").target = forTarget
        menu.addItem(withTitle: "New Group", action: #selector(ArgonBrowserViewController.onNewGroupClicked), keyEquivalent: "").target = forTarget
        }
    }
