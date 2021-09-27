//
//  ArgonBrowserHierarchyViewController.swift
//  ArgonBrowserHierarchyViewController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa

class ArgonBrowserHierarchyViewController: NSViewController,NSOutlineViewDelegate,NSOutlineViewDataSource
    {
    @IBOutlet var outliner: NSOutlineView!
    @IBOutlet var scrollView: NSScrollView!
    
    private var header1: HeaderView!
    private var header2: HeaderView!
    private var header3: HeaderView!
    private var scroller1: NSScrollView!
    private var scroller2: NSScrollView!
    private var scroller3: NSScrollView!
    private var classBrowser: NSOutlineView!
    private var methodBrowser: NSOutlineView!
    private var objectBrowser: NSOutlineView!
    
    private var symbolList1: SymbolList?
    private var symbolList2: SymbolList?
    private var symbolList3: SymbolList?
    
    public override func viewDidLoad()
        {
        super.viewDidLoad()
        self.header1 = HeaderView(frame: .zero)
        self.header1.text = "Classes"
        self.header1.textColor = .argonLightWhite
        self.header1.headerColor = .argonLightBlack
        self.view.addSubview(self.header1)
        self.header1.translatesAutoresizingMaskIntoConstraints = false
        self.header1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header1.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.header1.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header1.bottomAnchor.constraint(equalTo: self.view.topAnchor,constant:30).isActive = true
        self.scroller1 = (self.scrollView.copyView() as! NSScrollView)
        self.scroller2 = (self.scrollView.copyView() as! NSScrollView)
        self.scroller3 = (self.scrollView.copyView() as! NSScrollView)
        self.classBrowser = (self.scroller1.documentView as! NSOutlineView)
        self.classBrowser.indentationPerLevel = 20
        self.classBrowser.rowHeight = 16
        self.classBrowser.intercellSpacing = NSSize(width: 0,height: 0)
        self.view.addSubview(self.scroller1)
        self.symbolList1 = SymbolList()
        self.symbolList1!.childType = .class
        self.symbolList1!.foregroundColor = NSColor.controlAccentColor
        self.classBrowser.delegate = self.symbolList1
        self.classBrowser.dataSource = self.symbolList1
        self.symbolList1!.outliner = self.classBrowser
        self.symbolList1!.symbols = [TopModule.shared.argonModule.object]
        self.scroller1.translatesAutoresizingMaskIntoConstraints = false
        self.scroller1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scroller1.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.scroller1.topAnchor.constraint(equalTo: self.header1.bottomAnchor).isActive = true
        let constraint = NSLayoutConstraint(item: self.scroller1!, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.33333,constant: -30)
        NSLayoutConstraint.activate([constraint])
        self.view.addConstraint(constraint)
        self.header2 = HeaderView(frame: .zero)
        self.header2.text = "Methods"
        self.header2.textColor = .argonLightWhite
        self.header2.headerColor = .argonLightBlack
        self.view.addSubview(self.header2)
        self.header2.translatesAutoresizingMaskIntoConstraints = false
        self.header2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header2.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.header2.topAnchor.constraint(equalTo: self.scroller1.bottomAnchor).isActive = true
        self.header2.bottomAnchor.constraint(equalTo: self.header2.topAnchor,constant:30).isActive = true
        self.methodBrowser = (self.scroller2.documentView as! NSOutlineView)
        self.methodBrowser.indentationPerLevel = 20
        self.methodBrowser.rowHeight = 16
        self.methodBrowser.intercellSpacing = NSSize(width: 0,height: 0)
        self.view.addSubview(self.scroller2)
        self.symbolList2 = SymbolList()
        self.symbolList2!.childType = .method
        self.symbolList2!.foregroundColor = NSColor.argonZomp
        self.methodBrowser.delegate = self.symbolList2
        self.methodBrowser.dataSource = self.symbolList2
        self.symbolList2!.outliner = self.methodBrowser
        self.symbolList2!.symbols = [TopModule.shared]
        self.scroller2.translatesAutoresizingMaskIntoConstraints = false
        self.scroller2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scroller2.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.scroller2.topAnchor.constraint(equalTo: self.header2.bottomAnchor).isActive = true
        let constraint1 = NSLayoutConstraint(item: self.scroller2!, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.33333,constant: -30)
        NSLayoutConstraint.activate([constraint1])
        self.view.addConstraint(constraint1)
        self.header3 = HeaderView(frame: .zero)
        self.header3.text = "Objects"
        self.header3.textColor = .argonLightWhite
        self.header3.headerColor = .argonLightBlack
        self.view.addSubview(self.header3)
        self.header3.translatesAutoresizingMaskIntoConstraints = false
        self.header3.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header3.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.header3.topAnchor.constraint(equalTo: self.scroller2.bottomAnchor).isActive = true
        self.header3.bottomAnchor.constraint(equalTo: self.header3.topAnchor,constant:30).isActive = true
        self.objectBrowser = (self.scroller3.documentView as! NSOutlineView)
        self.objectBrowser.indentationPerLevel = 20
        self.objectBrowser.rowHeight = 16
        self.objectBrowser.intercellSpacing = NSSize(width: 0,height: 0)
        self.view.addSubview(self.scroller3)
        self.symbolList3 = SymbolList()
        self.symbolList3!.childType = .any
        self.symbolList3!.foregroundColor = NSColor.argonCheese
        self.objectBrowser.delegate = self.symbolList3
        self.objectBrowser.dataSource = self.symbolList3
        self.symbolList3!.outliner = self.objectBrowser
        self.symbolList3!.symbols = [TopModule.shared.moduleRoot]
        self.scroller3.translatesAutoresizingMaskIntoConstraints = false
        self.scroller3.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scroller3.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.scroller3.topAnchor.constraint(equalTo: self.header3.bottomAnchor).isActive = true
        let constraint2 = NSLayoutConstraint(item: self.scroller3!, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.33333,constant: -30)
        NSLayoutConstraint.activate([constraint2])
        self.view.addConstraint(constraint2)
        }
        
    public override func viewDidAppear()
        {
        let controller = self.view.window!.windowController as! ArgonBrowserWindowController
        controller.classBrowser = self.classBrowser
        controller.methodBrowser = self.methodBrowser
        controller.objectBrowser = self.objectBrowser
        controller.symbolList1 = self.symbolList1
        controller.symbolList2 = self.symbolList2
        controller.symbolList3 = self.symbolList3
        }
    }

public class SymbolList:NSObject,NSOutlineViewDelegate,NSOutlineViewDataSource
    {
    public var symbols: Symbols = []
        {
        didSet
            {
            self.outliner?.reloadData()
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
        let row = HierarchyRowView(selectionColor: self.foregroundColor)
        return(row)
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
