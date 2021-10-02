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
    
class ArgonBrowserWindowController: NSWindowController,NSWindowDelegate,NSToolbarDelegate,ReportingContext,NSTableViewDataSource,NSTableViewDelegate
    {
    @IBOutlet var toolbar: NSToolbar!
    @IBOutlet var splitViewController: NSSplitViewController!
    internal var classBrowser: NSOutlineView!
    internal var methodBrowser: NSOutlineView!
    
    internal var objectBrowser: NSOutlineView!
        {
        didSet
            {
            self.initObjectBrowser()
            }
        }
    
    private var errorListView: NSTableView!
    
    internal var symbolList1: SymbolList!
    internal var symbolList2: SymbolList!
    internal var symbolList3: SymbolList!
    
    private var symbols: Array<Symbol> = []
    private var compiler: Compiler! = nil
    private var currentSourceFileURL:URL? = nil
    private var currentSymbolFileURL:URL? = nil
    private var compilationEvents: Array<CompilationEvent> = []
    private var forwarderView: ForwarderView?
    private var firstFrame: NSRect? = nil
    
    public var capsules: Dictionary<URL,Capsule> = [:]
    public var currentCapsule: Capsule?
    public var selectedFont: NSFont?
    
    public var sourceEditor: LineNumberTextView!
        {
        didSet
            {
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
        
    override func windowDidLoad()
        {
        super.windowDidLoad()
        self.compiler = Compiler()
        self.window?.setFrame(self.firstFrame!, display: true, animate: true)
        let frame = self.firstFrame!
        let rectObject = RectObject(frame)
        rectObject.setValue(forKey: UserDefaultsKey.browserWindowRectangle.rawValue,on: UserDefaults.standard)
        self.window!.styleMask = [.resizable, .titled, .closable]
        NotificationCenter.default.addObserver(self, selector: #selector(sourceChangedNotification(_:)), name: NSText.didChangeNotification, object: self.sourceEditor)
        NotificationCenter.default.addObserver(self, selector: #selector(windowResizedNotification(_:)), name: NSWindow.didResizeNotification, object: self.window)
        self.window!.delegate = self
        self.toolbar.validateVisibleItems()
        let content = self.window!.contentView
        let splitView = content!.subviews[0] as! NSSplitView
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
        
    @IBAction public func sourceChangedNotification(_ event:NSNotification)
        {
        do
            {
            self.resetReporting()
            Transaction.abort()
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
        self.compilationEvents.append(.warning(at,message))
        self.errorListView?.reloadData()
        }
    
    public func dispatchError(at: Location, message: String)
        {
        self.compilationEvents.append(.error(at,message))
        self.errorListView?.reloadData()
        self.refreshSourceAnnotations()
        }
    
    private func resetReporting()
        {
        self.compilationEvents = []
        self.errorListView?.reloadData()
        self.sourceEditor.removeAllAnnotations()
        }
        
    public func refreshSourceAnnotations()
        {
        self.sourceEditor.removeAllAnnotations()
        for event in self.compilationEvents
            {
            switch(event)
                {
                case .warning(let location,_):
                    let annotation = LineAnnotation(line: location.line, icon: NSImage(named: "IconLineMarker")!)
                    self.sourceEditor.addAnnotation(annotation)
                case .error(let location,_):
                    let annotation = LineAnnotation(line: location.line, icon: NSImage(named: "IconLineMarker")!)
                    self.sourceEditor.addAnnotation(annotation)
                default:
                    break
                }
            }
        }
        
    public func numberOfRows(in tableView: NSTableView) -> Int
        {
        return(self.compilationEvents.count)
        }
        
    @objc func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
        {
        if tableColumn!.identifier == NSUserInterfaceItemIdentifier(rawValue: "0")
            {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CompilationEventImageCellView"),owner: nil) as? CompilationEventImageCellView
                {
                cell.iconView.image = self.compilationEvents[row].icon
                cell.iconView.image?.isTemplate = true
                cell.iconView.contentTintColor = self.compilationEvents[row].tintColor
                return(cell)
                }
            }
        else
            {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CompilationEventCellView"),owner: nil) as? CompilationEventCellView
                {
                cell.event = self.compilationEvents[row]
                return(cell)
                }
            }
        return(nil)
        }

    @objc func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView?
        {
        let event = self.compilationEvents[row]
        return(HierarchyRowView(selectionColor: event.selectionColor))
        }
        
    @objc func tableView(_ tableView: NSTableView,shouldSelectRow row: Int) -> Bool
        {
        let selectedRow = self.errorListView.selectedRow
        guard selectedRow != -1 else
            {
            return(true)
            }
        if let view = self.errorListView.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? CompilationEventCellView
            {
            view.makeUnhighlighted()
            }
        return(true)
        }
        
    @objc func tableViewSelectionDidChange(_ notification: Notification)
        {
        let selectedRow = self.errorListView.selectedRow
        guard selectedRow != -1 else
            {
            return
            }
        if let view = self.errorListView.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? CompilationEventCellView
            {
            view.makeHighlighted()
            }
        let item = self.compilationEvents[selectedRow]
        if let line = item.lineNumber
            {
            self.sourceEditor.highlight(line: line)
            }
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
        for item in self.toolbar.items
            {
            if item.label == "Open"
                {
                item.target = self.forwarderView!
                item.action = #selector(ForwarderView.onOpenFile(_:))
                item.isEnabled = true
                }
            else if item.label == "Compile"
                {
                item.target = self.forwarderView!
                item.action = #selector(ForwarderView.onCompileFile(_:))
                item.isEnabled = true
                }
            else if item.label == "Save"
                {
                item.target = self.forwarderView!
                item.action = #selector(ForwarderView.onSaveFile(_:))
                item.isEnabled = true
                }
            else if item.label == "Fonts"
                {
//                item.target = self.forwarderView!
//                item.action = #selector(ForwarderView.onSaveFile(_:))
                item.isEnabled = true
                }
            else if item.label == "New"
                {
                item.target = self.forwarderView!
                item.action = #selector(ForwarderView.onNewEditor(_:))
                item.isEnabled = true
                }
//            else if item.label == "Object"
//                {
//                item.target = self.forwarderView!
//                item.action = #selector(ForwarderView.onSaveObject(_:))
//                item.isEnabled = true
//                }
            else if item.label == "Symbols"
                {
                item.target = self.forwarderView!
                item.action = #selector(ForwarderView.onSaveSymbols(_:))
                item.isEnabled = true
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
            self.resetReporting()
            self.compiler = Compiler()
            self.compiler.reportingContext = self
            self.compiler.compileChunk(string)
            self.sourceEditor.textStorage?.beginEditing()
            for (range,attributes) in self.compiler.tokenRenderer.attributes
                {
                self.sourceEditor.textStorage?.setAttributes(attributes,range: range)
                }
            self.sourceEditor.textStorage?.endEditing()
            let style = NSMutableParagraphStyle()
            style.headIndent = 400
            style.firstLineHeadIndent = 400
            var attributes:Dictionary<NSAttributedString.Key,Any> = [:]
            attributes[.paragraphStyle] = style
            style.addTabStop(NSTextTab(textAlignment: .left, location: 50, options: [:]))
            style.addTabStop(NSTextTab(textAlignment: .left, location: 100, options: [:]))
            style.addTabStop(NSTextTab(textAlignment: .left, location: 150, options: [:]))
            style.addTabStop(NSTextTab(textAlignment: .left, location: 200, options: [:]))
            style.addTabStop(NSTextTab(textAlignment: .left, location: 400, options: [:]))
            style.addTabStop(NSTextTab(textAlignment: .left, location: 500, options: [:]))
            let count = self.sourceEditor.string.count
            let storage = self.sourceEditor.textStorage
            storage?.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: count))
            self.sourceEditor.typingAttributes = attributes
            self.toolbar.delegate = self
            self.window?.title = "ArgonBrowser [ \(self.currentSourceFileURL!.path) ]"
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
        var nib = NSNib(nibNamed: "CompilationEventCellView", bundle: nil)
        self.errorListView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CompilationEventCellView"))
        nib = NSNib(nibNamed: "CompilationEventImageCellView", bundle: nil)
        self.errorListView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CompilationEventImageCellView"))
        self.errorListView.rowHeight = 64
        self.errorListView.intercellSpacing = NSSize(width: 0,height: 2)
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
                self.currentSourceFileURL = url
                self.window?.title = "ArgonBrowser [ \(self.currentSourceFileURL!.path) ]"
                }
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
        let path = "/Users/vincent/Desktop/Library.c"
        let selectedRow = self.objectBrowser.selectedRow
        let selectedItem = objectBrowser.item(atRow: selectedRow)
        if let elementHolder = selectedItem as? ElementHolder,let library = elementHolder.symbol as? LibraryModule
            {
            let mangler = NameMangler()
            let file = fopen(path,"wt")
            for function in library.functions
                {
                let name = mangler.mangle(function)
                var string = "\t\(function.returnType.nativeCType.displayString) \(name)" + "("
                let strings = function.parameters.map{"\($0.type.nativeCType.displayString) \($0.label)"}.joined(separator: ",") + ")"
                string += strings
                string += "\n"
                string += "\t{\n\t}\n\n"
                fputs(string,file)
                }
            fflush(file)
            fclose(file)
            }
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
        panel.directoryURL = URL(fileURLWithPath: "/Users/vincent/Desktop")
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
    @IBAction func onSaveSymbols(_ sender:Any?)
        {
        if self.currentSymbolFileURL.isNil
            {
            let panel = NSSavePanel()
            panel.allowedContentTypes = [UTType("com.macsemantics.argon.symbols")!]
            panel.prompt = "Save"
            panel.message = "Select where the compiler must save the symbols from the compilation."
            panel.directoryURL = URL(fileURLWithPath: "/Users/vincent/Desktop")
            if panel.runModal() == .OK
                {
                if let theUrl = panel.url
                    {
                    self.currentSymbolFileURL = theUrl
                    let source = self.sourceEditor.string
                    self.compiler = Compiler()
                    if let chunk = self.compiler.compileChunk(source)
                        {
                        do
                            {
                            let data = try NSKeyedArchiver.archivedData(withRootObject: chunk, requiringSecureCoding: false)
                            try data.write(to: theUrl)
                            let newData = try Data(contentsOf: theUrl)
                            let result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(newData)
                            print(result)
                            }
                        catch let error
                            {
                            print(error)
                            let alert = NSAlert()
                            alert.icon = NSImage(named: "SymbolsIcon")!
                            alert.messageText = "Symbol writing error."
                            alert.informativeText = "An error occured while writing the symbols for this Argon module out to disk."
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
        let compiler = Compiler()
        self.resetReporting()
        compiler.reportingContext = self
        Transaction.abort()
        if let chunk = compiler.compileChunk(source)
            {
            let transaction = Transaction.current.copy()
            Transaction.commit()
            TopModule.shared.printContents()
            self.currentCapsule?.with(source: source, product: chunk, transaction: transaction)
            if let module = chunk as? Module
                {
                module.realizeSuperclasses()
                self.symbolList1.symbols = [TopModule.shared.argonModule.object]
                self.symbolList2.symbols = [TopModule.shared]
                self.symbolList3.symbols = [TopModule.shared.moduleRoot]
                }
            }
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
        Transaction.abort()
        self.resetReporting()
        self.compiler = Compiler()
        self.compiler.reportingContext = self
        self.currentSourceFileURL = nil
        self.window?.title = "ArgonBrowser [ Untitled.argon ]"
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
        panel.directoryURL = URL(fileURLWithPath: "/Users/vincent/Desktop")
        if panel.runModal() == .OK
            {
            if let url = panel.url,let string = try? String(contentsOf: url)
                {
                self.currentSourceFileURL = url
                let mutableString = NSMutableAttributedString(string: string,attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
                self.sourceEditor.textStorage?.setAttributedString(mutableString)
                self.resetReporting()
                self.compiler = Compiler()
                self.compiler.reportingContext = self
                self.compiler.compileChunk(string)
                self.sourceEditor.textStorage?.beginEditing()
                for (range,attributes) in self.compiler.tokenRenderer.attributes
                    {
                    self.sourceEditor.textStorage?.setAttributes(attributes,range: range)
                    }
                self.sourceEditor.textStorage?.endEditing()
                UserDefaults.standard.setValue(url.absoluteString,forKey: .currentSourceFileURL)
                let capsule = Capsule(path: url)
                self.capsules[capsule.path] = capsule
                self.currentCapsule = capsule
                self.window?.title = "ArgonBrowser [ \(self.currentSourceFileURL!.path) ]"
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
        
    @IBAction func onSaveSymbols(_ sender: Any?)
        {
        self.controller.onSaveSymbols(sender)
        }

    @IBAction func onNewEditor(_ sender: Any?)
        {
        self.controller.onNewEditor(sender)
        }
    }
