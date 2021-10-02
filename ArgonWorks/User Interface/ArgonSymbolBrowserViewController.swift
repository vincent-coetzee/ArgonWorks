//
//  ArgonConfigurationBrowserViewController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 2/10/21.
//

import Cocoa

//public protocol CartonItem
//    {
//    var label: String { get }
//    var icon: NSImage { get }
//    }
//
//public class Carton: CartonItem
//    {
//    public var icon: NSImage
//        {
//
//        }
//    }
    
class ArgonSymbolBrowserViewController: NSViewController
    {
    @IBOutlet var outliner: NSOutlineView!
    
//    private var items: Array<CartonItem> = []
    }
//
//extension ArgonConfigurationBrowserViewController: NSOutlineViewDelegate,NSOutlineViewDataSource
//    {
//    @objc public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
//        {
//        if item == nil
//            {
//            return(self.symbols.count)
//            }
//        else
//            {
//            let symbol = item as! HierarchySymbolWrapper
//            return(symbol.children.count)
//            }
//        }
//
//    @objc public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
//        {
//        if item.isNil
//            {
//            return(self.symbols[index])
//            }
//        else if let symbol = item as? HierarchySymbolWrapper
//            {
//            return(symbol.children[index])
//            }
//        fatalError()
//        }
//
//    @objc public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
//        {
//        let symbol = item as! HierarchySymbolWrapper
//        return(symbol.isExpandable)
//        }
//
//    @objc public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView?
//        {
//        let symbol = item as! HierarchySymbolWrapper
//        let row = HierarchyRowView(symbol: symbol)
//        return(row)
//        }
//
//    @objc public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
//        {
//        let selectedRow = self.browser.selectedRow
//        if selectedRow >= 0,let cell = self.browser.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? HierarchyCellView
//            {
//            cell.revert()
//            }
//        return(true)
//        }
//
//    public func outlineViewSelectionDidChange(_ notification: Notification)
//        {
//        let row = self.browser.selectedRow
//        if row >= 0,let cell = self.browser.view(atColumn: 0, row: row, makeIfNecessary: false) as? HierarchyCellView
//            {
//            cell.invert()
//            }
//        }
//
//
//    public func outlineView(_ outlineView: NSOutlineView,viewFor tableColumn: NSTableColumn?,item: Any) -> NSView?
//        {
//        let symbol = item as! HierarchySymbolWrapper
//        if tableColumn!.identifier == NSUserInterfaceItemIdentifier(rawValue: "0")
//            {
//            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NSTableCellView"), owner: nil) as! NSTableCellView
//            symbol.configure(leaderCell: view)
//            return(view)
//            }
//        else
//            {
//            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCellView"), owner: nil) as! HierarchyCellView
//            symbol.configure(cell: view)
//            return(view)
//            }
//        }
//    }
