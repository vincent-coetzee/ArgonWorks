//
//  ArgonHierarchyBrowserViewController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/9/21.
//

import Cocoa

class ArgonHierarchyBrowserViewController: NSViewController
    {
    @IBOutlet var browser: NSOutlineView!
    
    private var symbols: HierarchySymbolWrappers = []
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.browser.indentationPerLevel = 20
        self.browser.rowHeight = 16
        self.browser.intercellSpacing = NSSize(width: 0,height: 0)
        let nib = NSNib(nibNamed:"HierarchyCell",bundle: nil)
        self.browser.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCellView"))
        let classes = HierarchySymbolWrapper(groupNamed: "Classes",symbols: [TopModule.shared.argonModule.object],type: .class)
        let constants = HierarchySymbolWrapper(groupNamed: "Constants",symbols: TopModule.shared.allModules,type: .constant)
        let enums = HierarchySymbolWrapper(groupNamed: "Enumerations",symbols: TopModule.shared.allModules,type: .enumeration)
        let methods = HierarchySymbolWrapper(groupNamed: "Methods",symbols: TopModule.shared.allModules,type: .method)
        let types = HierarchySymbolWrapper(groupNamed: "Types",symbols: TopModule.shared.allModules,type: .type)
        self.symbols = [classes,constants,methods,types,enums]
        self.browser.reloadData()
        }
    
    }

extension ArgonHierarchyBrowserViewController: NSOutlineViewDelegate,NSOutlineViewDataSource
    {
    @objc public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item == nil
            {
            return(self.symbols.count)
            }
        else
            {
            let symbol = item as! HierarchySymbolWrapper
            return(symbol.children.count)
            }
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.symbols[index])
            }
        else if let symbol = item as? HierarchySymbolWrapper
            {
            return(symbol.children[index])
            }
        fatalError()
        }

    @objc public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        let symbol = item as! HierarchySymbolWrapper
        return(symbol.isExpandable)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView?
        {
        let symbol = item as! HierarchySymbolWrapper
        let row = HierarchyRowView(symbol: symbol)
        return(row)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
        {
        let selectedRow = self.browser.selectedRow
        if selectedRow >= 0,let cell = self.browser.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? HierarchyCellView
            {
            cell.revert()
            }
        return(true)
        }

    public func outlineViewSelectionDidChange(_ notification: Notification)
        {
        let row = self.browser.selectedRow
        if row >= 0,let cell = self.browser.view(atColumn: 0, row: row, makeIfNecessary: false) as? HierarchyCellView
            {
            cell.invert()
            }
        }
        
        
    public func outlineView(_ outlineView: NSOutlineView,viewFor tableColumn: NSTableColumn?,item: Any) -> NSView?
        {
        let symbol = item as! HierarchySymbolWrapper
        if tableColumn!.identifier == NSUserInterfaceItemIdentifier(rawValue: "0")
            {
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NSTableCellView"), owner: nil) as! NSTableCellView
            symbol.configure(leaderCell: view)
            return(view)
            }
        else
            {
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCellView"), owner: nil) as! HierarchyCellView
            symbol.configure(cell: view)
            return(view)
            }
        }
    }
