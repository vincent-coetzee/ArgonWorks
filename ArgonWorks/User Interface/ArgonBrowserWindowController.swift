//
//  ArgonBrowserWindowController.swift
//  ArgonBrowserWindowController
//
//  Created by Vincent Coetzee on 22/8/21.
//

import Cocoa
import UniformTypeIdentifiers

internal enum UserDefaultsKey: String
    {
    case currentSourceFileURL
    case browserWindowRectangle
    case memoryWindowRectangle
    }
    
internal class RectObject
    {
    var rect: NSRect
        {
        return(NSRect(x: self.x,y: self.y,width: self.width,height: self.height))
        }
        
    private let x: CGFloat
    private let y: CGFloat
    private let width: CGFloat
    private let height: CGFloat
    
    init(_ rect:NSRect)
        {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.size.width
        self.height = rect.size.height
        }
        
    init?(forKey: String,on defaults:UserDefaults)
        {
        self.x = defaults.double(forKey: forKey + "x")
        self.y = defaults.double(forKey: forKey + "y")
        self.width = defaults.double(forKey: forKey + "width")
        self.height = defaults.double(forKey: forKey + "height")
        if self.x == 0 && self.y == 0
            {
            return(nil)
            }
        }
        
    internal func setValue(forKey: String,on someDefaults: UserDefaults)
        {
        someDefaults.set(self.x,forKey: forKey + "x")
        someDefaults.set(self.y,forKey: forKey + "y")
        someDefaults.set(self.width,forKey: forKey + "width")
        someDefaults.set(self.height,forKey: forKey + "height")
        }
    }

extension UserDefaults
    {
    fileprivate func setValue(_ value: String,forKey: UserDefaultsKey)
        {
        self.set(value, forKey: forKey.rawValue)
        }
        
    fileprivate func setValue(_ value: NSRect,forKey: UserDefaultsKey)
        {
        self.set(value, forKey: forKey.rawValue)
        }
        
    fileprivate func stringValue(forKey: UserDefaultsKey) -> String?
        {
        return(self.value(forKey: forKey.rawValue) as? String)
        }
        
    fileprivate func rectValue(forKey: UserDefaultsKey) -> NSRect?
        {
        return(self.value(forKey: forKey.rawValue) as? NSRect)
        }
    }
    
class ArgonBrowserWindowController: NSWindowController
    {
    @IBOutlet var toolbar: NSToolbar!
    
    private var symbols: Array<Symbol> = []
    private let small = VirtualMachine.small
    private var compiler: Compiler! = nil
    private var currentSourceFileURL:URL? = nil
    
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
        self.compiler = Compiler()
        if let rectObject = RectObject(forKey: UserDefaultsKey.browserWindowRectangle.rawValue,on: UserDefaults.standard)
            {
            self.window?.setFrame(rectObject.rect, display: true, animate: true)
            }
        }
        
    private func initOutliner()
        {
        self.symbols = [TopModule.shared.argonModule.object,TopModule.shared,TopModule.shared.moduleRoot]
        self.outliner.indentationPerLevel = 20
        self.outliner.dataSource = self
        self.outliner.delegate = self
        self.outliner.rowHeight = 16
        self.outliner.intercellSpacing = NSSize(width: 0,height: 0)
        let nib = NSNib(nibNamed: "HierarchyCell", bundle: nil)
        self.outliner.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HierarchyCell"))
        self.outliner.reloadData()
        }
        
    @IBAction public func save(_ sender: Any?)
        {
        if let url = self.currentSourceFileURL
            {
            let text = self.sourceEditor.textStorage!.string
            do
                {
                try text.write(to: url, atomically: false, encoding: .utf8)
                }
            catch let error
                {
                print(error)
                }
            }
        }
        
    @IBAction public func sourceChangedNotification(_ event:NSNotification)
        {
        do
            {
            try self.compiler.parseChunk(self.sourceEditor.textStorage?.string ?? "")
            }
        catch
            {
            }
        self.sourceEditor.textStorage?.beginEditing()
        for (range,attributes) in self.compiler.tokenRenderer.attributes
            {
            self.sourceEditor.textStorage?.setAttributes(attributes,range: range)
            }
        self.sourceEditor.textStorage?.endEditing()
        }
        
    private func initSourceEditor()
        {
        self.sourceEditor.gutterBackgroundColor = NSColor.black
        self.sourceEditor.backgroundColor = NSColor.black
        self.sourceEditor.gutterForegroundColor = NSColor.lightGray
        NotificationCenter.default.addObserver(self, selector: #selector(sourceChangedNotification(_:)), name: NSText.didChangeNotification, object: self.sourceEditor)
        NotificationCenter.default.addObserver(self, selector: #selector(windowResizedNotification(_:)), name: NSWindow.didResizeNotification, object: self.window)
        self.sourceEditor.isAutomaticQuoteSubstitutionEnabled = false
        self.sourceEditor.isAutomaticDashSubstitutionEnabled = false
        self.sourceEditor.isAutomaticTextReplacementEnabled = false
        for item in self.toolbar.visibleItems!
            {
            item.isEnabled = true
            }
        for item in self.toolbar.items
            {
            if item.label == "Open"
                {
                item.target = self
                item.action = #selector(ArgonBrowserWindowController.fugglyBuggly(_:))
                }
            if item.label == "Compile"
                {
                item.target = self
                item.action = #selector(ArgonBrowserWindowController.onCompile(_:))
                }
            if item.label == "Save"
                {
                item.target = self
                item.action = #selector(ArgonBrowserWindowController.onSaveEditor(_:))
                }
            if item.label == "New"
                {
                item.target = self
                item.action = #selector(ArgonBrowserWindowController.onNewEditor(_:))
                }
            if item.label == "Object"
                {
                item.target = self
                item.action = #selector(ArgonBrowserWindowController.onEmitObject(_:))
                }
            if item.label == "Symbols"
                {
                item.target = self
                item.action = #selector(ArgonBrowserWindowController.onEmitSymbols(_:))
                }
            }
        let urlString = UserDefaults.standard.stringValue(forKey: .currentSourceFileURL)
        if let aString = urlString,
        let url = URL(string: aString),
        let string = try? String(contentsOf: url)
            {
            self.currentSourceFileURL = url
            let mutableString = NSMutableAttributedString(string: string,attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
            self.sourceEditor.textStorage?.setAttributedString(mutableString)
            self.compiler = Compiler()
            self.compiler.compileChunk(string)
            self.sourceEditor.textStorage?.beginEditing()
            for (range,attributes) in self.compiler.tokenRenderer.attributes
                {
                self.sourceEditor.textStorage?.setAttributes(attributes,range: range)
                }
            self.sourceEditor.textStorage?.endEditing()
            }
        }
        
    @IBAction public func windowResizedNotification(_ event:NSNotification)
        {
        let frame = self.window!.frame
        let rectObject = RectObject(frame)
        rectObject.setValue(forKey: UserDefaultsKey.browserWindowRectangle.rawValue,on: UserDefaults.standard)
        }
        
    private func initInspector()
        {
        }
        
    public func validateToolbarItem(item:NSToolbarItem) -> Bool
        {
        return(true)
        }
        
    @IBAction func onSaveEditor(_ sender:Any?)
        {
        let text = self.sourceEditor.textStorage!.string
        if self.currentSourceFileURL.isNotNil
            {
            do
                {
                try text.write(to: self.currentSourceFileURL!, atomically: false, encoding: .utf8)
                return
                }
            catch let error
                {
                print("ERROR \(error) SAVING FiLE")
                }
            }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType("com.macsemantics.argon.source")!]
        panel.prompt = "Save"
        panel.message = "Select where the editor must save the Argon source."
        panel.directoryURL = URL(fileURLWithPath: "/Users/vincent/Desktop")
        if panel.runModal() == .OK
            {
            if let url = panel.url
                {
                try? text.write(to: url, atomically: false, encoding: .utf8)
                UserDefaults.standard.setValue(url.absoluteString,forKey: .currentSourceFileURL)
                }
            }
        }
        
    @IBAction func onEmitSymbols(_ sender:Any?)
        {
        do
            {
            var url = self.currentSourceFileURL
            url?.deletePathExtension()
            url?.appendPathExtension("argonb")
            if let theUrl = url
                {
                let source = self.sourceEditor.string
                self.compiler = Compiler()
                if let chunk = self.compiler.compileChunk(source)
                    {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: chunk, requiringSecureCoding: false)
                    try data.write(to: theUrl)
                    }
                }
            }
        catch let error
            {
            print(error)
            }
        }
        
    @IBAction func onCompile(_ sender: Any?)
        {
        TopModule.shared.removeObject(taggedWith: self.compiler.currentTag)
        let source = self.sourceEditor.string
        let compiler = Compiler()
        TopModule.shared.argonModule.object.resetHierarchy()
        TopModule.shared.argonModule.realizeSuperclasses()
        if let chunk = compiler.compileChunk(source)
            {
            if let module = chunk as? Module
                {
                module.realizeSuperclasses()
                self.outliner.reloadData()
                }
            }
        }
        
    @IBAction func onNewEditor(_ sender:Any?)
        {
        let mutableString = NSMutableAttributedString(string: "",attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
        self.sourceEditor.textStorage?.setAttributedString(mutableString)
        self.compiler = Compiler()
        }
        
    @IBAction func fugglyBuggly(_ sender:Any?)
        {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType("com.macsemantics.argon.source")!]
        panel.canChooseFiles = true
        panel.prompt = "Open"
        panel.message = "Select an Argon source file to be opened in the Argon source editor."
        panel.directoryURL = URL(fileURLWithPath: "/Users/vincent/Desktop")
        if panel.runModal() == .OK
            {
            if let url = panel.url,let string = try? String(contentsOf: url)
                {
                self.currentSourceFileURL = url
                let mutableString = NSMutableAttributedString(string: string,attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
                self.sourceEditor.textStorage?.setAttributedString(mutableString)
                self.compiler = Compiler()
                self.compiler.compileChunk(string)
                self.sourceEditor.textStorage?.beginEditing()
                for (range,attributes) in self.compiler.tokenRenderer.attributes
                    {
                    self.sourceEditor.textStorage?.setAttributes(attributes,range: range)
                    }
                self.sourceEditor.textStorage?.endEditing()
                UserDefaults.standard.setValue(url.absoluteString,forKey: .currentSourceFileURL)
                }
            }
        }
        
    @IBAction public func onEmitObject(_ sender:Any?)
        {
        }
        
    @IBAction public func onOpenDocument(_ sender:Any?)
        {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType("com.macsemantics.argon.source")!]
        panel.canChooseFiles = true
        panel.prompt = "Open"
        panel.message = "Select an Argon source file to be opened in the Argon source editor."
        panel.directoryURL = URL(fileURLWithPath: "/Users/vincent/Desktop")
        if panel.runModal() == .OK
            {
            if let url = panel.url,let string = try? String(contentsOf: url)
                {
                self.sourceEditor.string = string
                self.currentSourceFileURL = url
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
        view.textField?.font = NSFont.systemFont(ofSize: 10)
        view.textField?.stringValue = anItem.label
        view.imageView?.image = NSImage(named: anItem.imageName)!
        view.imageView?.image?.isTemplate = true
        view.imageView?.contentTintColor = anItem.defaultColor
        view.textField?.textColor = NSColor.controlTextColor
        return(view)
        }
        
//    public func outlineView(_ outlineView: NSOutlineView,rowViewForItem anItem: Any) -> NSTableRowView?
//        {
//        let view = RowView(selectionColor: ArgonPalette.shared.kModuleColor)
//        return(view)
//        }
    }


