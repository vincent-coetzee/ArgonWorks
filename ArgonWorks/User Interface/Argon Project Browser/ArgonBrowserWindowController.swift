//
//  ArgonBrowserWindowController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/4/22.
//

import Cocoa

class ArgonBrowserWindowController: NSWindowController
    {
    private struct ToolbarItem
        {
        public var image: NSImage?
            {
            switch(self._image)
                {
                case .system(let name):
                    return(NSImage(systemSymbolName: name, accessibilityDescription: "")?.withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large)))
                case .custom(let name):
                    let anImage = NSImage(named: name)
                    anImage?.isTemplate = true
                    return(anImage?.image(withTintColor: Palette.shared.color(for: self.identifier)!))
                }
            }
            
        internal enum Image
            {
            case system(String)
            case custom(String)
            }
            
        let identifier: NSToolbarItem.Identifier
        private let _image: Image
        let label: String
        let paletteLabel: String
        let selector: Selector
        let toolTip: String?
        let actionSet: BrowserActionSet
        
        init(identifier: NSToolbarItem.Identifier,actionSet: BrowserActionSet,customImageName: String,label: String,paletteLabel: String = "",selector: Selector,toolTip: String? = nil)
            {
            self.actionSet = actionSet
            self.toolTip = toolTip
            self.identifier = identifier
            self._image = .custom(customImageName)
            self.label = label
            self.paletteLabel = paletteLabel
            self.selector = selector
            }
            
        init(identifier: NSToolbarItem.Identifier,actionSet: BrowserActionSet,systemImageName: String,label: String,paletteLabel: String = "",selector: Selector,toolTip: String? = nil)
            {
            self.actionSet = actionSet
            self.toolTip = toolTip
            self.identifier = identifier
            self._image = .system(systemImageName)
            self.label = label
            self.paletteLabel = paletteLabel
            self.selector = selector
            }
        }
        
    private static let toolbarItems: Dictionary<NSToolbarItem.Identifier,ToolbarItem> =
        {
        let items = [
        ToolbarItem(identifier: .addItem,actionSet: .newSymbolAction,customImageName: "IconAdd",label: "Symbol",selector: #selector(ArgonBrowserViewController.onNewSymbol),toolTip: "Add a new symbol record"),
        ToolbarItem(identifier: .deleteItem,actionSet: .deleteItemAction,customImageName: "IconDelete",label: "Delete",selector: #selector(ArgonBrowserViewController.onDeleteItem),toolTip: "Delete the selected record"),
        ToolbarItem(identifier: .groupItem,actionSet: .newGroupAction,customImageName: "IconGroup",label: "Group",selector: #selector(ArgonBrowserViewController.onNewGroup),toolTip: "Add a new group record"),
        ToolbarItem(identifier: .commentItem,actionSet: .newCommentAction,customImageName: "IconComment",label: "Comment",selector: #selector(ArgonBrowserViewController.onNewComment),toolTip: "Add a new comment record"),
        ToolbarItem(identifier: .moduleItem,actionSet: .newModuleAction,customImageName: "IconModule",label: "Module",selector: #selector(ArgonBrowserViewController.onNewModule),toolTip: "Add a new module record"),
        ToolbarItem(identifier: .importItem,actionSet: .newImportAction,customImageName: "IconImport",label: "Import",selector: #selector(ArgonBrowserViewController.onNewImport),toolTip: "Add a new import record"),
        ToolbarItem(identifier: .buildItem,actionSet: .buildAction,customImageName: "IconBuild",label: "Build",selector: #selector(ArgonBrowserViewController.onBuild),toolTip: "Build the project"),
        ToolbarItem(identifier: .saveItem,actionSet: .saveAction,customImageName: "IconSave",label: "Save",selector: #selector(ArgonBrowserViewController.onSave),toolTip: "Save the current project"),
        ToolbarItem(identifier: .openItem,actionSet: .loadAction,customImageName: "IconLoad",label: "Open",selector: #selector(ArgonBrowserViewController.onOpen),toolTip: "Open a project"),
        ToolbarItem(identifier: .leftSidebarItem,actionSet: .leftSidebarAction,customImageName: "IconLeftSidebar",label: "Left sidebar",selector: #selector(ArgonBrowserViewController.onToggleLeftSidebar),toolTip: "Toggle the left sidebar"),
        ToolbarItem(identifier: .rightSidebarItem,actionSet: .rightSidebarAction,customImageName: "IconRightSidebar",label: "Right sidebar",selector: #selector(ArgonBrowserViewController.onToggleRightSidebar),toolTip: "Toggle the right sidebar")
        ]
        var dict = Dictionary<NSToolbarItem.Identifier,ToolbarItem>()
        for item in items
            {
            dict[item.identifier] = item
            }
        return(dict)
        }()
        
    @IBOutlet private weak var toolbar: NSToolbar!
    private var leftSidebarController: LeftSidebarButtonController!
    
    public override func windowDidLoad()
        {
        super.windowDidLoad()
        let viewController = self.contentViewController as! ArgonBrowserViewController
        self.leftSidebarController = LeftSidebarButtonController()
        self.leftSidebarController.target = self
        self.window?.addTitlebarAccessoryViewController(self.leftSidebarController)
//        let nextController = SpaceController()
//        nextController.layoutAttribute = .left
//        self.window?.addTitlebarAccessoryViewController(nextController)
        let rightController = RightSidebarButtonController()
        rightController.target = self
        self.window?.addTitlebarAccessoryViewController(rightController)
        NotificationCenter.default.addObserver(self, selector: #selector(self.leftViewFrameDidChange), name: NSView.frameDidChangeNotification, object: viewController.leftView)
        }
        
    @objc public func leftViewFrameDidChange(_ notification: Notification)
        {
        let viewController = self.contentViewController as! ArgonBrowserViewController
        let frame = viewController.leftView.frame
        self.leftSidebarController.rightOffset = frame.maxX
        }
        
    @objc public func onToggleLeftSidebar(_ sender: Any?)
        {
        (self.contentViewController as! ArgonBrowserViewController).onToggleLeftSidebar(self)
        }
        
    @objc public func onToggleRightSidebar(_ sender: Any?)
        {
        }
    }

extension ArgonBrowserWindowController: NSToolbarDelegate
    {
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
        {
        [.warningsItem,.space,.buildItem,.space,.groupItem,.commentItem,.importItem,.moduleItem,.space,.deleteItem,.space,.openItem,.saveItem]
        }
        
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
        {
        [.addItem,.deleteItem,.groupItem,.commentItem,.importItem,.moduleItem,.openItem,.saveItem,.buildItem,.warningsItem]
        }
        
//    public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
//        {
//        [.warningsItem,.space,.buildItem,.space,.groupItem,.commentItem,.importItem,.moduleItem,.space,.deleteItem,.space,.openItem,.saveItem]
//        }
        
    public func toolbar(_ toolbar: NSToolbar,itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem?
        {
        let target = self.contentViewController as! ArgonBrowserViewController
        if let anItem = Self.toolbarItems[itemIdentifier]
            {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = anItem.image
            item.label = anItem.label
            item.paletteLabel = anItem.label
            item.isBordered = true
            item.tag = anItem.actionSet.rawValue
            item.toolTip = anItem.toolTip
            item.target = target
            item.action = anItem.selector
            return(item)
            }
        else if itemIdentifier == .warningsItem
            {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            var image = NSImage(named: "IconMarker")!
            image.isTemplate = true
            image = image.image(withTintColor: Palette.shared.color(for: .warningColor))
            let label = IconLabelView(imageValueModel: ValueHolder(value: image), imageEdge: .left, valueModel: target.warningCountValueModel)
            label.textFontIdentifier = .titlebarTextFont
            item.toolTip = "Displays the number of warnings in the project"
            item.view = label
            return(item)
            }
        return(nil)
        }
    }
