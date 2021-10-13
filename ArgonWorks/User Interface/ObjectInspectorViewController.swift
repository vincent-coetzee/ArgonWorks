//
//  ObjectInspectorViewController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Cocoa
import UniformTypeIdentifiers

public class ObjectFileItem
    {
    public var defaultColor: NSColor
        {
        Palette.shared.hierarchyPrimaryTintColor
        }
        
    public var displayString: String
        {
        fatalError()
        }
        
    public var childCount: Int
        {
        fatalError()
        }
    
    public var icon: NSImage
        {
        fatalError()
        }
        
    public var isExpandable: Bool
        {
        fatalError()
        }
        
    public func child(atIndex: Int) -> ObjectFileItem
        {
        fatalError()
        }
    }
    
public class ObjectFileWrapper: ObjectFileItem
    {
    public override var displayString: String
        {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY hh:mm"
        let string = dateFormatter.string(from: wrapper.date)
        return("\(string) \(wrapper.filename)")
        }
        
    public override var childCount: Int
        {
        return(1)
        }
    
    public override var icon: NSImage
        {
        NSImage(named: "ObjectIcon")!
        }
        
    public override var isExpandable: Bool
        {
        return(true)
        }
        
    public override func child(atIndex: Int) -> ObjectFileItem
        {
        return(ObjectFileSymbol(symbol: wrapper.module))
        }
        
    private let wrapper: ObjectFile
    
    internal init(objectFile: ObjectFile)
        {
        self.wrapper = objectFile
        }
    }
    
public class ObjectFileSymbol: ObjectFileItem
    {
    public override var defaultColor: NSColor
        {
        self.symbol.defaultColor
        }
        
    public override var displayString: String
        {
        return(self.symbol.displayString)
        }
        
    public override var childCount: Int
        {
        return(self.symbol.childCount)
        }
    
    public override var icon: NSImage
        {
        NSImage(named: self.symbol.iconName)!
        }
        
    public override var isExpandable: Bool
        {
        self.symbol.isExpandable
        }
        
    public override func child(atIndex: Int) -> ObjectFileItem
        {
        if self.children.isEmpty
            {
            self.children = self.symbol.children!.map{ObjectFileSymbol(symbol: $0)}.sorted{$0.displayString < $1.displayString}
            }
        return(self.children[atIndex])
        }
        
    private let symbol: Symbol
    private var children: Array<ObjectFileItem> = []
    
    public init(symbol: Symbol)
        {
        self.symbol = symbol
        }
    }
    
public class ObjectInspectorViewController: NSViewController
    {
    @IBOutlet var outliner: NSOutlineView!
    
    private var items: Array<ObjectFileItem> = []
    
    public override func viewDidLoad()
        {
        super.viewDidLoad()
        let nib = NSNib(nibNamed: "HierarchyCell",bundle: nil)
        self.outliner.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCell"))
        self.outliner.dataSource = self
        self.outliner.delegate = self
        self.outliner.rowHeight = 18
        self.outliner.indentationPerLevel = 30
        }
        
    @IBAction func onObjectClicked(_ sender: Any?)
        {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType("com.macsemantics.argon.object")!]
        panel.prompt = "Load Object"
        panel.message = "Select which object file to load."
        if panel.runModal() == .OK
            {
            if let url = panel.url
                {
                do
                    {
                    let newData = try Data(contentsOf: url)
                    let result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(newData) as! ObjectFile
                    let item = ObjectFileWrapper(objectFile: result)
                    self.items.append(item)
                    self.outliner.reloadData()
                    }
                catch
                    {
                    let alert = NSAlert()
                    alert.icon = NSImage(named: "ObjectIcon")!
                    alert.messageText = "Object reading error."
                    alert.informativeText = "An error occured while reading the object file at the path '\(url.absoluteString)'."
                    alert.beginSheetModal(for: self.view.window!)
                        {
                        response in
                        alert.window.endSheet(self.view.window!)
                        }
                    }
                }
            }
        }
    }


extension ObjectInspectorViewController: NSOutlineViewDataSource
    {
    @objc public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item == nil
            {
            return(self.items.count)
            }
        else
            {
            let objectItem = item as! ObjectFileItem
            return(objectItem.childCount)
            }
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.items[index])
            }
        else if let objectItem = item as? ObjectFileItem
            {
            return(objectItem.child(atIndex: index))
            }
        fatalError()
        }

    @objc public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        let objectItem = item as! ObjectFileItem
        return(objectItem.isExpandable)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView?
        {
        let row = HierarchyRowView(selectionColor: Palette.shared.hierarchySelectionColor)
        return(row)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat
        {
        return(20)
        }
    
    public func outlineView(_ outlineView: NSOutlineView,viewFor tableColumn: NSTableColumn?,item: Any) -> NSView?
        {
        let objectItem = item as! ObjectFileItem
        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCell"), owner: nil) as! HierarchyCellView
        view.icon.image = objectItem.icon
        view.icon.image?.isTemplate = true
        view.icon.contentTintColor = objectItem.defaultColor
        view.text.stringValue = objectItem.displayString
        return(view)
        }
    }
    
extension ObjectInspectorViewController: NSOutlineViewDelegate
    {
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
//        let row = outliner!.selectedRow
//        if row >= 0,let cell = outliner!.view(atColumn: 0, row: row, makeIfNecessary: false) as? HierarchyCellView
//            {
//            cell.invert()
//            }
        }
    }
