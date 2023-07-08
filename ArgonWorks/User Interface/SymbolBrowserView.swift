//
//  SymbolBrowserView.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 22/9/21.
//

import Cocoa

public enum ChildType
    {
    case `class`
    case method
    case any
    }
    
public class SymbolBrowserView: NSScrollView,NSOutlineViewDataSource,NSOutlineViewDelegate,Pane
    {
    public override var isFlipped: Bool
        {
        return(true)
        }
        
    public override var intrinsicContentSize: CGSize
        {
        return(CGSize(width:400,height: 400))
        }
        
    public var layoutFrame:LayoutFrame = .zero
    
    public var foregroundColor: NSColor = .white
    public var iconTintColor: NSColor = .argonCheese
    private var outliner: NSOutlineView
    
    public var childType: ChildType = .class
        {
        didSet
            {
            self.outliner.reloadData()
            }
        }
    
    public var symbols: Array<Symbol> = []
        {
        didSet
            {
            self.outliner.reloadData()
            }
        }
    
    public init()
        {
        fatalError("This is not the designated initializer for NSScrollView")
        }
        
    public override init(frame: NSRect)
        {
        self.outliner = NSOutlineView(frame: .zero)
        super.init(frame: frame)
        self.initBrowserView()
        self.drawsBackground = true
        self.focusRingType = .none
        self.outliner.backgroundColor = .black
        self.borderType = .noBorder
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initBrowserView()
        {
        self.backgroundColor = .black
        self.drawsBackground = true
        self.documentView = self.outliner
//        self.outliner.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.outliner)
        self.outliner.focusRingType = .none
        self.outliner.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.outliner.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.outliner.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.outliner.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.outliner.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        for column in self.outliner.tableColumns
            {
            self.outliner.removeTableColumn(column)
            }
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column0"))
        self.outliner.addTableColumn(column)
        self.outliner.delegate = self
        self.outliner.dataSource = self
        let nib = NSNib(nibNamed: "HierarchyCell", bundle: nil)
        self.outliner.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCell"))
        self.outliner.indentationPerLevel = 20
        self.outliner.rowHeight = 16
        self.outliner.intercellSpacing = NSSize(width: 0,height: 0)
        }
    
    public override func awakeFromNib()
        {
        super.awakeFromNib()
        self.initBrowserView()
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
        
    public func outlineViewSelectionDidChange(_ notification: Notification)
        {
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
