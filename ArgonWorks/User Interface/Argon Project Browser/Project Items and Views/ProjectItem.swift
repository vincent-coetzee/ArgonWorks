//
//  ProjectItem.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 8/3/22.
//

import Cocoa

public struct WeakTableCellView
    {
    public weak var tableCellView: NSTableCellView?
    }
    
public class ProjectItem: NSObject,NSCoding,AspectModel
    {
    public static let kIconHeight:CGFloat = 12
    
    public var pathToProject: Array<ProjectItem>
        {
        [self] + (self.parentItem?.pathToProject ?? [])
        }
        
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
    public unowned var parentItem: ProjectItem?
    internal var cellViews = Dictionary<NSUserInterfaceItemIdentifier,WeakTableCellView>()
    public var controller: ArgonBrowserViewController!
    public var height: CGFloat = 0
    public var icon: NSImage!
    public var iconTintIdentifier: StyleColorIdentifier = .defaultColor
    public var textColorIdentifier: StyleColorIdentifier = .recordTextColor
    public var backgroundColorIdentifier: StyleColorIdentifier = .recordBackgroundColor
    public var fontIdentifier: StyleFontIdentifier = .recordTextFont
    public var itemKey: Int = 0
    public var validActions: BrowserActionSet = []
    public var isExpanded = false
        {
        didSet
            {
            self.updateViews()
            }
        }
    
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
        self.iconTintIdentifier = StyleColorIdentifier(rawValue: coder.decodeString(forKey: "iconTint")!)!
        self.textColorIdentifier = StyleColorIdentifier(rawValue: coder.decodeString(forKey: "textColor")!)!
        self.backgroundColorIdentifier = StyleColorIdentifier(rawValue: coder.decodeString(forKey: "backgroundColor")!)!
        self.fontIdentifier = StyleFontIdentifier(rawValue: coder.decodeString(forKey: "font")!)!
        self.itemKey = coder.decodeInteger(forKey: "itemKey")
        self.isExpanded = coder.decodeBool(forKey: "isExpanded")
        super.init()
        self.validActions = self.initValidActions()
        }
        
    private func updateViews()
        {
        if !self.isExpanded
            {
            self.height = 0
            }
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
        
    public func item(atItemKey: Int) -> ProjectItem?
        {
        if self.itemKey == atItemKey
            {
            return(self)
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
        
    public func expandIfNeeded(inOutliner: NSOutlineView)
        {
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.label,forKey: "label")
        coder.encode(self.parentItem,forKey: "parentItem")
        coder.encode(self.icon,forKey: "icon")
        coder.encode(self.iconTintIdentifier.rawValue,forKey: "iconTint")
        coder.encode(self.textColorIdentifier.rawValue,forKey: "textColor")
        coder.encode(self.backgroundColorIdentifier.rawValue,forKey: "backgroundColor")
        coder.encode(self.fontIdentifier.rawValue,forKey: "font")
        coder.encode(self.itemKey,forKey: "itemKey")
        coder.encode(self.isExpanded,forKey: "isExpanded")
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
        if let view = self.cellViews[columnIdentifier]?.tableCellView
            {
            return(view)
            }
        let view = self._makeCellView(inOutliner: outliner,forColumn: columnIdentifier)
        self.cellViews[columnIdentifier] = WeakTableCellView(tableCellView: view)
        return(view)
        }
        
    public func _makeCellView(inOutliner outliner: NSOutlineView,forColumn columnIdentifier: NSUserInterfaceItemIdentifier) -> NSTableCellView?
        {
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "Primary")
            {
            let view = ProjectItemCellView(frame: .zero)
            view.item = self
            view.font = Palette.shared.font(for: self.fontIdentifier)
            view.viewText.stringValue = self.label
            view.viewText.textColor = Palette.shared.color(for: self.textColorIdentifier)
            view.viewImage.image = self.icon
            view.viewImage.image!.isTemplate = true
            view.viewImage.contentTintColor = Palette.shared.color(for: self.iconTintIdentifier)
            return(view)
            }
        else if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "VersionState")
            {
            let view = ProjectVersionStateCellView(frame: .zero)
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
        let stringSize = self.measureString(self.label,withFont: Palette.shared.font(for: self.fontIdentifier),inWidth: inWidth)
        let height = max(stringSize.height,Palette.shared.float(for: .recordIconHeight))
        return(height)
        }
        
    public func measureString(_ string: String,withFont: NSFont,inWidth width:CGFloat) -> NSSize
        {
        let attributedString = NSAttributedString(string: string,attributes:[.font: withFont,.foregroundColor: Palette.shared.color(for: self.textColorIdentifier)])
        let size = NSSize(width: width,height: .infinity)
        let rect = attributedString.boundingRect(with: size, options: .usesLineFragmentOrigin)
        return(rect.size)
        }
        
    public func updateMenu(_ menu: NSMenu,forTarget: ArgonBrowserViewController)
        {
        self.validActions.adjustBrowserActionMenu(menu)
        for item in menu.items
            {
            item.target = forTarget
            }
        }
    }

public typealias ProjectItems = Array<ProjectItem>
