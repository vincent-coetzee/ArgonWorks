//
//  ProjectItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Cocoa

public class ProjectItem: NSObject,NSCoding,AspectModel
    {
    public static let kIconHeight:CGFloat = 12
    
    public var itemCount: Int
        {
        1
        }
        
    public var allItems: ProjectItems
        {
        []
        }
        
    public var isElement: Bool
        {
        false
        }
        
    public var isGroup: Bool
        {
        false
        }
        
    public var isProject: Bool
        {
        false
        }
        
    public var isExpandable: Bool
        {
        false
        }
        
    public var childCount: Int
        {
        0
        }
        
    public var versionStateIcon: NSImage?
        {
        nil
        }
        
    public var module: Module
        {
        self.parentItem!.module
        }
        
    public var project: Project
        {
        if self.isProject
            {
            return(self as! Project)
            }
        return(self.parentItem!.project)
        }
        
    public let dependentKey = DependentSet.nextDependentKey
    public let dependents = DependentSet()
    public var label: Label
        {
        didSet
            {
            self.changed(aspect: "label",with: self.label)
            }
        }
    internal var versionState: VersionState = .added
        {
        didSet
            {
            self.changed(aspect: "versionState",with: self.versionState,from: self)
            }
        }
    public var parentItem: ProjectItem?
    internal var cellViews = Dictionary<NSUserInterfaceItemIdentifier,NSTableCellView>()
    public var controller: ArgonBrowserViewController!
    public var height: CGFloat = 0
    public var icon: NSImage!
    public var iconTint: NSColor = .white
    public var itemKey: Int = 0
    public var validActions: BrowserActionSet = []
    
    init(label: Label)
        {
        self.label = label
        self.icon = NSImage(named:"IconCircle")!
        self.icon.isTemplate = true
        super.init()
        self.validActions = self.initValidActions()
        }
        
    public func initValidActions() -> BrowserActionSet
        {
        [.deleteItemAction,.loadAction,.saveAction,.leftSidebarAction,.rightSidebarAction,.buildAction,.searchAction,.settingsAction]
        }
        
    public func setController(_ controller: ArgonBrowserViewController)
        {
        self.controller = controller
        }
        
    public required init?(coder: NSCoder)
        {
        self.label = coder.decodeObject(forKey: "label") as! String
        self.parentItem = coder.decodeObject(forKey: "parentItem") as? ProjectItem
        self.icon = coder.decodeObject(forKey: "icon") as? NSImage
        self.iconTint = coder.decodeObject(forKey: "iconTint") as! NSColor
        self.itemKey = coder.decodeInteger(forKey: "itemKey")
        super.init()
        self.validActions = self.initValidActions()
        }
        
    public func value(forAspect: String) -> Any?
        {
        if forAspect == "label"
            {
            return(self.label)
            }
        if forAspect == "versionState"
            {
            return(self.versionState)
            }
        return(nil)
        }
        
    public func markVersionState(as state: VersionState)
        {
        self.versionState = state
        }
        
    public func removeFromParent()
        {
        self.parentItem?.removeItem(self)
        }
        
    public func removeItem(_ item: ProjectItem)
        {
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.label,forKey: "label")
        coder.encode(self.parentItem,forKey: "parentItem")
        coder.encode(self.icon,forKey: "icon")
        coder.encode(self.iconTint,forKey: "iconTint")
        coder.encode(self.itemKey,forKey: "itemKey")
        }
        
    public func insertItems(_ items: Array<ProjectItem>,atIndex index:Int)
        {
        }
        
    public func doubleClicked(inOutliner: NSOutlineView)
        {
        }
        
    public func child(atIndex:Int) -> ProjectItem
        {
        fatalError()
        }
        
    public func addItem(_ item: ProjectItem)
        {
        fatalError()
        }
        
    public func index(of: ProjectItem) -> Int?
        {
        nil
        }
        
    public func itemWasAdded(to: ProjectItem)
        {
        }
        
    public func itemWillBeRemoved(from: ProjectItem)
        {
        }
        
    public func makeCellView(inOutliner outliner: NSOutlineView,forColumn columnIdentifier: NSUserInterfaceItemIdentifier) -> NSTableCellView?
        {
        if let view = self.cellViews[columnIdentifier]
            {
            return(view)
            }
        let view = self._makeCellView(inOutliner: outliner,forColumn: columnIdentifier)
        self.cellViews[columnIdentifier] = view
        return(view)
        }
        
    public func _makeCellView(inOutliner outliner: NSOutlineView,forColumn columnIdentifier: NSUserInterfaceItemIdentifier) -> NSTableCellView?
        {
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "Primary")
            {
            let view = ProjectItemView(frame: .zero)
            view.item = self
            view.font = self.controller.sourceOutlinerFont
            view.viewText.stringValue = self.label
            view.viewText.textColor = NSColor.white
            view.viewImage.image = self.icon
            view.viewImage.image!.isTemplate = true
            view.viewImage.contentTintColor = self.iconTint
            return(view)
            }
        else if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "VersionState")
            {
            let view = ProjectVersionStateView(frame: .zero)
            view.item = self
            return(view)
            }
        return(nil)
        }
        
    public func labelChanged(to string: String)
        {
        self.label = string
        }
        
    public func height(inWidth: CGFloat) -> CGFloat
        {
        let stringSize = self.measureString(self.label,withFont: self.controller.sourceOutlinerFont,inWidth: inWidth)
        let height = stringSize.height
        return(height)
        }
        
    public func measureString(_ string: String,withFont: NSFont,inWidth width:CGFloat) -> NSSize
        {
        let attributedString = NSAttributedString(string: string,attributes:[.font: withFont,.foregroundColor: NSColor.white])
        let size = NSSize(width: width,height: .infinity)
        let rect = attributedString.boundingRect(with: size, options: .usesLineFragmentOrigin)
        return(rect.size)
        }
        
    public func updateMenu(_ menu: NSMenu,forTarget: ArgonBrowserViewController)
        {
        menu.addItem(withTitle: "Delete", action: #selector(ArgonBrowserViewController.onDeleteClicked), keyEquivalent: "").target = forTarget
        }
    }

public typealias ProjectItems = Array<ProjectItem>
