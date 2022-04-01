//
//  Outliner.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/3/22.
//

import Cocoa

public enum OutlinerContext
    {
    case `default`
    case classes
    case enumerations
    case modules
    case constants
    case methods
    
    public func isSymbolExpandable(_ symbol: Symbol) -> Bool
        {
        switch(self)
            {
            case .default:
                return(false)
            case .classes:
                return(symbol is TypeClass)
            case .enumerations:
                return(symbol is TypeEnumeration)
            case .modules:
                return(symbol is Module || symbol is TypeClass)
            case .constants:
                return(false)
            case .methods:
                return(symbol is Method)
            }
        }
        
    public func parentSymbols(forSymbol: Symbol) -> Symbols?
        {
        switch(self)
            {
            case .default:
                fatalError()
            case .classes:
                if let aClass = forSymbol as? TypeClass
                    {
                    return(aClass.superclasses)
                    }
                return(nil)
            case .enumerations:
                return(nil)
            case .modules:
                if let instance = forSymbol as? MethodInstance
                    {
                    return([instance.argonMethod])
                    }
                return(forSymbol.module.isNil ? nil : [forSymbol.module!])
            case .constants:
                return(nil)
            case .methods:
                if let instance = forSymbol as? MethodInstance
                    {
                    return([instance.argonMethod])
                    }
                return(nil)
            }
        }
        
    public func children(forSymbol: Symbol) -> Symbols
        {
        switch(self)
            {
            case .default:
                return([])
            case .classes:
                if let aClass = forSymbol as? TypeClass
                    {
                    let slots = aClass.instanceSlots.sorted{$0.label < $1.label}
                    let subclasses = aClass.subtypes.map{$0 as! TypeClass}.sorted{$0.label < $1.label}
                    return(slots + subclasses)
                    }
                return([])
            case .enumerations:
                if let enumeration = forSymbol as? TypeEnumeration
                    {
                    return(enumeration.cases.sorted{$0.label < $1.label})
                    }
                return([])
            case .modules:
                if let module = forSymbol as? Module
                    {
                    return(module.allSymbols.sorted{$0.label < $1.label})
                    }
                return([])
            case .constants:
                return([])
            case .methods:
                if let  method = forSymbol as? Method
                    {
                    return(method.instances.sorted{$0.displayString < $1.displayString})
                    }
                return([])
            }
        }
    }
    
public class Outliner: NSViewController
    {
    public var rootItems: OutlineItems = []
        {
        didSet
            {
            for item in self.rootItems
                {
                self.outlineItemsByKey[item.identityKey] = item
                }
            self.outlineView.reloadData()
            }
        }
    
    public var font: NSFont = NSFont(name: "SunSans-SemiBold",size: 10)!
        {
        didSet
            {
            self.outlineView.font = self.font
            self.outlineView.reloadData()
            }
        }
        
    public var backgroundColor: NSColor?
        {
        didSet
            {
            self.scrollView.backgroundColor = self.backgroundColor!
            }
        }
        
    public var outlineItemsByKey = Dictionary<Int,OutlineItem>()
    private let scrollView: NSScrollView
    private let outlineView: NSOutlineView
    private var tag: String
    public var topConstraint: NSLayoutConstraint!
    public var context: OutlinerContext!
    private var isActive = false
    private var wasActive = false
    
    public init(tag: String)
        {
        self.tag = tag
        self.scrollView = NSScrollView(frame: .zero)
        self.outlineView = NSOutlineView(frame: .zero)
        super.init()
        self.tag = tag
        }
    
    public override init(nibName: String?,bundle: Bundle?)
        {
        self.tag = ""
        self.scrollView = NSScrollView(frame: .zero)
        self.outlineView = NSOutlineView(frame: .zero)
        super.init(nibName: nil,bundle: nil)
        self.initViews()
        }
        
    public override func loadView()
        {
        self.view = self.scrollView
        }
        
    public func changeHeight(inView leftView: NSView,inController controller: ArgonBrowserViewController)
        {
        self.outlineView.removeConstraint(self.topConstraint)
        self.topConstraint = self.scrollView.topAnchor.constraint(equalTo: leftView.topAnchor,constant: controller.toolbarHeight)
        self.topConstraint.isActive = true
        }
        
    public func loseActiveController(inController controller: ArgonBrowserViewController)
        {
        self.isActive = false
        self.scrollView.removeFromSuperview()
        controller.leftController = nil
        }
        
    public func becomeActiveController(inController controller: ArgonBrowserViewController)
        {
        controller.leftView.addSubview(self.scrollView)
        self.bindEdgesToEdgesOfView(controller.leftView,withHeight: controller.toolbarHeight)
        controller.leftController = self
        controller.buttonBar.highlightButton(atTag: self.tag)
        self.isActive = true
        self.wasActive = true
        }
        
    public func bindEdgesToEdgesOfView(_ aView: NSView,withHeight height: CGFloat)
        {
        self.scrollView.leadingAnchor.constraint(equalTo: aView.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: aView.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: aView.bottomAnchor).isActive = true
        self.topConstraint = self.scrollView.topAnchor.constraint(equalTo: aView.topAnchor,constant: height)
        self.topConstraint.isActive = true
        }
        
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
    
    private func initViews()
        {
        self.scrollView.autohidesScrollers = true
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.outlineView.frame = self.scrollView.bounds
        self.outlineView.headerView = nil
        self.scrollView.drawsBackground = true
        self.scrollView.backgroundColor = .clear
        self.outlineView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.scrollView.documentView = self.outlineView
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "0"))
        column.minWidth = 200
        self.outlineView.addTableColumn(column)
        self.scrollView.hasHorizontalScroller = false
        self.scrollView.hasVerticalScroller = true
        self.outlineView.rowHeight = self.font.lineHeight
        self.outlineView.intercellSpacing = NSSize(width: 0,height: 0)
        self.outlineView.style = .plain
        self.scrollView.borderType = .noBorder
        self.scrollView.drawsBackground = false
        self.outlineView.backgroundColor = NSColor.argonBlack70
        }
        
    public func beginUpdates()
        {
        self.outlineView.beginUpdates()
        }
        
    public func endUpdates()
        {
        self.outlineView.endUpdates()
        }
        
    public func itemChanged(_ item: OutlineItem)
        {
        self.outlineView.reloadItem(item)
        }
        
    public func removeSymbol(_ symbol: Symbol)
        {
        if let item = self.outlineItemsByKey[symbol.identityHash]
            {
            let parent = self.outlineView.parent(forItem: item)
            if parent.isNil
                {
                var index = 0
                while index < self.rootItems.count
                    {
                    if (self.rootItems[index] as! SymbolHolder).symbol.identityHash == symbol.identityHash
                        {
                        self.rootItems.remove(at: index)
                        break
                        }
                    index += 1
                    }
                }
            guard self.wasActive else
                {
                return
                }
            let childIndex = self.outlineView.childIndex(forItem: item)
            self.outlineView.removeItems(at: IndexSet(integer: childIndex), inParent: parent, withAnimation: .slideUp)
            self.outlineItemsByKey[symbol.identityHash] = nil
            }
        }
        
    public func insertSymbol(_ symbol: Symbol)
        {
        if let parentSymbols = self.context.parentSymbols(forSymbol: symbol)
            {
            guard self.wasActive else
                {
                return
                }
            for aParent in parentSymbols
                {
                if let parent = self.outlineItemsByKey[aParent.identityHash]
                    {
                    let index = parent.insertionIndex(forSymbol: symbol)
                    self.outlineView.insertItems(at: IndexSet(integer: index), inParent: parent)
                    }
                else
                    {
                    fatalError("Could not find parent item")
                    }
                }
            }
        else
            {
            let newItem = SymbolHolder(symbol: symbol,context: self.context)
            self.outlineItemsByKey[symbol.identityHash] = newItem
            self.rootItems.append(newItem)
            guard self.wasActive else
                {
                return
                }
            self.rootItems = self.rootItems.sorted{$0.label < $1.label}
            let labels = self.rootItems.map{$0.label}
            let index = labels.firstIndex(of: symbol.label)!
            self.outlineView.insertItems(at: IndexSet(integer: index),inParent: nil,withAnimation: .slideDown)
            }
        }
    }

extension Outliner: NSOutlineViewDataSource
    {
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item.isNil
            {
            return(self.rootItems.count)
            }
        let element = item as! OutlineItem
        return(element.childCount)
        }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.rootItems[index])
            }
        else
            {
            let anItem = item as! OutlineItem
            let child = anItem.child(atIndex: index)
            self.outlineItemsByKey[child.identityKey] = child
            return(child)
            }
        }

    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        let anItem = item as! OutlineItem
        return(anItem.isExpandable)
        }
    }
    
extension Outliner: NSOutlineViewDelegate
    {
//    public func outlineViewSelectionDidChange(_ notification: Notification)
//        {
//        let selectedRow = self.outliner.selectedRow
//        if selectedRow == -1
//            {
//            self.selectedItem = nil
//            }
//        else
//            {
//            self.selectedItem = (self.outliner.item(atRow: selectedRow) as! BrowserViewItem)
//            let source = selectedItem!.symbol.source
//            self.editor.string = source
//            }
//        }

    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
        {
        let entry = item as! OutlineItem
        let view = entry.makeView(for: self)
        view.outlineItem = entry
        view.font = self.font
        return(view)
        }
        
    public func outlineView(_ outlineView: NSOutlineView,rowViewForItem anItem: Any) -> NSTableRowView?
        {
        let view = RowView(selectionColor: NSColor.controlAccentColor)
        return(view)
        }
    }
