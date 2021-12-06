//
//  AppDelegate.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/8/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate
    {
    func applicationDidFinishLaunching(_ aNotification: Notification)
        {
//        let families = NSFontManager.shared.availableFontFamilies.sorted{$0 < $1}
//        for family in families
//            {
//            print("\(family)")
//            if let fonts = NSFontManager.shared.availableMembers(ofFontFamily: family)
//                {
//                for items in fonts
//                    {
//                    let array = items as! NSArray
//                    let name = array[0]
//                    print("\t\(name)")
//                    }
//                }
//            }
//        let source = try! String(contentsOfFile: "/Users/vincent/Desktop/Argon.Base.Primitives.argon")
//        let compiler = Compiler(source: source,reportingContext: NullReportingContext.shared,tokenRenderer: NullTokenRenderer.shared)
//        compiler.compile()
        let type1 = TypeVariable(index: 2000)
        let type2 = TypeVariable(index: 2000)
        assert(type1 == type2,"Type1 should == type2")
        let type3 = TypeVariable(index: 2001)
        assert(type1 != type3,"Type3 should not == type1")
        let compiler = Compiler()
        let items = compiler.argonModule.lookupN(label: "-")
        print(items)
        let type = compiler.argonModule.lookup(label: "Void") as! Type
        print(type.fullName.displayString)
        let slot1 = Slot(label: "slot1",type: compiler.argonModule.integer)
        let slot2 = Slot(label: "slot2",type: compiler.argonModule.string)
        let tuple1 = Tuple(.slot(slot1),.slot(slot2))
        do
            {
            let context = TypeContext(scope: compiler.argonModule)
            try tuple1.initializeType(inContext: context)
            print(tuple1.type.displayString)
            let slot1Expression = SlotExpression(slot: slot1)
            let slot2Expression = SlotExpression(slot: slot2)
            let right1Expression = LiteralExpression(.integer(10))
            let right2Expression = LiteralExpression(.string("hello"))
            let assignmentExpression = AssignmentExpression(TupleExpression(slot1Expression,slot2Expression),TupleExpression(right1Expression,right2Expression))
            try assignmentExpression.initializeType(inContext: context)
            print(assignmentExpression.lhs.type!.displayString)
            print(assignmentExpression.rhs.type!.displayString)
            }
        catch let error
            {
            print(error)
            }
        }

    func applicationWillTerminate(_ aNotification: Notification)
        {
        // Insert code here to tear down your application
        }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool
        {
        return true
        }
        
    @IBAction
    public func openProcessorBrowser(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "ProcessorWindowController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
        
    @IBAction
    public func openMemoryBrowser(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "MemoryWindowController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
        
    @IBAction
    public func openArgonBrowser(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "ArgonBrowserWindowController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
        
    @IBAction
    public func openHierarchyBrowser(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "ArgonHierarchyController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
        
    @IBAction
    public func openSymbolBrowser(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "ArgonSymbolController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
        
    @IBAction
    public func openSemanticBrowser(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "ArgonSemanticController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
        
    @IBAction
    public func openObjectInspector(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "ObjectInspectorController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
        
    @IBAction
    public func openRunner(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "ArgonRunner") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
    }

