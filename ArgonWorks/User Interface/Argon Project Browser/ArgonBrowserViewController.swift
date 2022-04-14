//
//  ArgonBrowserViewController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/2/22.
//

import Cocoa

public class ArgonBrowserViewController: NSViewController,Dependent
    {
    private let selectedItemValueModel = ValueHolder(value: nil)
    
    @IBOutlet internal var outliner: NSOutlineView!
    @IBOutlet private var toolbar: ToolbarView!
    @IBOutlet internal var leftView: NSView!
    @IBOutlet internal var rightView: NSView!
    
    public let dependentKey = DependentSet.nextDependentKey
    
    private var rootItem: Project = Project(label: "Project")
    private var tokenColors = Dictionary<TokenColor,NSColor>()
    internal var font = NSFont(name: "Menlo",size: 12)!
    public var incrementalParser: IncrementalParser!
    public var sourceOutlinerFont: NSFont!
    private var draggingItems: Array<ProjectItem>?
    internal var buttonBar: ButtonBar!
    private let classesController = Outliner(tag: "classes")
    private let enumerationController = Outliner(tag: "enumerations")
    private let constantsController = Outliner(tag: "constants")
    private let methodsController = Outliner(tag: "methods")
    private let modulesController = Outliner(tag: "modules")
    internal var leftController: Outliner?
    private var baseRowHeight: CGFloat = 14
    private var toolbarHeightConstraint: NSLayoutConstraint!
    private var buttonBarHeightConstraint: NSLayoutConstraint!
    public private(set) var toolbarHeight: CGFloat = 0
    private var fileWrapper: FileWrapper!
    private var browsingContext = BrowsingContext()
    
    public var argonModule: ArgonModule
        {
        self.browsingContext.argonModule
        }
        
    public override func viewDidLoad()
        {
        super.viewDidLoad()
        self.font = NSFont(name: "SunSans-SemiBold",size: 10)!
        self.baseRowHeight = self.font.lineHeight
        self.sourceOutlinerFont = self.font
        self.rootItem.controller = self
        self.outliner.registerForDraggedTypes([.string])
        self.browsingContext.project = self.rootItem
        self.initCompiler()
        self.configureOutlinerMenu()
        self.setProjectLabel()
        self.configureDependencies()
        self.configureToolbar()
        self.configureTabs()
        self.configureOutlinerAndBars()
        self.configureLeftView()
        }
        
    private func initCompiler()
        {
        let (topModule,argonModule) = TopModule.initSystem()
        self.browsingContext.topModule = topModule
        self.browsingContext.argonModule = argonModule
        topModule.addSymbol(self.rootItem.module)
        self.incrementalParser = IncrementalParser()
        self.incrementalParser.topModule = topModule
        self.incrementalParser.argonModule = argonModule
        Token.systemClassNames = self.browsingContext.argonModule.allClasses.map{$0.label}
        }
        
    private func configureToolbar()
        {
        self.toolbarHeight = self.sourceOutlinerFont.lineHeight + 4 + 4 + 2 + 2
        self.toolbarHeightConstraint = self.toolbar.heightAnchor.constraint(equalToConstant: self.toolbarHeight)
        self.toolbarHeightConstraint.isActive = true
        self.outliner.topAnchor.constraint(equalTo: self.toolbar.bottomAnchor).isActive = true
        self.toolbar.target = self
        }
        
    private func configureOutlinerAndBars()
        {
        self.outliner.backgroundColor = Palette.shared.color(for: .recordOutlinerBackgroundColor)
        self.outliner.rowSizeStyle = .custom
        self.outliner.intercellSpacing = NSSize(width: 0, height: 4)
        self.outliner.doubleAction = #selector(self.outlinerDoubleClicked)
        self.outliner.target = self
        self.outliner.style = .plain
        self.outliner.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        self.outliner.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "VersionState"))!.width = 14
        NotificationCenter.default.addObserver(self, selector: #selector(self.outlinerFrameChanged), name: NSOutlineView.frameDidChangeNotification, object: self.outliner)
        NotificationCenter.default.addObserver(self, selector: #selector(self.recordDidExpand), name: NSOutlineView.itemDidExpandNotification, object: self.outliner)
        NotificationCenter.default.addObserver(self, selector: #selector(self.recordDidCollapse), name: NSOutlineView.itemDidCollapseNotification, object: self.outliner)
        self.buttonBar.backgroundColorIdentifier = .barBackgroundColor
        self.toolbar.backgroundColorIdentifier = .barBackgroundColor
        self.outliner.enclosingScrollView!.borderType = .noBorder
        }
        
    private func configureDependencies()
        {
        self.rootItem.addDependent(self)
        var adaptor = Transformer(model: AspectAdaptor(on: self.rootItem, aspect: "warningCount"))
            {
            incoming in
            let total = incoming as! Int
            let string = "\(total) warning\(total == 1 ? "" : "s")"
            return(string)
            }
        self.toolbar.control(atKey: "warnings")!.valueModel = adaptor
        adaptor = Transformer(model: AspectAdaptor(on: self.rootItem, aspect: "errorCount"))
            {
            incoming in
            let total = incoming as! Int
            let string = "\(total) error\(total == 1 ? "" : "s")"
            return(string)
            }
        self.toolbar.control(atKey: "errors")!.valueModel = adaptor
        adaptor = Transformer(model: AspectAdaptor(on: self.rootItem,aspect: "label"))
            {
            incoming in
            let string = incoming as! String
            let label = "Project: Model(\(string))"
            return(label)
            }
        self.toolbar.control(atKey: "name")!.valueModel = adaptor
        adaptor = Transformer(model: AspectAdaptor(on: self.rootItem,aspect: "itemCount"))
            {
            incoming in
            let count = incoming as! Int
            let label = "\(count) item\(count == 1 ? "" : "s")"
            return(label)
            }
        self.toolbar.control(atKey: "records")!.valueModel = adaptor
        adaptor = Transformer(model: self.selectedItemValueModel)
            {
            incoming in
            if let value = incoming as? ProjectItem
                {
                return(value.validActions)
                }
            return(BrowserActionSet(rawValue: 0))
            }
        self.toolbar.enabledValueModel = adaptor
        }
        
    public override func viewDidAppear()
        {
        super.viewDidAppear()
        self.view.window?.title = "Argon Browser [\(self.rootItem.label)]"
        }
        
    public func update(aspect: String,with: Any?,from: Model)
        {
        if aspect == "label" && from.dependentKey == self.rootItem.dependentKey
            {
            self.setProjectLabel()
            }
        if aspect == "value" && from.dependentKey == self.classesController.selectionValueModel.dependentKey
            {
            if let symbolHolder = with as? SymbolHolder,symbolHolder.symbol.itemKey.isNotNil
                {
                if let item = self.rootItem.item(atItemKey: symbolHolder.symbol.itemKey!)
                    {
                    self.outliner.expandItem(item)
                    }
                }
            }
        }
        
    @objc public func outlinerFrameChanged(_ sender: Any?)
        {
        let primaryColumn = outliner.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Primary"))
        let versionStateColumn = outliner.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "VersionState"))
        versionStateColumn?.width = self.baseRowHeight + 10
        primaryColumn?.width = self.outliner.bounds.size.width - (self.baseRowHeight + 25)
        }
        
    private func configureOutlinerMenu()
        {
        let menu = NSMenu()
        self.outliner.menu = menu
        menu.delegate = self
        }
        
    private func configureLeftView()
        {
        self.leftView.wantsLayer = true
        self.leftView.layer?.backgroundColor = Palette.shared.color(for: .defaultSourceOutlinerBackgroundColor).cgColor
        self.classesController.context = .classes
        self.classesController.rootItems = [SymbolHolder(symbol: self.browsingContext.argonModule.object,context: .classes)]
        self.enumerationController.context = .enumerations
        self.enumerationController.rootItems = self.browsingContext.argonModule.allSymbols.compactMap{$0 as? TypeEnumeration}.map{SymbolHolder(symbol: $0,context: .enumerations)}.sorted{$0.label < $1.label}
        self.constantsController.context = .constants
        self.constantsController.rootItems = self.browsingContext.argonModule.allSymbols.compactMap{$0 as? Constant}.map{SymbolHolder(symbol: $0,context: .constants)}.sorted{$0.label < $1.label}
        self.methodsController.context = .methods
        self.methodsController.rootItems = self.browsingContext.argonModule.allSymbols.compactMap{$0 as? Method}.map{SymbolHolder(symbol: $0,context: .methods)}.sorted{$0.label < $1.label}
        self.modulesController.context = .modules
        self.modulesController.rootItems = self.browsingContext.topModule.allSymbols.map{SymbolHolder(symbol: $0,context: .modules)}.sorted{$0.label < $1.label}
        self.classesController.selectionValueModel.addDependent(self)
        self.enumerationController.selectionValueModel.addDependent(self)
        self.modulesController.selectionValueModel.addDependent(self)
        self.methodsController.selectionValueModel.addDependent(self)
        self.classesController.becomeActiveController(inController: self)
        }
        
    private func configureTabs()
        {
        let bar = ButtonBar(frame: .zero)
        self.buttonBar = bar
        bar.appendButton(tag: "classes",image: NSImage(named: "IconClass")!,toolTip: "Show class view",target: self, action: #selector(self.onClassesClicked))
        bar.appendButton(tag: "enumerations",image: NSImage(named: "IconEnumeration")!,toolTip: "Show enumeration view", target: self, action: #selector(self.onEnumerationsClicked))
        bar.appendButton(tag: "constants",image: NSImage(named: "IconConstant")!,toolTip: "Show constants view", target: self, action: #selector(self.onConstantsClicked))
        bar.appendButton(tag: "methods",image: NSImage(named: "IconMethod")!,toolTip: "Show methods view", target: self, action: #selector(self.onMethodsClicked))
        bar.appendButton(tag: "modules",image: NSImage(named: "IconModule")!,toolTip: "Show module view", target: self, action: #selector(self.onModulesClicked))
        bar.translatesAutoresizingMaskIntoConstraints = false
        self.leftView.addSubview(bar)
        bar.leadingAnchor.constraint(equalTo: self.leftView.leadingAnchor).isActive = true
        bar.trailingAnchor.constraint(equalTo: self.leftView.trailingAnchor).isActive = true
        bar.topAnchor.constraint(equalTo: self.leftView.topAnchor).isActive = true
        self.buttonBarHeightConstraint = bar.heightAnchor.constraint(equalToConstant: self.toolbarHeight)
        self.buttonBarHeightConstraint.isActive = true
        }
        
    @IBAction public func onSettings(_ sender: Any?)
        {
        }
        
    @IBAction public func onBuild(_ sender: Any?)
        {
        }
        
    @IBAction public func onLoad(_ sender: Any?)
        {
        }
        
    @IBAction public func onSave(_ sender: Any?)
        {
        }
        
    @IBAction public func onNewSymbol(_ sender: Any?)
        {
       let row = self.outliner.selectedRow
        guard row != -1 else
            {
            NSSound.beep()
            return
            }
        let item = ProjectElementItem(label: "Symbol")
        item.controller = self
        let forItem = self.outliner.item(atRow: row) as! ProjectItem
        forItem.addItem(item)
        let indexSet = IndexSet(integer: max(forItem.childCount-1,0))
        self.outliner.beginUpdates()
        self.outliner.insertItems(at: indexSet, inParent: forItem, withAnimation: .slideDown)
        if !self.outliner.isItemExpanded(forItem)
            {
            self.outliner.expandItem(forItem)
            }
        if !self.outliner.isItemExpanded(item)
            {
            self.outliner.expandItem(item)
            }
        self.outliner.endUpdates()
        }
        
    @IBAction public func onNewGroup(_ sender: Any?)
        {
        let row = self.outliner.selectedRow
        guard row != -1 else
            {
            NSSound.beep()
            return
            }
        let item = ProjectGroupItem(label: "Group")
        item.controller = self
        let forItem = self.outliner.item(atRow: row) as! ProjectItem
        forItem.addItem(item)
        let indexSet = IndexSet(integer: max(forItem.childCount-1,0))
        self.outliner.beginUpdates()
        self.outliner.insertItems(at: indexSet, inParent: forItem, withAnimation: .slideUp)
        self.outliner.endUpdates()
        if !self.outliner.isItemExpanded(forItem)
            {
            self.outliner.expandItem(forItem)
            }
        }
        
    @IBAction public func onNewComment(_ sender: Any?)
        {
        let row = self.outliner.selectedRow
        guard row != -1 else
            {
            NSSound.beep()
            return
            }
        let item = ProjectCommentItem(label: "")
        item.controller = self
        let forItem = self.outliner.item(atRow: row) as! ProjectItem
        forItem.addItem(item)
        let indexSet = IndexSet(integer: max(forItem.childCount-1,0))
        self.outliner.beginUpdates()
        self.outliner.insertItems(at: indexSet, inParent: forItem, withAnimation: .slideDown)
        self.outliner.endUpdates()
        if !self.outliner.isItemExpanded(forItem)
            {
            self.outliner.expandItem(forItem)
            self.outliner.expandItem(item)
            }
        }
        
    @IBAction public func onNewImport(_ sender: Any?)
        {
        let row = self.outliner.selectedRow
        guard row != -1 else
            {
            NSSound.beep()
            return
            }
        let item = ProjectImportItem(label: NSHomeDirectory() + "/SomeModule.armod")
        item.controller = self
        let forItem = self.outliner.item(atRow: row) as! ProjectItem
        forItem.addItem(item)
        let indexSet = IndexSet(integer: max(forItem.childCount-1,0))
        self.outliner.beginUpdates()
        self.outliner.insertItems(at: indexSet, inParent: forItem, withAnimation: .slideDown)
        self.outliner.endUpdates()
        if !self.outliner.isItemExpanded(forItem)
            {
            self.outliner.expandItem(forItem)
            self.outliner.expandItem(item)
            }
        }
        
    @IBAction public func onDeleteItem(_ sender: Any?)
        {
        }
        
    @IBAction public func onSearch(_ sender: Any?)
        {
        }
        
    @IBAction public func onNewModule(_ sender: Any?)
        {
        let row = self.outliner.selectedRow
        guard row != -1 else
            {
            NSSound.beep()
            return
            }
        let item = ProjectModuleItem(label: "Module")
        item.controller = self
        let forItem = self.outliner.item(atRow: row) as! ProjectItem
        forItem.addItem(item)
        let indexSet = IndexSet(integer: max(forItem.childCount-1,0))
        self.outliner.beginUpdates()
        self.outliner.insertItems(at: indexSet, inParent: forItem, withAnimation: .slideDown)
        self.outliner.endUpdates()
        if !self.outliner.isItemExpanded(forItem)
            {
            self.outliner.expandItem(forItem)
            self.outliner.expandItem(item)
            }
        }
        
    @IBAction public func onToggleLeftSidebar(_ sender: Any?)
        {
        }
        
    @IBAction public func onToggleRightSidebar(_ sender: Any?)
        {
        }
        
    @IBAction public func recordDidExpand(_ notification: Notification)
        {
        let record = notification.userInfo!["NSObject"] as! ProjectItem
        record.isExpanded = true
        }
        
    @IBAction public func recordDidCollapse(_ notification: Notification)
        {
        let record = notification.userInfo!["NSObject"] as! ProjectItem
        record.isExpanded = false
        }
        
    @IBAction public func onClassesClicked(_ any: Any?)
        {
        self.leftController?.loseActiveController(inController: self)
        self.classesController.becomeActiveController(inController: self)
        }
        
    @IBAction public func onModulesClicked(_ any: Any?)
        {
        self.leftController?.loseActiveController(inController: self)
        self.modulesController.becomeActiveController(inController: self)
        }
        
    @IBAction public func onEnumerationsClicked(_ any: Any?)
        {
        self.leftController?.loseActiveController(inController: self)
        self.enumerationController.becomeActiveController(inController: self)
        }
        
    @IBAction public func onConstantsClicked(_ any: Any?)
        {
        self.leftController?.loseActiveController(inController: self)
        self.constantsController.becomeActiveController(inController: self)
        }
        
    @IBAction public func onMethodsClicked(_ any: Any?)
        {
        self.leftController?.loseActiveController(inController: self)
        self.methodsController.becomeActiveController(inController: self)
        }
        
    public func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting?
        {
        let theItem = item as! ProjectItem
        if !theItem.isElement
            {
            return(nil)
            }
        let source = (theItem as! ProjectElementItem).sourceRecord.text
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(source,forType: .string)
        return(pasteboardItem)
        }
        
    public func removeSymbolsFromHierarchies(_ symbols: Symbols)
        {
        self.classesController.beginUpdates()
        self.modulesController.beginUpdates()
        self.constantsController.beginUpdates()
        self.enumerationController.beginUpdates()
        self.methodsController.beginUpdates()
        for symbol in symbols
            {
            switch(symbol)
                {
                case is TypeAlias:
                    if (symbol as! TypeAlias).isClassType
                        {
                        self.classesController.removeSymbol(symbol)
                        }
                    else if (symbol as! TypeAlias).isEnumerationType
                        {
                        self.enumerationController.removeSymbol(symbol)
                        }
                    else
                        {
                        fatalError("TypeAlias case not handled.")
                        }
                case is TypeClass:
                    self.classesController.removeSymbol(symbol)
                case is TypeEnumeration:
                    self.enumerationController.removeSymbol(symbol)
                case is Constant:
                    self.constantsController.removeSymbol(symbol)
                case is Method:
                    self.methodsController.removeSymbol(symbol)
                case is Module:
                    break
                default:
                    fatalError("Case not handled \(symbol)")
                }
            self.modulesController.removeSymbol(symbol)
            }
        self.classesController.endUpdates()
        self.modulesController.endUpdates()
        self.constantsController.endUpdates()
        self.enumerationController.endUpdates()
        self.methodsController.endUpdates()
        }
        
    public func insertSymbolsInHierarchies(_ symbols: Symbols)
        {
        self.classesController.beginUpdates()
        self.modulesController.beginUpdates()
        self.constantsController.beginUpdates()
        self.enumerationController.beginUpdates()
        self.methodsController.beginUpdates()
        for symbol in symbols
            {
            switch(symbol)
                {
                case is TypeAlias:
                    if (symbol as! TypeAlias).isClassType
                        {
                        self.classesController.insertSymbol(symbol)
                        }
                    else if (symbol as! TypeAlias).isEnumerationType
                        {
                        self.enumerationController.insertSymbol(symbol)
                        }
                    else
                        {
                        fatalError("TypeAlias case not handled.")
                        }
                case is TypeClass:
                    self.classesController.insertSymbol(symbol)
                case is TypeEnumeration:
                    self.enumerationController.insertSymbol(symbol)
                case is Constant:
                    self.constantsController.insertSymbol(symbol)
                case is Method:
                    self.methodsController.insertSymbol(symbol)
                case is MethodInstance:
                    self.methodsController.insertSymbol(symbol)
                case is Module:
                    break
                default:
                    fatalError("Case not handled \(symbol)")
                }
            self.modulesController.insertSymbol(symbol)
            }
        self.classesController.endUpdates()
        self.modulesController.endUpdates()
        self.constantsController.endUpdates()
        self.enumerationController.endUpdates()
        self.methodsController.endUpdates()
        }
        
    public func setProjectLabel()
        {
        self.rootItem.module.setLabel(self.rootItem.label)
        self.view.window?.title = "Argon Browser [\(self.rootItem.label)]"
        }

    public func loadProject(fromURL url: URL)
        {
        do
            {
            try self.fileWrapper = FileWrapper(url: url,options: [.immediate,.withoutMapping])
            if let mainData = self.fileWrapper.fileWrappers?["main.arbin"]?.regularFileContents
                {
                if let context = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(mainData) as? BrowsingContext
                    {
                    context.topModule.setArgonModule(context.argonModule)
                    context.topModule.patchSymbols()
                    self.browsingContext = context
                    self.rootItem = context.project
                    context.project.setController(self)
                    self.outliner.reloadData()
                    self.configureDependencies()
                    self.classesController.rootItems = context.classesRootItems
                    self.enumerationController.rootItems = context.enumerationsRootItems
                    self.constantsController.rootItems = context.constantsRootItems
                    self.methodsController.rootItems = context.methodsRootItems
                    self.modulesController.rootItems = context.modulesRootItems
                    self.expandExpandedItems()
                    }
                }
            }
        catch let error as NSError
            {
            let alert = NSAlert(error: error)
            alert.alertStyle = .critical
            alert.icon = NSImage(named: "AppIcon")!
            alert.runModal()
            }
        }
        
    private func expandExpandedItems()
        {
        self.rootItem.expandIfNeeded(inOutliner: self.outliner)
        self.classesController.expandItemsIfNeeded()
        self.modulesController.expandItemsIfNeeded()
        self.enumerationController.expandItemsIfNeeded()
        self.methodsController.expandItemsIfNeeded()
        }
    @IBAction func outlinerDoubleClicked(_ any: Any?)
        {
        let row = self.outliner.clickedRow
        guard row != -1 else
            {
            return
            }
        let item = self.outliner.item(atRow: row) as! ProjectItem
        item.doubleClicked(inOutliner: self.outliner)
        }
        
    @IBAction func onNewGroupClicked(_ any: Any?)
        {
        let row = self.outliner.clickedRow
        guard row != -1 else
            {
            NSSound.beep()
            return
            }
        let item = ProjectGroupItem(label: "Group")
        item.controller = self
        let forItem = self.outliner.item(atRow: row) as! ProjectItem
        forItem.addItem(item)
        let indexSet = IndexSet(integer: max(forItem.childCount-1,0))
        self.outliner.beginUpdates()
        self.outliner.insertItems(at: indexSet, inParent: forItem, withAnimation: .slideUp)
        self.outliner.endUpdates()
        if !self.outliner.isItemExpanded(forItem)
            {
            self.outliner.expandItem(forItem)
            }
        }
        
    @IBAction func onDeleteClicked(_ any: Any?)
        {
        let row = self.outliner.clickedRow
        guard row != -1 else
            {
            NSSound.beep()
            return
            }
        let item = self.outliner.item(atRow: row) as! ProjectItem
        let parentItem = item.parentItem!
        if let index = parentItem.index(of: item)
            {
            item.removeFromParent()
            let indexSet = IndexSet(integer: index)
            self.outliner.removeItems(at: indexSet, inParent: parentItem, withAnimation: .slideUp)
            }
        else
            {
            NSSound.beep()
            }
        }
        
    @IBAction func onNewSymbolClicked(_ any: Any?)
        {
        let row = self.outliner.clickedRow
        guard row != -1 else
            {
            NSSound.beep()
            return
            }
        let item = ProjectElementItem(label: "Symbol")
        item.controller = self
        let forItem = self.outliner.item(atRow: row) as! ProjectItem
        forItem.addItem(item)
        let indexSet = IndexSet(integer: max(forItem.childCount-1,0))
        self.outliner.beginUpdates()
        self.outliner.insertItems(at: indexSet, inParent: forItem, withAnimation: .slideUp)
        self.outliner.endUpdates()
        if !self.outliner.isItemExpanded(forItem)
            {
            self.outliner.expandItem(forItem)
            self.outliner.expandItem(item)
            }
        }
        
    @IBAction func onNewModuleClicked(_ any: Any?)
        {
        let row = self.outliner.clickedRow
        guard row != -1 else
            {
            NSSound.beep()
            return
            }
        let item = ProjectModuleItem(label: "Module")
        item.controller = self
        let forItem = self.outliner.item(atRow: row) as! ProjectItem
        forItem.addItem(item)
        let indexSet = IndexSet(integer: max(forItem.childCount-1,0))
        self.outliner.beginUpdates()
        self.outliner.insertItems(at: indexSet, inParent: forItem, withAnimation: .slideUp)
        self.outliner.endUpdates()
        if !self.outliner.isItemExpanded(forItem)
            {
            self.outliner.expandItem(forItem)
            self.outliner.expandItem(item)
            }
        }
        
    @IBAction func onSaveFile(_ any: Any?)
        {
        self.saveProject()
        }
        
    @IBAction func onDeleteFileClicked(_ any: Any?)
        {
        }
        
    @IBAction func onModuleClicked(_ any: Any?)
        {
//        let row = self.outliner.clickedRow
//        guard row != -1 else
//            {
//            return
//            }
//        let item = self.outliner.item(atRow: row) as! BrowserProject
//        item.targetType = .module
//        self.outliner.reloadData()
        }

    @IBAction func onCartonClicked(_ any: Any?)
        {
//        let row = self.outliner.clickedRow
//        guard row != -1 else
//            {
//            return
//            }
//        let item = self.outliner.item(atRow: row) as! BrowserProject
//        item.targetType = .carton
//        self.outliner.reloadData()
        }

    public func saveProject()
        {
        var alert: NSAlert!
        do
            {
            if self.rootItem.hasBeenSavedOnce
                {
                if let wrappers = self.fileWrapper.fileWrappers?.values
                    {
                    for wrapper in wrappers
                        {
                        self.fileWrapper.removeFileWrapper(wrapper)
                        }
                    }
                try self.updateAndWriteProject(self.fileWrapper,to: self.rootItem.url!)
                return
                }
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["arpro"]
            panel.message = "Please select the name and destination for this project."
            panel.nameFieldLabel = "Enter the name of the file"
            panel.nameFieldStringValue = self.rootItem.label
            if panel.runModal() == .OK
                {
                self.rootItem.url = panel.url!
                self.rootItem.hasBeenSavedOnce = true
                self.fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
                try self.updateAndWriteProject(self.fileWrapper,to: self.rootItem.url!)
                return
                }
            }
        catch 
            {
            alert = NSAlert()
            alert.informativeText = "There was an error while serializing the project data."
            alert.messageText = "Unable to save project data."
            }
        catch let error
            {
            alert = NSAlert(error: error)
            }
        alert.icon = NSImage(named: "AppIcon")!
        alert.alertStyle = .critical
        alert.runModal()
        }
        
    private func updateAndWriteProject(_ fileWrapper: FileWrapper,to url: URL) throws
        {
        self.browsingContext.classesRootItems = self.classesController.rootItems as? SymbolHolders
        self.browsingContext.modulesRootItems = self.modulesController.rootItems as? SymbolHolders
        self.browsingContext.constantsRootItems = self.constantsController.rootItems as? SymbolHolders
        self.browsingContext.enumerationsRootItems = self.enumerationController.rootItems as? SymbolHolders
        self.browsingContext.methodsRootItems = self.methodsController.rootItems as? SymbolHolders
        let mainData = NSKeyedArchiver.archivedData(withRootObject: self.browsingContext)
        var wrappers = Dictionary<String,FileWrapper>()
        wrappers["main.arbin"] = FileWrapper(regularFileWithContents: mainData)
        let wrapper = FileWrapper(directoryWithFileWrappers: wrappers)
        do
            {
            try wrapper.write(to: url,options: [.withNameUpdating,.atomic],originalContentsURL: url)
            try FileManager.default.setAttributes([.extensionHidden : true] , ofItemAtPath: url.path)
            }
        catch let error as NSError
            {
            let alert = NSAlert(error: error)
//                alert.informativeText = "ArgonWorks was unable to write out the project data."
//                alert.messageText = "ArgonWorks could not write the serialized project data to disk. Please try again later."
            alert.icon = NSImage(named: "AppIcon")!
            alert.alertStyle = .critical
            alert.runModal()
            return
            }
        }
    }
    
extension ArgonBrowserViewController: NSMenuDelegate
    {
    public func menuNeedsUpdate(_ menu: NSMenu)
        {
        menu.removeAllItems()
        let row = self.outliner.clickedRow
        guard row != -1 else
            {
            return
            }
        let item = self.outliner.item(atRow: row) as! ProjectItem
        item.updateMenu(menu,forTarget: self)
        }
    }

extension ArgonBrowserViewController: NSOutlineViewDelegate
    {
    public func outlineView(_ outlineView: NSOutlineView,heightOfRowByItem item: Any) -> CGFloat
        {
        let entry = item as! ProjectItem
        let width = self.outliner.bounds.size.width
        if entry.height == 0
            {
            entry.height = entry.height(inWidth: width)
            return(entry.height)
            }
        else
            {
            return(entry.height)
            }
        }
    public func outlineViewSelectionDidChange(_ notification: Notification)
        {
        let selectedRow = self.outliner.selectedRow
        if selectedRow == -1
            {
            self.selectedItemValueModel.value = nil
            }
        else
            {
            self.selectedItemValueModel.value = (self.outliner.item(atRow: selectedRow) as? ProjectItem)
            }
        }
        
    public func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool
        {
        return(true)
        }
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
        {
        let entry = item as! ProjectItem
        let view = entry.makeCellView(inOutliner: self.outliner, forColumn: tableColumn!.identifier)
        entry.controller = self
        let row = self.outliner.row(forItem: item)
        let indexSet = IndexSet(integer: row)
        self.outliner.noteHeightOfRows(withIndexesChanged: indexSet)
        return(view)
        }
        
    public func outlineView(_ outlineView: NSOutlineView,rowViewForItem anItem: Any) -> NSTableRowView?
        {
        let view = RowView(selectionColorIdentifier: .recordSelectionColor)
        return(view)
        }
    }
    
extension ArgonBrowserViewController: NSOutlineViewDataSource
    {
    public func outlineView(_ outlineView: NSOutlineView,validateDrop info: NSDraggingInfo,proposedItem item: Any?,proposedChildIndex index: Int) -> NSDragOperation
        {
        if let theItem = item as? ProjectItem
            {
            if theItem.isGroup
                {
                return([.move])
                }
            }
        return([])
        }
        
    public func outlineView(_ outlineView: NSOutlineView,draggingSession session: NSDraggingSession,willBeginAt screenPoint: NSPoint,forItems draggedItems: [Any])
        {
        self.draggingItems = draggedItems.map{$0 as! ProjectItem}
        }
        
    public func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation)
        {
        self.draggingItems = nil
        }
                 
    public func outlineView(_ outlineView: NSOutlineView,acceptDrop info: NSDraggingInfo,item: Any?,childIndex index: Int) -> Bool
        {
        let sourceNode = self.draggingItems![0]
        let sourceParent = self.outliner.parent(forItem: sourceNode) as! ProjectItem
        sourceParent.removeItem(sourceNode)
        let targetParent = item as! ProjectItem
        targetParent.insertItems([sourceNode],atIndex: index)
        let sourceIndex = self.outliner.childIndex(forItem: sourceNode)
        let targetIndex = index == -1 ? 0 : index
        self.outliner.moveItem(at: sourceIndex, inParent: sourceParent, to: targetIndex, inParent: targetParent)
        return(true)
        }
               
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item.isNil
            {
            return(1)
            }
        let element = item as! ProjectItem
        return(element.childCount)
        }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.rootItem)
            }
        else
            {
            let anItem = item as! ProjectItem
            let child = anItem.child(atIndex: index)
            return(child)
            }
        }

    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        let anItem = item as! ProjectItem
        return(anItem.isExpandable)
        }
    }

