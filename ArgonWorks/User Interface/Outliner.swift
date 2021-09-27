//
//  Outliner.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/9/21.
//

import Cocoa

public class Outliner: NSScrollView,NSOutlineViewDataSource, NSOutlineViewDelegate
    {
    public var symbols: Array<Symbol> = []
        {
        didSet
            {
//            self.outlineView.reloadData()
            }
        }
        
    public var childType: ChildType = .class
    public var foregroundColor: NSColor = NSColor.controlAccentColor
    
//    private let outlineView:NSOutlineView
    
    override init(frame: NSRect)
        {
//        self.outlineView = NSOutlineView()
        super.init(frame: frame)
//        self.addSubview(self.outlineView)
//        initView()
        }
    
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
    
//    private func initView()
//        {
//        self.outlineView.translatesAutoresizingMaskIntoConstraints = false
//        self.outlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        self.outlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        self.outlineView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        self.outlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
////        self.outlineView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        self.outlineView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
//        self.outlineView.dataSource = self
//        self.outlineView.delegate = self
//        }
        
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
