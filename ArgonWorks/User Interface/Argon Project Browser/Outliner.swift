//
//  Outliner.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/3/22.
//

import Cocoa

public protocol OutlineItem
    {
    var isSystemItem: Bool { get }
    var iconTint: NSColor { get }
    var childCount: Int { get }
    var label: String { get }
    var icon: NSImage { get }
    var isExpandable: Bool { get }
    func child(atIndex: Int) -> OutlineItem
    func makeView(for: Outliner) -> OutlineItemNSView
    }
    
public protocol OutlineItemView: AnyObject
    {
    var outlineItem: OutlineItem? { get set }
    var font: NSFont { get set }
    }
    
public typealias OutlineItemNSView = OutlineItemView & NSView

public typealias OutlineItems = Array<OutlineItem>

public class SymbolHolder: OutlineItem
    {
    public enum SymbolHolderContext
        {
        case `default`
        case classes
        case enumerations
        case modules
        case constants
        case methods
        }
        
    public var isSystemItem: Bool
        {
        self.symbol.isSystemType
        }
        
    public var iconTint: NSColor
        {
        if self.symbol is TypeClass
            {
            return(SyntaxColorPalette.classColor)
            }
        else if self.symbol is TypeEnumeration || self.symbol is EnumerationCase
            {
            return(SyntaxColorPalette.enumerationColor)
            }
        else if self.symbol is Method || self.symbol is MethodInstance
            {
            return(SyntaxColorPalette.methodColor)
            }
        else if self.symbol is TypeAlias
            {
            return(SyntaxColorPalette.typeColor)
            }
        else if self.symbol is Constant
            {
            return(SyntaxColorPalette.constantColor)
            }
        else if symbol is Slot
            {
            return(SyntaxColorPalette.slotColor)
            }
        else if symbol is Module
            {
            return(SyntaxColorPalette.identifierColor)
            }
        else
            {
            return(NSColor.white)
            }
        }
    
    public var childCount: Int
        {
        self.children.count
        }
        
    private var children: Symbols
        {
        if self.symbol.isArgonModule
            {
            var symbols = self.symbol.children.filter{(!($0 is TypeClass) && !($0.isMetaclass))}
            symbols.insert(ArgonModule.shared.object,at: 0)
            return(symbols)
            }
        return(self.symbol.children)
        }
        
    public var label: String
        {
        self.symbol.displayName
        }
        
    public var icon: NSImage
        {
        let image = self._icon
        image.isTemplate = true
        return(image)
        }
        
    private var _icon: NSImage
        {
        if self.symbol is TypeClass
            {
            return(NSImage(named: "IconClass")!)
            }
        else if self.symbol is TypeEnumeration
            {
            return(NSImage(named: "IconEnumeration")!)
            }
        else if self.symbol is Method || self.symbol is MethodInstance
            {
            return(NSImage(named: "IconMethod")!)
            }
        else if self.symbol is TypeAlias
            {
            return(NSImage(named: "IconType")!)
            }
        else if self.symbol is Constant
            {
            return(NSImage(named: "IconConstant")!)
            }
        else if self.symbol is Slot || self.symbol is EnumerationCase
            {
            return(NSImage(named: "IconSlot")!)
            }
        else if self.symbol is Module
            {
            return(NSImage(named: "IconModule")!)
            }
        else
            {
            return(NSImage(named: "IconEmpty")!)
            }
        }
        
    public var isExpandable: Bool
        {
        self.symbol is Module || (self.symbol is TypeClass && ((self.symbol as! TypeClass).instanceSlots.count > 0 || (self.symbol as! TypeClass).subtypes.count > 0)) || self.symbol is TypeEnumeration || self.symbol is Method
        }
        
    public var symbol: Symbol
    private var symbolChildren: Symbols?
    private let context: SymbolHolderContext
    
    init(symbol: Symbol,context: SymbolHolderContext = .default)
        {
        self.symbol = symbol
        self.context = context
        }
        
    public func child(atIndex: Int) -> OutlineItem
        {
        return(SymbolHolder(symbol: self.children[atIndex],context: self.context))
        }
        
    public func makeView(for outliner: Outliner) -> OutlineItemNSView
        {
        let view = ConcreteOutlineItemView(frame: .zero)
        view.outlineItem = self
        return(view)
        }
    }
    
public class ConcreteOutlineItemView: NSTableCellView,OutlineItemView
    {
    public var font: NSFont = NSFont.systemFont(ofSize: 10)
        {
        didSet
            {
            self.textView.font = self.font
            }
        }
        
    public var outlineItem: OutlineItem?
        {
        didSet
            {
            if self.outlineItem.isNotNil
                {
                self.update()
                }
            }
        }
        
    private let iconView: NSImageView
    private let textView: NSTextField
    private let systemView: NSImageView
    
    override init(frame: NSRect)
        {
        self.textView = NSTextField(frame: .zero)
        self.iconView = NSImageView(frame: .zero)
        self.systemView = NSImageView(frame: .zero)
        super.init(frame: frame)
        self.addSubview(self.textView)
        self.addSubview(self.iconView)
        self.addSubview(self.systemView)
        self.textView.isBezeled = false
        self.textView.isBordered = false
        self.textView.isEditable = false
        self.textView.drawsBackground = false
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update()
        {
        self.textView.stringValue = self.outlineItem!.label
        self.iconView.image = self.outlineItem!.icon
        self.iconView.image!.isTemplate = true
        self.iconView.contentTintColor = self.outlineItem!.iconTint
        self.systemView.isHidden = !self.outlineItem!.isSystemItem
        if self.outlineItem!.isSystemItem
            {
            self.systemView.image = NSImage(named: "IconSystem")!
            self.systemView.image!.isTemplate = true
            self.systemView.contentTintColor = NSColor.argonNeonPink
            }
        }
        
    public override func layout()
        {
        super.layout()
        let height = self.bounds.size.height
        self.iconView.frame = NSRect(x: height,y: 0,width: height,height: height).insetBy(dx: 1, dy: 2)
        self.systemView.frame = NSRect(x: 0,y:0,width: height,height: height).insetBy(dx: 1,dy: 2)
        let font = self.textView.font
        let string = self.textView.stringValue
        let size = NSAttributedString(string: string,attributes: [.font: font]).size()
        let delta = (height - size.height) / 2
        self.textView.frame = NSRect(x: height + height,y: delta,width: self.bounds.size.width - height,height: size.height)
        }
    }
    
public class Outliner: NSViewController
    {
    public var rootItems: OutlineItems = []
        {
        didSet
            {
            self.outlineView.reloadData()
            }
        }
    
    public var font: NSFont!
        {
        didSet
            {
            self.outlineView.font = self.font
            }
        }
        
    public var outlineItemsByKey = Dictionary<Int,OutlineItem>()
    private let scrollView: NSScrollView
    private let outlineView: NSOutlineView
    private var tag: String
    
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
        
    public func loseActiveController(inController controller: ArgonBrowserViewController)
        {
        self.scrollView.removeFromSuperview()
        controller.leftController = nil
        }
        
    public func becomeActiveController(inController controller: ArgonBrowserViewController)
        {
        controller.leftView.addSubview(self.scrollView)
        self.bindEdgesToEdgesOfView(controller.leftView)
        controller.leftController = self
        controller.buttonBar.highlightButton(atTag: self.tag)
        }
        
    public func bindEdgesToEdgesOfView(_ aView: NSView)
        {
        self.scrollView.leadingAnchor.constraint(equalTo: aView.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: aView.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: aView.bottomAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: aView.topAnchor,constant: 25).isActive = true
        }
        
    required init?(coder: NSCoder)
        {
        fatalError("init(coder:) has not been implemented")
        }
    
    private func initViews()
        {
        self.scrollView.autohidesScrollers = true
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
//        self.outlineView.translatesAutoresizingMaskIntoConstraints = false
        self.outlineView.frame = self.scrollView.bounds
        self.outlineView.headerView = nil
        self.scrollView.drawsBackground = false
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
        self.font = NSFont(name: "SunSans-SemiBold",size: 10)!
        self.outlineView.rowHeight = 14
        self.outlineView.intercellSpacing = NSSize(width: 0,height: 0)
//        self.scrollView.contentInsets = NSEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.outlineView.style = .plain
        self.scrollView.borderType = .noBorder
        self.scrollView.drawsBackground = false
        self.outlineView.backgroundColor = NSColor.argonBlack70
        }
        
    public func itemChanged(_ item: OutlineItem)
        {
        self.outlineView.reloadItem(item)
        }
        
    public func addItem(_ item: OutlineItem,in parent: OutlineItem?)
        {
//        if parent.isNil
//            {
//            self.rootItems.append(item)
//            self.reloadData()
//            }
//        else
//            {
//            self.insertItems(at: [item],inParent: parent,withAnimation: .slideDown)
//            }
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
        view.font = self.font.isNil ? NSFont(name: "SunSans-SemiBold",size: 10)! : self.font!
        return(view)
        }
        
    public func outlineView(_ outlineView: NSOutlineView,rowViewForItem anItem: Any) -> NSTableRowView?
        {
        let view = RowView(selectionColor: NSColor.controlAccentColor)
        return(view)
        }
    }
