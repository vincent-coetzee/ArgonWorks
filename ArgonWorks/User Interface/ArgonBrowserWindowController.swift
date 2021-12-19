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
    case currentSymbolFileURL
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
    fileprivate func removeObject(forKey: UserDefaultsKey)
        {
        self.removeObject(forKey: forKey.rawValue)
        }
        
    fileprivate func setValue(_ value: Any?,forKey: UserDefaultsKey)
        {
        self.set(value, forKey: forKey.rawValue)
        }
        
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
    
class ArgonBrowserWindowController: NSWindowController,NSWindowDelegate,NSToolbarDelegate,Reporter
    {
    public static let kCompilationEventCellIdentifier = NSUserInterfaceItemIdentifier(rawValue: ArgonBrowserWindowController.kCompilationEventCellName)
    public static let kCompilationEventCellName = "CompilationEventCell"
    public static let kCompilationEventCellNibName = "CompilationEventCell"
    
    @IBOutlet var toolbar: NSToolbar!
    @IBOutlet var splitViewController: NSSplitViewController!
//    internal var classBrowser: NSOutlineView!
    internal var methodBrowser: NSOutlineView!
    
    internal var objectBrowser: NSOutlineView!
        {
        didSet
            {
            self.initObjectBrowser()
            }
        }
    
    internal var errorListView: NSOutlineView!
    
    internal var symbolList1: SymbolList!
    internal var symbolList2: SymbolList!
    internal var symbolList3: SymbolList!
    
    private var symbols: Array<Symbol> = []
    private var currentSourceFileURL:URL? = nil
    private var currentSymbolFileURL:URL? = nil
    private var forwarderView: ForwarderView?
    private var firstFrame: NSRect? = nil
    private var compilationEvents: Dictionary<Int,CompilationEvent> = [:]
    private var compilationEventList: Array<CompilationEvent> = []
    
    public var capsules: Dictionary<URL,Capsule> = [:]
    public var currentCapsule: Capsule?
    public var selectedFont: NSFont?
    public var tokenizer:VisualTokenizer!
    
    public var sourceEditor: LineNumberTextView!
        {
        didSet
            {
            self.tokenizer = VisualTokenizer(lineNumberView: self.sourceEditor,reporter: self)
            self.initSourceEditor()
            self.initFontManagement()
            }
        }
        
    public var inspectorController: ArgonBrowserInspectorViewController!
        {
        didSet
            {
            self.initInspector()
            }
        }
    
    public func windowWillResize(_ window: NSWindow,to size: NSSize) -> NSSize
        {
        if self.firstFrame.isNil
            {
            if let rectObject = RectObject(forKey: UserDefaultsKey.browserWindowRectangle.rawValue,on: UserDefaults.standard)
                {
                let rect = rectObject.rect
                self.firstFrame = rect
                }
            }
        var frame = self.window!.frame
        frame.size = size
        let rectObject = RectObject(frame)
        rectObject.setValue(forKey: UserDefaultsKey.browserWindowRectangle.rawValue,on: UserDefaults.standard)
        return(size)
        }
        
    public func windowWillClose(_ notification: Notification)
        {
        RectObject(self.window!.frame).setValue(forKey: UserDefaultsKey.browserWindowRectangle.rawValue,on: UserDefaults.standard)
        UserDefaults.standard.setValue(nil,forKey: "junk")
        UserDefaults.standard.setValue(self.currentSourceFileURL?.absoluteString,forKey: .currentSourceFileURL)
        UserDefaults.standard.setValue(self.currentSymbolFileURL?.absoluteString,forKey: .currentSymbolFileURL)
        }
        
    override func windowDidLoad()
        {
        super.windowDidLoad()
        self.window?.setFrame(self.firstFrame!, display: true, animate: true)
        let frame = self.firstFrame!
        let rectObject = RectObject(frame)
        rectObject.setValue(forKey: UserDefaultsKey.browserWindowRectangle.rawValue,on: UserDefaults.standard)
        self.window!.styleMask = [.resizable, .titled, .closable]
//        NotificationCenter.default.addObserver(self, selector: #selector(sourceChangedNotification(_:)), name: NSText.didChangeNotification, object: self.sourceEditor)
        NotificationCenter.default.addObserver(self, selector: #selector(windowResizedNotification(_:)), name: NSWindow.didResizeNotification, object: self.window)
        self.window!.delegate = self
        self.toolbar.validateVisibleItems()
        }
    
    private func initObjectBrowser()
        {
        let menu = NSMenu()
        menu.insertItem(withTitle: "Generate Library Stub", action: #selector(onGenerateLibraryStub(_:)), keyEquivalent: "G", at: 0)
        self.objectBrowser.menu = menu
        NSColorPanel.shared.setTarget(self)
        NSColorPanel.shared.setAction(#selector(onColorSelected(_:)))
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
        
    private func initFontManagement()
        {
        NSFontManager.shared.target = self
        NSFontManager.shared.action = #selector(onFontChanged(_:))
        if let font = self.sourceEditor.textStorage?.font
            {
            NSFontManager.shared.setSelectedFont(font,isMultiple: false)
            }
        }
        
    @objc func onFontChanged(_ sender:Any?)
        {
        if let selectedFont = self.sourceEditor.textStorage?.font
            {
            let newFont = NSFontManager.shared.convert(selectedFont)
            self.sourceEditor.textStorage?.font = newFont
            self.selectedFont = newFont
            }
        }
        
    public func dispatchWarning(at: Location, message: String)
        {
        if let group = self.compilationEvents[at.line] as? CompilationEventGroup
            {
            group.addEvent(CompilationWarningEvent(location: at,message: message))
            }
        else
            {
            let group = CompilationEventGroup(location: at, message: message)
            group.isWarning = true
            self.compilationEvents[group.line] = group
            }
        self.compilationEventList = self.compilationEvents.values.sorted{$0.line < $1.line}
        self.errorListView?.reloadData()
        self.refreshSourceAnnotations()
        }
    
    public func dispatchError(at: Location, message: String)
        {
        if let group = self.compilationEvents[at.line] as? CompilationEventGroup
            {
            group.addEvent(CompilationErrorEvent(location: at,message: message))
            }
        else
            {
            let group = CompilationEventGroup(location: at, message: message)
            group.isWarning = false
            self.compilationEvents[group.line] = group
            }
        self.compilationEventList = self.compilationEvents.values.sorted{$0.line < $1.line}
        self.errorListView?.reloadData()
        self.refreshSourceAnnotations()
        }
        
    public func pushIssues(_ issues: CompilerIssues)
        {
        }
        
    public func status(_ string: String)
        {
        }
    
    public func resetReporting()
        {
        self.compilationEvents = [:]
        self.compilationEventList = []
        self.sourceEditor.removeAllAnnotations()
        self.errorListView?.reloadData()
        }
        
    public func cancelCompletion()
        {
        }
        
    public func refreshSourceAnnotations()
        {
        self.sourceEditor.removeAllAnnotations()
        }
        
    private func initSourceEditor()
        {
        self.forwarderView = ForwarderView(controller: self)
        self.sourceEditor.gutterBackgroundColor = NSColor.black
        self.sourceEditor.backgroundColor = NSColor.black
        self.sourceEditor.gutterForegroundColor = NSColor.lightGray
        self.sourceEditor.isAutomaticQuoteSubstitutionEnabled = false
        self.sourceEditor.isAutomaticDashSubstitutionEnabled = false
        self.sourceEditor.isAutomaticTextReplacementEnabled = false
        self.sourceEditor.selectionHighlightColor = Palette.shared.sourceSelectedLineHighlightColor
//        self.sourceEditor.sourceEditorDelegate = self
        let urlString = UserDefaults.standard.stringValue(forKey: .currentSourceFileURL)
        if let aString = urlString,
        let url = URL(string: aString),
        let string = try? String(contentsOf: url)
            {
            self.currentSourceFileURL = url
            let mutableString = NSMutableAttributedString(string: string,attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
            self.sourceEditor.textStorage?.setAttributedString(mutableString)
            self.toolbar.delegate = self
            self.window?.title = "ArgonBrowser [ \(self.currentSourceFileURL!.path) ]"
            self.tokenizer.update(string)
            }
        else
            {
            print("WARNING: Unable to open file \(String(describing: urlString))")
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
        self.errorListView = inspectorController.listView
        self.errorListView.delegate = self
        self.errorListView.dataSource = self
        let nib = NSNib(nibNamed: Self.kCompilationEventCellNibName, bundle: nil)
        self.errorListView.register(nib, forIdentifier: Self.kCompilationEventCellIdentifier)
        self.errorListView.rowHeight = 35
        self.errorListView.intercellSpacing = NSSize(width: 0,height: 2)
        self.errorListView.indentationPerLevel = 30
        self.errorListView?.reloadData()
        }
        
    public func validateToolbarItem(item:NSToolbarItem) -> Bool
        {
        return(true)
        }
        
    ///
    ///
    /// Actions that are invoked when a particular toolbar item is activated
    ///
    ///
    ///
    /// SAVE THE CURRENT FILE
    ///
    ///
    ///
    @IBAction func onSaveFile(_ sender:Any?)
        {
        let text = self.sourceEditor.textStorage!.string
        guard self.currentSourceFileURL.isNil else
            {
            do
                {
                try text.write(to: self.currentSourceFileURL!, atomically: false, encoding: .utf8)
                }
            catch let error
                {
                print("ERROR \(error) SAVING FiLE")
                }
            return
            }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType("com.macsemantics.argon.source")!]
        panel.prompt = "Save"
        panel.message = "Select where the editor must save the Argon source."
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Desktop")
        if panel.runModal() == .OK,let url = panel.url
            {
            try? text.write(to: url, atomically: false, encoding: .utf8)
            UserDefaults.standard.setValue(url.absoluteString,forKey: .currentSourceFileURL)
            self.currentSourceFileURL = url
            self.window?.title = "ArgonBrowser [ \(self.currentSourceFileURL!.path) ]"
            }
        }
    ///
    ///
    /// A COLOR WAS SELECTED IN THE COLOR PICKER, CHANGE THE COLOR IN THE
    /// PANE THAT IS CURRENTLY SELECTED
    ///
    ///
    @objc func onColorSelected(_ sender: Any?)
        {
        self.symbolList3.foregroundColor = NSColorPanel.shared.color
        self.objectBrowser.needsDisplay = true
        let rows = self.objectBrowser.numberOfRows
        for index in 0..<rows
            {
            self.objectBrowser.drawRow(index,clipRect: .zero)
            }
        }
    ///
    ///
    ///
    /// A CONTEXTUAL MENU ITEM THAT GENERATES STUB FILES FOR IMPLMENTING ROUTINES
    /// IN C WAS SELECTED. GENERATE THE STUB FILE.
    ///
    ///
    @objc func onGenerateLibraryStub(_ sender: Any?)
        {
//        let path = "/Users/vincent/Desktop/Library.c"
//        let selectedRow = self.objectBrowser.selectedRow
//        let selectedItem = objectBrowser.item(atRow: selectedRow)
//        if let elementHolder = selectedItem as? ElementHolder,let library = elementHolder.symbol as? LibraryModule
//            {
//            let mangler = NameMangler()
//            let file = fopen(path,"wt")
//            for function in library.functions
//                {
//                let name = mangler.mangle(function)
//                var string = "\t\(function.returnType.nativeCType.displayString) \(name)" + "("
//                let strings = function.parameters.map{"\($0.type.nativeCType.displayString) \($0.label)"}.joined(separator: ",") + ")"
//                string += strings
//                string += "\n"
//                string += "\t{\n\t}\n\n"
//                fputs(string,file)
//                }
//            fflush(file)
//            fclose(file)
//            }
        }
    ///
    ///
    /// The user wants to save this file under a new name so bring up the
    /// SavePanel to get a new name and sve it accordingly.
    ///
    ///
    @IBAction func onSaveAs(_ sender: Any?)
        {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType("com.macsemantics.argon.source")!]
        panel.prompt = "Save As"
        panel.message = "Select where the compiler must save the current source file under a new name."
//        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Desktop")
        if panel.runModal() == .OK
            {
            if let theUrl = panel.url
                {
                if theUrl == self.currentSourceFileURL
                    {
                    let alert = NSAlert()
                    alert.icon = NSImage(named: "SourceIcon")!
                    alert.messageText = "Save As Error."
                    alert.informativeText = "The new name of the file is the same as the existing name of the file."
                    alert.beginSheetModal(for: self.window!)
                        {
                        response in
                        alert.window.endSheet(self.window!)
                        }
                    }
                else
                    {
                    let text = self.sourceEditor.textStorage!.string
                    try? text.write(to: theUrl, atomically: false, encoding: .utf8)
                    UserDefaults.standard.setValue(theUrl.absoluteString,forKey: .currentSourceFileURL)
                    self.currentSourceFileURL = theUrl
                    self.window?.title = "ArgonBrowser [ \(self.currentSourceFileURL!.path) ]"
                    }
                }
            }
        }
    ///
    ///
    ///
    /// SAVE THE SYMBOLS GENERATED BY COMPILING THE CURRENT ARGON FILE
    ///
    ///
    ///
    @IBAction func onSaveObject(_ sender:Any?)
        {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType("com.macsemantics.argon.object")!]
        panel.prompt = "Save Object"
        panel.message = "Select where the compiler must save the object file."
        if self.currentSourceFileURL.isNotNil
            {
            var lastPart = self.currentSourceFileURL!.lastPathComponent
            var string = lastPart as NSString
            string = string.deletingPathExtension as NSString
            lastPart = string.appendingPathExtension("argono")!
            panel.nameFieldStringValue  = lastPart
            }
        if panel.runModal() == .OK
            {
            if let theUrl = panel.url
                {
                let aCompiler = Compiler(source: self.sourceEditor.string,reportingContext: NullReporter.shared,tokenRenderer: NullTokenRenderer.shared)
                if let module = aCompiler.compile()
                    {
                    do
                        {
                        let objectFile = ObjectFile(filename: theUrl.absoluteString,module: module,root: TopModule.shared,date: Date(), version: SemanticVersion(major: 1, minor: 0, patch: 0))
//                        let exporter = ImportArchiver(requiringSecureCoding: false, swapSystemSymbols: true, swapImportedSymbols: true)
                        ImportArchiver.isSwappingSystemTypes = true
                        let data = try ImportArchiver.archivedData(withRootObject: objectFile, requiringSecureCoding: false)
                        try data.write(to: theUrl)
//                        print("\(exporter.swappedSystemSymbolNames.count) system symbols swapped.")
//                        print("\(exporter.swappedImportedSymbolNames.count) imported symbols swapped.")
//                        let data = NSKeyedArchiver.archivedData(withRootObject: objectFile)
//                        try! data.write(to: theUrl)
                        let newData = try Data(contentsOf: theUrl)
//                        ImportUnarchiver.topModule = aCompiler.topModule
                        let result = try ImportUnarchiver.unarchiveTopLevelObjectWithData(newData)
//                        let importer = try! NSKeyedUnarchiver(forReadingFrom: newData)
//                        let result = importer.decodeObject(forKey: "root")
                        print(result!)
                        }
                    catch let error
                        {
                        print(error)
                        let alert = NSAlert()
                        alert.icon = NSImage(named: "ObjectIcon")!
                        alert.messageText = "Object writing error."
                        alert.informativeText = "An error occured while writing the object file for this Argon module out to disk."
                        alert.beginSheetModal(for: self.window!)
                            {
                            response in
                            alert.window.endSheet(self.window!)
                            }
                        }
                    }
                }
            }
        }
    ///
    ///
    ///
    /// COMPILE THE CURRENT ARGON FILE AND INCLUDE THE RESULTS
    /// OF THE COMPILATION INTO THE CURRENT STATE OF THE ENVIRONMENT
    ///
    ///
    @IBAction func onCompileFile(_ sender: Any?)
        {
        let source = self.sourceEditor.string
        Compiler(source: source,reportingContext: self,tokenRenderer: self.tokenizer).compile()
        }
    ///
    ///
    ///
    /// FLUSH THE EDITOR AND CREATE A NEW ONE, RESET THE SAVE FILE URL
    ///
    ///
    @IBAction func onNewEditor(_ sender:Any?)
        {
        let mutableString = NSMutableAttributedString(string: "",attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
        self.sourceEditor.textStorage?.setAttributedString(mutableString)
        self.resetReporting()
        self.window?.title = "ArgonBrowser [ Untitled.argon ]"
        self.currentSourceFileURL = nil
        }
    ///
    ///
    ///
    /// OPEN AND LOAD A NEW FILE REPLACING THE CONTENTS OF THE EDITOR
    ///
    ///
    @IBAction func onOpenFile(_ sender:Any?)
        {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType("com.macsemantics.argon.source")!]
        panel.canChooseFiles = true
        panel.prompt = "Open"
        panel.message = "Select an Argon source file to be opened in the Argon source editor."
//        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Desktop")
        if panel.runModal() == .OK
            {
            if let url = panel.url,let string = try? String(contentsOf: url)
                {
                self.currentSourceFileURL = url
                let mutableString = NSMutableAttributedString(string: string,attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
                self.sourceEditor.textStorage?.setAttributedString(mutableString)
                self.tokenizer.update(self.sourceEditor.string)
                UserDefaults.standard.setValue(url.absoluteString,forKey: .currentSourceFileURL)
                self.window?.title = "ArgonBrowser [ \(self.currentSourceFileURL!.path) ]"
                _ = Compiler(source: self.sourceEditor.string,reportingContext: self,tokenRenderer: self.tokenizer).compile()
                }
            }
        }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem?
        {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = "Item"
        let image = NSImage(named: "IconClass")
        let button = NSButton(frame: NSRect(x:0,y:0,width: 40,height: 40))
        button.title = ""
        button.image = image
        button.setButtonType(.toggle)
        button.bezelStyle = .rounded
        button.action = #selector(ArgonBrowserWindowController.doButton(_:))
        item.view = button
        return(item)
        }
        
    @IBAction func doButton(_ sender: Any?)
        {
        }
    }

extension ArgonBrowserWindowController
    {
    public func sourceEditorGutter(_ view: LineNumberGutter, selectedAnnotationAtLine line: Int)
        {
        if let group = self.compilationEvents[line]
            {
            let row = self.errorListView.row(forItem: group)
            if row != -1
                {
                self.errorListView.scrollRowToVisible(row)
                self.errorListView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                }
            }
        }
    }
    
public class ForwarderView: NSView
    {
    private var controller: ArgonBrowserWindowController
    
    init(controller: ArgonBrowserWindowController)
        {
        self.controller = controller
        super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    @IBAction func onOpenFile(_ sender: Any?)
        {
        self.controller.onOpenFile(sender)
        }
        
    @IBAction func onSaveFile(_ sender: Any?)
        {
        self.controller.onSaveFile(sender)
        }
        
    @IBAction func onCompileFile(_ sender: Any?)
        {
        self.controller.onCompileFile(sender)
        }
        
    @IBAction func onSaveObject(_ sender: Any?)
        {
        self.controller.onSaveObject(sender)
        }

    @IBAction func onNewEditor(_ sender: Any?)
        {
        self.controller.onNewEditor(sender)
        }
    }
    
extension ArgonBrowserWindowController:NSOutlineViewDelegate,NSOutlineViewDataSource
    {
    @objc public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item == nil
            {
            return(self.compilationEventList.count)
            }
        else
            {
            let event = item as! CompilationEvent
            return(event.childCount)
            }
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.compilationEventList[index])
            }
        else if let event = item as? CompilationEvent
            {
            return(event.child(atIndex: index))
            }
        fatalError()
        }

    @objc public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        if let event = item as? CompilationEvent
            {
            return(event.isExpandable)
            }
        return(false)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView?
        {
        let row = CompilationEventRowView(selectionColor: Palette.shared.hierarchySelectionColor)
        return(row)
        }
        
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
        
        
    public func outlineView(_ outlineView: NSOutlineView,viewFor tableColumn: NSTableColumn?,item: Any) -> NSView?
        {
        if let event = item as? CompilationEvent
            {
            let view = outlineView.makeView(withIdentifier: Self.kCompilationEventCellIdentifier, owner: nil) as! CompilationEventCell
            view.event = event
            return(view)
            }
        return(nil)
        }
    }
