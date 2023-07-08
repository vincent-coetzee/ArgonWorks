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
        TopModule.resetTopModule()
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
        let compiler:Compiler? = Compiler(source: "", reportingContext: NullReporter.shared, tokenRenderer: NullTokenRenderer.shared)
        let items = ArgonModule.shared.lookupN(label: "-")
        print(items)
        let type = ArgonModule.shared.lookup(label: "Void") as! Type
        print(type.fullName.displayString)
        let slot1 = Slot(label: "slot1",type: ArgonModule.shared.integer)
        let slot2 = Slot(label: "slot2",type: ArgonModule.shared.string)
        let tuple1 = Tuple(.slot(slot1),.slot(slot2))
        let context = TypeContext()
        tuple1.initializeType(inContext: context)
        print(tuple1.type.displayString)
        let slot1Expression = SlotExpression(slot: slot1)
        let slot2Expression = SlotExpression(slot: slot2)
        let right1Expression = LiteralExpression(.integer(10))
        let right2Expression = LiteralExpression(.string(StaticString(string: "hello")))
        let assignmentExpression = AssignmentExpression(TupleExpression(slot1Expression,slot2Expression),TupleExpression(right1Expression,right2Expression))
        assignmentExpression.initializeType(inContext: context)
        print(assignmentExpression.lhs.type.displayString)
        print(assignmentExpression.rhs.type.displayString)
        let pointer = Word(object: 0)
        print(pointer.bitString)
        let object = ArgonModule.shared.object
        var allocator:AddressAllocator? = AddressAllocator(compiler!)
        ArgonModule.shared.layoutObjectSlots()
//        object.printLayout()
//        let array = ArgonModule.shared.array
//        array.printLayout()
//        let aClass = ArgonModule.shared.class
//        aClass.printLayout()
//        let string = ArgonModule.shared.string
//        string.printLayout()
//        let enumeration = ArgonModule.shared.enumeration
//        enumeration.printLayout()
//        let module = ArgonModule.shared.moduleType
//        module.printLayout()
        Header.test()
        Word.testWord()
        print("Size of Int is \(MemoryLayout<Int>.size)")
        StackSegment.testStackSegment()
        allocator = nil
        let payload = VMPayload()
        let symbol1 = "symbol1"
        let symbol1Handle = payload.symbolRegistry.registerSymbol(symbol1)
        print("SYMBOL1 = \(symbol1Handle)")
        let symbol2 = "this-is-a-symbol"
        let symbol2Handle = payload.symbolRegistry.registerSymbol(symbol2)
        print("SYMBOL2 = \(symbol2Handle)")
        let symbol3 = "symbol1"
        let symbol3Handle = payload.symbolRegistry.registerSymbol(symbol3)
        print("SYMBOL3 = \(symbol3Handle)")
        
        let module1 = Module(label: "module1")
        let module2 = Module(label: "module2")
        let class1 = TypeClass(label: "class1")
        let class2 = TypeClass(label: "class2")
        module1.setContainer(.symbol(TopModule.shared))
        module1.addSymbol(module2)
        module2.addSymbol(class1)
        module1.addSymbol(class2)
        assert(module1.lookup(name: Name("\\\\Argon\\Array")).isNotNil)
        assert(module1.lookup(label: "module2").isNotNil)
        assert(module2.lookup(label: "class1").isNotNil)
        assert(module2.lookup(label: "class2").isNotNil)
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

