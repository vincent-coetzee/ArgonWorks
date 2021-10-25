//
//  EditorViewController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 23/10/21.
//

import Cocoa
import UniformTypeIdentifiers

public class Rectangle: NSObject,NSCoding
    {
    internal let x: CGFloat
    internal let y: CGFloat
    internal let width: CGFloat
    internal let height: CGFloat
    
    init(_ rect: NSRect)
        {
        self.x = rect.minX
        self.y = rect.minY
        self.width = rect.width
        self.height = rect.height
        }
        
    public required init?(coder: NSCoder)
        {
        self.x = coder.decodeDouble(forKey: "x")
        self.y = coder.decodeDouble(forKey: "y")
        self.width = coder.decodeDouble(forKey: "width")
        self.height = coder.decodeDouble(forKey: "height")
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.x,forKey: "x")
        coder.encode(self.y,forKey: "y")
        coder.encode(self.width,forKey: "width")
        coder.encode(self.height,forKey: "height")
        }
    }
    
extension NSRect
    {
    init(_ rectangle: Rectangle)
        {
        self.init(x: rectangle.x,y: rectangle.y,width: rectangle.width,height: rectangle.height)
        }
    }
    
extension UserDefaults
    {
    func rectangle(forKey: String) -> NSRect?
        {
        let x = self.double(forKey: forKey + "x")
        let y = self.double(forKey: forKey + "y")
        let width = self.double(forKey: forKey + "width")
        let height = self.double(forKey: forKey + "height")
        return(NSRect(x:x,y:y,width:width,height: height))
        }
        
    func set(_ rectangle: NSRect,forKey: String)
        {
        self.set(rectangle.minX,forKey: forKey + "x")
        self.set(rectangle.minY,forKey: forKey + "y")
        self.set(rectangle.width,forKey: forKey + "width")
        self.set(rectangle.height,forKey: forKey + "height")
        }
    }
    
class EditorViewController: NSViewController,SourceEditorDelegate,ReportingContext,NSWindowDelegate
    {
    private static let kWindowFrameKey = "EditorViewControllerWindowFrame"
    private static let kWindowURLKey = "EditorViewControllerWindowURL"
    
    @IBOutlet var topBar: NSView!
    @IBOutlet var bottomBar: NSView!
    @IBOutlet var editorView: LineNumberTextView!
    @IBOutlet var topLeftText: NSTextField!
    @IBOutlet var topRightText: NSTextField!
    @IBOutlet var bottomLeftText: NSTextField!
    @IBOutlet var bottomRightText: NSTextField!
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet var outliner: NSOutlineView!
    
    private var tokenizer: VisualTokenizer!
    private var currentSourceFileURL: URL?
    private var fileItems = FileItems()
    private var currentItem = PackageItem(name: "Current", path: "/", date: Date())
    private var warningItem = WarningGroupItem()
    private var issues = Array<IssueItem>()
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.initViews()
        self.initEditing()
        }

    override func viewDidAppear()
        {
        super.viewDidAppear()
        self.view.window?.delegate = self
        let defaults = UserDefaults.standard
        if let rectangle = defaults.rectangle(forKey: Self.kWindowFrameKey)
            {
            self.view.window!.setFrame(rectangle,display: true,animate: true)
            }
        if let name = defaults.string(forKey: Self.kWindowURLKey)
            {
            self.currentSourceFileURL = URL(string: name)
            if let url = currentSourceFileURL,let string = try? String(contentsOf: url)
                {
                self.resetReporting()
                let mutableString = NSMutableAttributedString(string: string,attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
                self.editorView.textStorage?.setAttributedString(mutableString)
                self.tokenizer.update(self.editorView.string)
                self.view.window?.title = "ArgonBrowser [ \(self.currentSourceFileURL!.path) ]"
                let node = Compiler(source: self.editorView.string,reportingContext: self,tokenRenderer: self.tokenizer).compile()
                self.currentItem.appendItem(SymbolItem(symbol: node as! Symbol))
                self.outliner.reloadData()
                self.updateStatusBar("LOADED \(self.currentSourceFileURL!.path)")
                }
            }
        }
        
    public func windowWillResize(_ window: NSWindow,to size: NSSize) -> NSSize
        {
        if UserDefaults.standard.rectangle(forKey: Self.kWindowFrameKey).isNil
            {
            UserDefaults.standard.set(self.view.window!.frame,forKey: Self.kWindowFrameKey)
            }
        var frame = self.view.window!.frame
        frame.size = size
        UserDefaults.standard.set(frame,forKey: Self.kWindowFrameKey)
        return(size)
        }
        
    public func windowWillClose(_ notification: Notification)
        {
        UserDefaults.standard.set(self.view.window!.frame,forKey: Self.kWindowFrameKey)
        UserDefaults.standard.set(self.currentSourceFileURL?.absoluteString,forKey: Self.kWindowURLKey)
        }
        
    private func initViews()
        {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.black.cgColor
        self.topBar.wantsLayer = true
        self.topBar.layer?.backgroundColor = self.editorView.backgroundColor.cgColor
        self.editorView.sourceEditorDelegate = self
        self.topLeftText.stringValue = "LOADED..."
        self.topRightText.stringValue = ""
        self.bottomRightText.stringValue = ""
        self.currentItem.appendItem(self.warningItem)
        self.outliner.register(NSNib(nibNamed: "FileItemCellView", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileItemCellView"))
        self.outliner.rowHeight = 24
        self.outliner.indentationPerLevel = 30
        self.outliner.intercellSpacing = CGSize(width: 0,height: 0)
        self.currentItem.appendItem(SourceItem(name:"LogicA",path: "/A/B"))
        self.currentItem.appendItem(SourceItem(name:"Reasoning",path: "/A/B"))
        self.currentItem.appendItem(SourceItem(name:"Exploits",path: "/A/B"))
        }
        
    private func updateStatusBar(_ text: String)
        {
        self.topRightText.stringValue = Date.dateFormatter.string(from: Date())
        self.topLeftText.stringValue = text
        }
        
    private func initEditing()
        {
        self.tokenizer = VisualTokenizer(lineNumberView: self.editorView,reportingContext: self)
        self.editorView.gutterBackgroundColor = NSColor.black
        self.editorView.backgroundColor = NSColor.black
        self.editorView.gutterForegroundColor = NSColor.lightGray
        self.editorView.isAutomaticQuoteSubstitutionEnabled = false
        self.editorView.isAutomaticDashSubstitutionEnabled = false
        self.editorView.isAutomaticTextReplacementEnabled = false
        self.editorView.selectionHighlightColor = Palette.shared.sourceSelectedLineHighlightColor
        }
        
    private func scrollToLineNumber(_ line: Int)
        {
        self.editorView.scrollToLine(line)
        }
        
    public func status(_ string: String)
        {
        self.topLeftText.stringValue = string
        }
        
    public func dispatchWarning(at: Location, message: String)
        {
        var found = false
        for issue in self.issues
            {
            if issue.line == at.line
                {
                found = true
                issue.appendSubissue(message: message)
                }
            }
        if !found
            {
            let issue = IssueItem(line: at.line, message: message)
            self.issues.append(issue)
            self.warningItem.appendIssue(issue)
            }
        self.warningItem.sort()
        self.outliner.reloadData()
        self.refreshSourceAnnotations()
        }
    
    public func dispatchError(at: Location, message: String)
        {
        var found = false
        for issue in self.issues
            {
            if issue.line == at.line
                {
                found = true
                issue.appendSubissue(message: message)
                }
            }
        if !found
            {
            let issue = IssueItem(line: at.line, message: message)
            self.issues.append(issue)
            self.warningItem.appendIssue(issue)
            }
        self.warningItem.sort()
        self.outliner.reloadData()
        self.refreshSourceAnnotations()
        }
    
    public func resetReporting()
        {
        self.currentItem = PackageItem(name: "Current", path: "/", date: Date())
        self.issues = []
        self.warningItem = WarningGroupItem()
        self.currentItem.appendItem(self.warningItem)
        self.editorView.removeAllAnnotations()
        self.outliner.reloadData()
        }
        
    public func refreshSourceAnnotations()
        {
        self.editorView.removeAllAnnotations()
        for value in self.issues
            {
            let annotation = LineAnnotation(line: value.line, icon: NSImage(named: "IconLineMarkerYellow2")!)
            self.editorView.addAnnotation(annotation)
            }
        }
        
    func sourceEditorGutter(_ view: LineNumberGutter, selectedAnnotationAtLine line: Int)
        {
        var rowSet = IndexSet()
        for issue in self.issues
            {
            if issue.line == line && issue.line != -1
                {
                let row = self.outliner.row(forItem: issue)
                if row != -1
                    {
                    rowSet.insert(row)
                    }
                }
            }
        self.outliner.selectRowIndexes(rowSet, byExtendingSelection: false)
        }
    
    func sourceEditorKeyPressed(_ editor: LineNumberTextView)
        {
        
        }
    
    func sourceEditor(_ editor: LineNumberTextView,changedLine: Int,offset: Int)
        {
        let lineString = String(format: "Line %d",changedLine)
        let offsetString = String(format: "column %d",offset)
        self.bottomRightText.stringValue = "\(lineString) \(offsetString)"
        }
    
    @IBAction func onNewFile(_ sender: Any?)
        {
        let mutableString = NSMutableAttributedString(string: "",attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
        self.editorView.textStorage?.setAttributedString(mutableString)
        self.resetReporting()
        self.view.window?.title = "Argon Editor [ Untitled.argon ]"
        self.currentSourceFileURL = nil
        }
        
    @IBAction func onOpenFile(_ sender: Any?)
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
                self.resetReporting()
                self.currentSourceFileURL = url
                let mutableString = NSMutableAttributedString(string: string,attributes: [.font: NSFont(name: "Menlo",size: 11)!,.foregroundColor: NSColor.lightGray])
                self.editorView.textStorage?.setAttributedString(mutableString)
                self.tokenizer.update(self.editorView.string)
//                UserDefaults.standard.setValue(url.absoluteString,forKey: .currentSourceFileURL)
                self.view.window?.title = "ArgonBrowser [ \(self.currentSourceFileURL!.path) ]"
                let node = Compiler(source: self.editorView.string,reportingContext: self,tokenRenderer: self.tokenizer).compile()
                self.currentItem.appendItem(SymbolItem(symbol: node as! Symbol))
                let named = (node as! Symbol).allNamedInvokables
                for item in named
                    {
                    self.currentItem.appendItem(InvokableItem(invokable: item))
                    }
                self.outliner.reloadData()
                self.updateStatusBar("LOADED \(self.currentSourceFileURL!.path)")
                }
            }
        }
        
    @IBAction func onSaveFile(_ sender: Any?)
        {
        let text = self.editorView.textStorage!.string
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
        panel.message = "Select where the editor should save the Argon source."
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Desktop")
        if panel.runModal() == .OK,let url = panel.url
            {
            try? text.write(to: url, atomically: false, encoding: .utf8)
//            UserDefaults.standard.setValue(url.absoluteString,forKey: .currentSourceFileURL)
            self.currentSourceFileURL = url
            self.view.window?.title = "Argon Editor [ \(self.currentSourceFileURL!.path) ]"
            self.updateStatusBar("SAVED FILE \(url.absoluteString)")
            }
        }
        
    @IBAction func onSaveObjectFile(_ sender: Any?)
        {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType("com.macsemantics.argon.object")!]
        panel.prompt = "Save Object"
        panel.message = "Select where the compiler should save the object file."
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
                let aCompiler = Compiler(source: self.editorView.string,reportingContext: NullReportingContext.shared,tokenRenderer: NullTokenRenderer())
                if let module = aCompiler.compile() as? Module
                    {
                    do
                        {
                        let objectFile = ObjectFile(filename: theUrl.absoluteString,module: module,root: aCompiler.topModule,date: Date(), version: SemanticVersion(major: 1, minor: 0, patch: 0))
//                        let exporter = ImportArchiver(requiringSecureCoding: false, swapSystemSymbols: true, swapImportedSymbols: true)
                        ImportArchiver.isSwappingSystemSymbols = true
                        let data = try ImportArchiver.archivedData(withRootObject: objectFile, requiringSecureCoding: false)
                        try data.write(to: theUrl)
//                        print("\(exporter.swappedSystemSymbolNames.count) system symbols swapped.")
//                        print("\(exporter.swappedImportedSymbolNames.count) imported symbols swapped.")
//                        let data = NSKeyedArchiver.archivedData(withRootObject: objectFile)
//                        try! data.write(to: theUrl)
                        let newData = try Data(contentsOf: theUrl)
                        ImportUnarchiver.topModule = TopModule.shared.clone()
                        let result = try ImportUnarchiver.unarchiveTopLevelObjectWithData(newData)
//                        let importer = try! NSKeyedUnarchiver(forReadingFrom: newData)
//                        let result = importer.decodeObject(forKey: "root")
                        print(result!)
                        self.updateStatusBar("SAVED OBJECT FILE \(theUrl.absoluteString)")
                        }
                    catch let error
                        {
                        print(error)
                        let alert = NSAlert()
                        alert.icon = NSImage(named: "ObjectIcon")!
                        alert.messageText = "Object writing error."
                        alert.informativeText = "An error occured while writing the object file for this Argon module out to disk."
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
        
    @IBAction func onCompileFile(_ sender: Any?)
        {
        let source = self.editorView.string
        self.resetReporting()
        if let node = Compiler(source: source,reportingContext: self,tokenRenderer: self.tokenizer).compile()
            {
            let named = (node as! Symbol).allNamedInvokables
            for item in named
                {
                self.currentItem.appendItem(InvokableItem(invokable: item))
                }
            self.outliner.reloadData()
            }
        }
    }

extension EditorViewController:NSOutlineViewDelegate,NSOutlineViewDataSource
    {
    @objc public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item == nil
            {
            return(1)
            }
        else
            {
            let item = item as! FileItem
            return(item.childCount)
            }
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat
        {
        return(20)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.currentItem)
            }
        else if let event = item as? FileItem
            {
            return(event.child(atIndex: index))
            }
        fatalError()
        }

    @objc public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        if let event = item as? FileItem
            {
            return(event.isExpandable)
            }
        return(false)
        }
        
    @objc public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView?
        {
        return(nil)
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
        let row = self.outliner.selectedRow
        if row != -1
            {
            if let item = self.outliner.item(atRow: row) as? FileItem,item.isIssue,let line = item.lineNumber
                {
                self.scrollToLineNumber(line)
                }
            }
        }
        
        
    public func outlineView(_ outlineView: NSOutlineView,viewFor tableColumn: NSTableColumn?,item: Any) -> NSView?
        {
        if let event = item as? FileItem
            {
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileItemCellView"), owner: nil) as! FileItemCellView
            event.configure(cell: view)
            return(view)
            }
        return(nil)
        }
    }
