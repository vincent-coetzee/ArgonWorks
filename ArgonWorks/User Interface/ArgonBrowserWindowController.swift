//
//  ArgonBrowserWindowController.swift
//  ArgonBrowserWindowController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa

class ArgonBrowserWindowController: NSWindowController
    {
    private var symbols: Array<Symbol> = []
    private let small = VirtualMachine(small: true)
    
    public var outliner: NSOutlineView!
        {
        didSet
            {
            self.initOutliner()
            }
        }
        
    public var sourceEditor: LineNumberTextView!
        {
        didSet
            {
            self.initSourceEditor()
            }
        }
        
    public var inspectorController: ArgonBrowserInspectorViewController!
        {
        didSet
            {
            self.initInspector()
            }
        }
    
    override func windowDidLoad()
        {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        }
        
    private func initOutliner()
        {
        self.symbols = [small.argonModule]
        self.outliner.dataSource = self
        self.outliner.delegate = self
        self.outliner.reloadData()
        }
        
    private func initSourceEditor()
        {
        }
        
    private func initInspector()
        {
        }
    }

extension ArgonBrowserWindowController: NSOutlineViewDataSource
    {
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item == nil
            {
            return(self.symbols.count)
            }
        else
            {
            let symbol = item as! Symbol
            return(symbol.childCount)
            }
        }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.symbols[index])
            }
        else if let symbol = item as? Symbol
            {
            return(symbol.child(atIndex: index))
            }
        fatalError()
        }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        let symbol = item as! Symbol
        return(symbol.isExpandable)
        }
    }

extension ArgonBrowserWindowController:NSOutlineViewDelegate
    {
    public func outlineViewSelectionDidChange(_ notification: Notification)
        {
        }
        
    public func outlineView(_ outlineView: NSOutlineView,viewFor tableColumn: NSTableColumn?,item: Any) -> NSView?
        {
        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCell"), owner: nil) as! NSTableCellView
        let anItem = item as! Symbol
        view.textField?.stringValue = anItem.label
        view.imageView?.image = NSImage(named: anItem.imageName)!
        return(view)
        }
        
//    public func outlineView(_ outlineView: NSOutlineView,rowViewForItem anItem: Any) -> NSTableRowView?
//        {
//        let view = RowView(selectionColor: ArgonPalette.shared.kModuleColor)
//        return(view)
//        }
    }


