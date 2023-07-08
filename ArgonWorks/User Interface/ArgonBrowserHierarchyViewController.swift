//
//  ArgonBrowserHierarchyViewController.swift
//  ArgonBrowserHierarchyViewController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa

class ArgonBrowserHierarchyViewController: NSViewController,NSOutlineViewDelegate,NSOutlineViewDataSource
    {
    @IBOutlet var header1: HeaderView!
    @IBOutlet var header2: HeaderView!
    @IBOutlet var header3: HeaderView!
    @IBOutlet var classBrowser: NSOutlineView!
    @IBOutlet var methodBrowser: NSOutlineView!
    @IBOutlet var objectBrowser: NSOutlineView!
    
    private var symbolList1: SymbolList?
    private var symbolList2: SymbolList?
    private var symbolList3: SymbolList?
    
    @IBOutlet var splitView: NSSplitView!
    
    public override func viewDidLoad()
        {
        super.viewDidLoad()
        self.header1.text = "Classes"
        self.header1.textColor = Palette.shared.headerTextColor
        self.header1.headerColor = Palette.shared.headerColor
        self.symbolList1 = SymbolList()
        self.symbolList1!.childType = .class
        self.symbolList1!.foregroundColor = Palette.shared.argonPrimaryColor
        self.classBrowser.delegate = self.symbolList1
        self.classBrowser.dataSource = self.symbolList1
        self.symbolList1!.outliner = self.classBrowser
//        self.symbolList1!.symbols = [TopModule.shared.argonModule.object]
        self.header2.text = "Methods"
        self.header2.textColor = Palette.shared.headerTextColor
        self.header2.headerColor = Palette.shared.headerColor
        self.symbolList2 = SymbolList()
        self.symbolList2!.childType = .method
        self.symbolList2!.foregroundColor = Palette.shared.argonPrimaryColor
        self.methodBrowser.delegate = self.symbolList2
        self.methodBrowser.dataSource = self.symbolList2
        self.symbolList2!.outliner = self.methodBrowser
//        self.symbolList2!.symbols = [TopModule.shared]
        self.header3.text = "Objects"
        self.header3.textColor = Palette.shared.headerTextColor
        self.header3.headerColor = Palette.shared.headerColor
        self.symbolList3 = SymbolList()
        self.symbolList3!.childType = .any
        self.symbolList3!.foregroundColor = Palette.shared.argonPrimaryColor
        self.objectBrowser.delegate = self.symbolList3
        self.objectBrowser.dataSource = self.symbolList3
        self.symbolList3!.outliner = self.objectBrowser
//        self.symbolList3!.symbols = [TopModule.shared.moduleRoot]
        }
        
    public override func viewDidAppear()
        {
        let height = self.view.window!.frame.height / 3.0
        self.splitView.setPosition(height, ofDividerAt: 0)
        self.splitView.setPosition(2 * height, ofDividerAt: 1)
        }
    }

public class SymbolList:NSObject,NSOutlineViewDelegate,NSOutlineViewDataSource
    {
    public var symbols: Symbols = []
        {
        didSet
            {
            self.outliner?.reloadData()
            self.outliner?.indentationPerLevel = 200
            self.outliner?.rowHeight = 40
            self.outliner?.intercellSpacing = NSSize(width: 20,height: 20)
            }
        }
        
    public var childType: ChildType = .class
    public var foregroundColor: NSColor = .white
    public var outliner: NSOutlineView?
        {
        didSet
            {
            let nib = NSNib(nibNamed: "HierarchyCell", bundle: nil)
            self.outliner?.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCell"))
            self.outliner?.indentationPerLevel = 200
            self.outliner?.rowHeight = 40
            self.outliner?.intercellSpacing = NSSize(width: 20,height: 20)
            self.outliner?.reloadData()
            }
        }
  
    
    @objc public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item == nil
            {
            return(self.symbols.count)
            }
        else
            {
            let symbol = item as! Symbol
            return(symbol.childCount(forChildType: self.childType))
            }
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.symbols[index])
            }
        else if let symbol = item as? Symbol
            {
            return(symbol.child(forChildType: self.childType,atIndex: index))
            }
        fatalError()
        }

    @objc public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        let symbol = item as! Symbol
        return(symbol.isExpandable(forChildType: self.childType))
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView?
        {
        let row = HierarchyRowView(selectionColor: Palette.shared.hierarchySelectionColor)
        return(row)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat
        {
        return(24)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
        {
        guard outliner.isNotNil else
            {
            return(false)
            }
        let selectedRow = outliner!.selectedRow
        if selectedRow >= 0,let cell = outliner?.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? HierarchyCellView
            {
            cell.revert()
            }
        return(true)
        }

    public func outlineViewSelectionDidChange(_ notification: Notification)
        {
        guard outliner.isNotNil else
            {
            return
            }
        let row = outliner!.selectedRow
        if row >= 0,let cell = outliner!.view(atColumn: 0, row: row, makeIfNecessary: false) as? HierarchyCellView
            {
            cell.invert()
            }
        }
        
        
    public func outlineView(_ outlineView: NSOutlineView,viewFor tableColumn: NSTableColumn?,item: Any) -> NSView?
        {
        let symbol = item as! Symbol
        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCell"), owner: nil) as! HierarchyCellView
        view.symbol = symbol
        symbol.configure(cell: view,foregroundColor: self.foregroundColor)
        return(view)
        }
    }
