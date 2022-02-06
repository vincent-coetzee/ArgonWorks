//
//  CompilerBrowserController.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/2/22.
//

import Cocoa

public protocol ModuleReceiver
    {
    func moduleUpdated(_ module: Module)
    }
    
class CompilerBrowserController: NSViewController,ModuleReceiver
    {
    @IBOutlet weak var outliner: NSOutlineView!
    
    private var module: Module!
    
    override func viewDidLoad()
        {
        super.viewDidLoad()
        self.outliner.register(NSNib(nibNamed: "CompilerSymbolCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CompilerSymbolCell"))
        self.outliner.dataSource = self
        self.outliner.delegate = self
        let source = try! String(contentsOfFile: "/Users/vincent/Desktop/InferenceTester.argon")
        let compiler = Compiler(source: source,reportingContext: NullReporter(),tokenRenderer: NullTokenRenderer())
        compiler.compile(parseOnly: false, moduleReceiver: self)
        }
        
    public func moduleUpdated(_ module: Module)
        {
        self.module = module
        self.outliner.reloadData()
        }
    }

extension CompilerBrowserController: NSOutlineViewDataSource
    {
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
        {
        if item.isNil
            {
            return(self.module?.symbols.count ?? 0)
            }
        else
            {
            return((item as! OutlineItem).childOutlineItemCount)
            }
        }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
        {
        if item.isNil
            {
            return(self.module.symbols[index])
            }
        else
            {
            return((item as! OutlineItem).childOutlineItem(atIndex: index))
            }
        }

    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
        {
        (item as! OutlineItem).isOutlineItemExpandable
        }
    }

extension CompilerBrowserController: NSOutlineViewDelegate
    {
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
        {
        let cell = self.outliner.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CompilerSymbolCell"), owner: nil) as! CompilerSymbolCell
        cell.outlineItem = (item as! OutlineItem)
        return(cell)
        }
    }
