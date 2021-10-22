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
        let families = NSFontManager.shared.availableFontFamilies.sorted{$0 < $1}
        for family in families
            {
            print("\(family)")
            if let fonts = NSFontManager.shared.availableMembers(ofFontFamily: family)
                {
                for items in fonts
                    {
                    let array = items as! NSArray
                    let name = array[0]
                    print("\t\(name)")
                    }
                }
            }
        TopModule.shared.resolveReferences(topModule: TopModule.shared)
        TopModule.shared.commitJournalTransaction()
        let objectFile = ObjectFile(filename: "test.dat", module: Module(label: "junk"), root: TopModule.shared, date: Date(), version: SemanticVersion(major: 1, minor: 0, patch: 0))
        let cleanData = try! NSKeyedArchiver.archivedData(withRootObject: objectFile, requiringSecureCoding: false)
        let topModuleClone = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(cleanData) as! ObjectFile
        print(topModuleClone)
        let method = Method(label: "f")
        let methodInstance1 = StandardMethodInstance(label: "f",parameters: [Parameter(label: "a", type: TopModule.shared.argonModule.class.type),Parameter(label:"b",type: TopModule.shared.argonModule.integer.type)],returnType: TopModule.shared.argonModule.integer.type)
        method.addInstance(methodInstance1)
        let methodInstance2 = StandardMethodInstance(label: "f",parameters: [Parameter(label: "a", type: TopModule.shared.argonModule.metaclass.type),Parameter(label:"b",type: TopModule.shared.argonModule.integer.type)],returnType: TopModule.shared.argonModule.integer.type)
        method.addInstance(methodInstance2)
        let methodInstance3 = StandardMethodInstance(label: "f",parameters: [Parameter(label: "a", type: TopModule.shared.argonModule.class.type)],returnType: TopModule.shared.argonModule.integer.type)
        method.addInstance(methodInstance3)
        let methodInstance4 = StandardMethodInstance(label: "f",parameters: [Parameter(label:"a",type: TopModule.shared.argonModule.integer.type),Parameter(label:"b",type: TopModule.shared.argonModule.integer.type)],returnType: TopModule.shared.argonModule.integer.type)
        method.addInstance(methodInstance4)
        let methodInstance5 = StandardMethodInstance(label: "f",parameters: [],returnType: TopModule.shared.argonModule.integer.type)
        method.addInstance(methodInstance5)
        let methodInstance6 = StandardMethodInstance(label: "f",parameters: [Parameter(label:"a",type: TopModule.shared.argonModule.class.type),Parameter(label:"b",type: TopModule.shared.argonModule.integer.type),Parameter(label:"c",type: TopModule.shared.argonModule.byte.type)],returnType: TopModule.shared.argonModule.integer.type)
        method.addInstance(methodInstance6)
        let methodInstance7 = StandardMethodInstance(label: "f",parameters: [Parameter(label: "a", type: TopModule.shared.argonModule.typeClass.type),Parameter(label:"b",type: TopModule.shared.argonModule.integer.type)],returnType: TopModule.shared.argonModule.integer.type)
        method.addInstance(methodInstance7)
        let types:Array<Type> = [TopModule.shared.argonModule.class.type,TopModule.shared.argonModule.integer.type]
        let instance = method.mostSpecificMethodInstance(forTypes: types)
        instance?.printInstance()
            let lifeform = Class(label: "Lifeform")
            TopModule.shared.argonModule.object.addSubclass(lifeform)
            let sentient = Class(label: "Sentient")
            lifeform.addSubclass(sentient)
            let bipedal = Class(label: "Bipedal")
            lifeform.addSubclass(bipedal)
            let intelligent = Class(label: "Intelligent")
            sentient.addSubclass(intelligent)
            let humanoid = Class(label: "Humanoid")
            bipedal.addSubclass(humanoid)
            let vulcan = Class(label: "Vulcan")
            vulcan.addSuperclass(intelligent)
            vulcan.addSuperclass(humanoid)
            let human = Class(label: "Human")
            human.addSuperclass(humanoid)
            human.addSuperclass(intelligent)
            print(vulcan.precedenceList)
            print(human.precedenceList)

        let method1 = Method(label: "psychoanalyze")
        let methodInstance1A = StandardMethodInstance(label: "psychoanalyze",parameters: [Parameter(label: "being", type: intelligent.type)],returnType: TopModule.shared.argonModule.integer.type)
        method1.addInstance(methodInstance1A)
        let methodInstance1B = StandardMethodInstance(label: "psychoanalyze",parameters: [Parameter(label: "being", type: humanoid.type)],returnType: TopModule.shared.argonModule.integer.type)
        method1.addInstance(methodInstance1B)
        let types1:Array<Type> = [human.type]
        let instance1 = method1.mostSpecificMethodInstance(forTypes: types1)
        instance1?.printInstance()
        let types2:Array<Type> = [vulcan.type]
        let instance2 = method1.mostSpecificMethodInstance(forTypes: types2)
        instance2?.printInstance()
//        let aClass = TopModule.shared.argonModule.class
//        let archiver = Archiver(path: URL(fileURLWithPath: "/Users/vincent/Desktop/Class.argonb"))
//        try! archiver.writeRootObject(aClass)
//        let small = VirtualMachine.small
//        let array = InnerArrayPointer.allocate(arraySize: 20, elementClass: TopModule.shared.argonModule.slot, in: small)
//        for word in Word(0)..<Word(20)
//            {
//            array.append(word)
//            }
//        assert(array.size == 20,"ARRAY SIZE IS \(array.size) BUT SHOULD BE 20")
//        assert(array.count == 20,"ARRAY COUNT IS \(array.count) BUT SHOULD BE 20")
//        for index in 0..<20
//            {
//            let word = Word(index)
//            let result = array[index]
//            assert(word == result,"array[\(index)] SHOULD BE \(word) BUT IS \(result)")
//            }
//        let elementClass = array.elementClass
////        assert(elementClass == TopModule.shared.argonModule.slot,"THE ELEMENT CLASS OF THE ARRAY SHOULD BE slot BUT IS \(elementClass!.label)")
////        small.registers[Instruction.Register.BP.rawValue] = array.address
////        let arrayCopy = InnerArrayPointer(address: small.registers[Instruction.Register.BP.rawValue])
////        assert(arrayCopy.elementClass == small.argonModule.slot,"ARRAY ELEMENT CLASS SHOULD BE slot BUT IS \(arrayCopy.elementClass!.label)")
////        assert(arrayCopy.count == 20,"ARRAY COUNT SHOULD BE 20 BUT IS \(arrayCopy.count)")
////        assert(arrayCopy.size == 20,"ARRAY SIZE SHOULD BE 20 BUT IS \(arrayCopy.size)")
//        for index in 0..<20
//            {
//            let word = Word(index)
////            let result = arrayCopy[index]
////            assert(word == result,"arrayCopy[\(index)] SHOULD BE \(word) BUT IS \(result)")
//            }
//        let sourceURL = Bundle.main.url(forResource: "Basics", withExtension: "argon")
//        let source = try! String(contentsOf: sourceURL!)
//        print(source)
//        let compiler = Compiler()
//        let chunk = compiler.compileChunk(source)
//        let module = chunk as! Module
//        do
//            {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: chunk, requiringSecureCoding: false)
//            try data.write(to: URL(string: "file:///Users/vincent/Desktop/Output.argono")!)
//            let newData = try Data(contentsOf: URL(string: "file:///Users/vincent/Desktop/Output.argono")!)
//            let result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(newData)
//            print(result!)
//            let output = result
//            print(output!)
//            let topObject = result! as! Symbol
//            if topObject.isModule
//                {
//                let module = topObject as! Module
//                for symbol in module.symbols
//                    {
//                    print(symbol)
//                    }
//                }
//            }
//        catch let error
//            {
//            print(error)
//            }
        let name1 = Name("\\\\Argon\\Collections")
        print(name1)
        let name2 = Name("\\Argon\\Collections")
        print(name2)
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

