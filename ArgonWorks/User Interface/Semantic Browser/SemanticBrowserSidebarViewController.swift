//
//  SemanticBrowserSidebarViewController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 6/10/21.
//

import Cocoa

class SemanticBrowserSidebarViewController: NSViewController,NSToolbarDelegate
    {
    @IBOutlet var outliner: NSOutlineView!
    
    private var browserItems = Symbols()
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        let main = Module(label: "Main")
        main.addSymbol(Module(label: "Primary"))
        main.addSymbol(Module(label: "Secondary"))
        main.lookup(label: "Primary")?.addSymbol(Module(label: "Inner"))
        main.lookup(label: "Secondary")?.addSymbol(Module(label: "Color"))
        main.lookup(label: "Secondary")?.addSymbol(TypeAlias(label: "ColorSpace",type: TopModule.shared.argonModule.object.type))
        main.lookup(label: "Secondary")?.addSymbol(TypeAlias(label: "ColorConstituent",type: TopModule.shared.argonModule.float.type))
        let colorSpace = Class(label: "ColorSpace")
        let colorClass = Class(label: "Color")
        main.lookup(label: "Secondary")?.lookup(label: "Color")?.addSymbol(colorClass)
        main.lookup(label: "Secondary")?.lookup(label: "Color")?.addSymbol(colorSpace)
        main.lookup(label: "Secondary")?.lookup(label: "Color")?.addSymbol(Constant(label: "WhiteColorSpace",type: colorSpace.type,value: Expression()))
        main.lookup(label: "Secondary")?.lookup(label: "Color")?.addSymbol(Constant(label: "RGBColorSpace",type: colorSpace.type,value: Expression()))
        main.lookup(label: "Secondary")?.lookup(label: "Color")?.addSymbol(Constant(label: "HSBColorSpace",type: colorSpace.type,value: Expression()))
        colorClass.addSymbol(Slot(label: "colorSpace",type: TopModule.shared.argonModule.string.type))
        colorClass.addSubclass(Class(label: "RGBColor"))
        colorClass.addSubclass(Class(label: "HSBColor"))
        colorClass.addSubclass(Class(label: "CMYKColor"))
        self.browserItems.append(main)
        self.browserItems.append(TopModule.shared)
        self.outliner.indentationPerLevel = 30
        self.outliner.rowHeight = 20
        self.outliner.register(NSNib(nibNamed: "LeaderSemanticCellView",bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "LeaderSemanticCellView"))
        self.outliner.register(NSNib(nibNamed: "MainSemanticCellView",bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MainSemanticCellView"))
        self.outliner.selectionHighlightStyle = .regular
        self.outliner.reloadData()
        }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem?
        {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = "Item"
        let image = NSImage(named: "IconClass")
        let button = NSButton(frame: NSRect(x:0,y:0,width: 40,height: 40))
        button.title = ""
        button.image = image
        button.setButtonType(.toggle)
        button.bezelStyle = .rounded
        button.action = #selector(ArgonBrowserWindowController.doButton(_:))
        item.view = button
        return(item)
        }
    }
    
extension SemanticBrowserSidebarViewController:NSOutlineViewDelegate,NSOutlineViewDataSource
    {
    @objc public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item == nil
            {
            return(self.browserItems.count)
            }
        else
            {
            let symbol = item as! Symbol
            return(symbol.childCount)
            }
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.browserItems[index])
            }
        else if let symbol = item as? Symbol
            {
            return(symbol.child(atIndex: index))
            }
        fatalError()
        }

    @objc public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        if let symbol = item as? Symbol
            {
            return(symbol.isExpandable)
            }
        return(false)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView?
        {
        return(SemanticRowView(selectionColor: Palette.shared.hierarchySelectionColor))
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
        {
//        guard outliner.isNotNil else
//            {
//            return(false)
//            }
//        let selectedRow = outliner!.selectedRow
//        if selectedRow >= 0,let cell = outliner?.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? HierarchyCellView
//            {
//            cell.revert()
//            }
        return(true)
        }

    public func outlineViewSelectionDidChange(_ notification: Notification)
        {
//        guard outliner.isNotNil else
//            {
//            return
//            }
        let row = outliner!.selectedRow
        if row >= 0,let cell = outliner!.rowView(atRow: row, makeIfNecessary: false)
            {
            cell.isEmphasized = false
            }
        }
        
        
    public func outlineView(_ outlineView: NSOutlineView,viewFor tableColumn: NSTableColumn?,item: Any) -> NSView?
        {
        if let symbol = item as? Symbol
            {
//            if tableColumn!.identifier == NSUserInterfaceItemIdentifier(rawValue: "first")
//                {
//                let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "LeaderSemanticCellView"), owner: nil) as! LeaderSemanticCellView
//                view.labelView.stringValue = ""
//                return(view)
//                }
           if tableColumn!.identifier == NSUserInterfaceItemIdentifier(rawValue: "second")
                {
                let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MainSemanticCellView"), owner: nil) as! MainSemanticCellView
                view.textField?.stringValue = symbol.displayString
                view.imageView?.image = NSImage(named: symbol.iconName)!
                view.imageView?.image?.isTemplate = true
                view.imageView?.contentTintColor = symbol.defaultColor
                view.symbol = symbol
                return(view)
                }
            }
        return(nil)
        }
    }
