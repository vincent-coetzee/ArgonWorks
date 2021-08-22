//
//  ArgonBrowserWindowController.swift
//  ArgonBrowserWindowController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa
import UniformTypeIdentifiers

class ArgonBrowserWindowController: NSWindowController
    {
    @IBOutlet var toolbar: NSToolbar!
    
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
        self.sourceEditor.gutterBackgroundColor = NSColor.black
        self.sourceEditor.backgroundColor = NSColor.black
        self.sourceEditor.gutterForegroundColor = NSColor.lightGray
        for item in self.toolbar.visibleItems!
            {
            item.isEnabled = true
            }
        for item in self.toolbar.items
            {
            if item.label == "Open"
                {
                item.target = self
                item.action = #selector(ArgonBrowserWindowController.openDocument(_:))
                }
            }
        }
        
    private func initInspector()
        {
        }
        
    public func validateToolbarItem(item:NSToolbarItem) -> Bool
        {
        return(true)
        }
        
    @IBAction public func openDocument(_ sender:Any?)
        {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.argonSourceFile]
        panel.canChooseFiles = true
        panel.prompt = "Open"
        panel.message = "Select an Argon source file to be opened in the Argon source editor."
        panel.directoryURL = URL(fileURLWithPath: "/Users/vincent/Desktop")
        if panel.runModal() == .OK
            {
            if let url = panel.url,let string = try? String(contentsOf: url)
                {
                self.sourceEditor.string = string
                }
            }
        }
        
    @IBAction public func onOpenDocument(_ sender:Any?)
        {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.argonSourceFile]
        panel.canChooseFiles = true
        panel.prompt = "Open"
        panel.message = "Select an Argon source file to be opened in the Argon source editor."
        panel.directoryURL = URL(fileURLWithPath: "/Users/vincent/Desktop")
        if panel.runModal() == .OK
            {
            if let url = panel.url,let string = try? String(contentsOf: url)
                {
                self.sourceEditor.string = string
                }
            }
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


