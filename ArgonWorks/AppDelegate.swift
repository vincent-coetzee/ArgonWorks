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
        let small = VirtualMachine(small: true)
        let array = InnerArrayPointer.allocate(arraySize: 20, elementClass: small.argonModule.slot, in: small)
        for word in Word(0)..<Word(20)
            {
            array.append(word)
            }
        assert(array.size == 20,"ARRAY SIZE IS \(array.size) BUT SHOULD BE 20")
        assert(array.count == 20,"ARRAY COUNT IS \(array.count) BUT SHOULD BE 20")
        for index in 0..<20
            {
            let word = Word(index)
            let result = array[index]
            assert(word == result,"array[\(index)] SHOULD BE \(word) BUT IS \(result)")
            }
        let elementClass = array.elementClass
        assert(elementClass == small.argonModule.slot,"THE ELEMENT CLASS OF THE ARRAY SHOULD BE slot BUT IS \(elementClass?.label)")
        small.registers[Instruction.Register.bp.rawValue] = array.address
        let arrayCopy = InnerArrayPointer(address: small.registers[Instruction.Register.bp.rawValue])
        assert(arrayCopy.elementClass == small.argonModule.slot,"ARRAY ELEMENT CLASS SHOULD BE slot BUT IS \(arrayCopy.elementClass?.label)")
        assert(arrayCopy.count == 20,"ARRAY COUNT SHOULD BE 20 BUT IS \(arrayCopy.count)")
        assert(arrayCopy.size == 20,"ARRAY SIZE SHOULD BE 20 BUT IS \(arrayCopy.size)")
        for index in 0..<20
            {
            let word = Word(index)
            let result = arrayCopy[index]
            assert(word == result,"arrayCopy[\(index)] SHOULD BE \(word) BUT IS \(result)")
            }
        let sourceURL = Bundle.main.url(forResource: "Basics", withExtension: "argon")
        let source = try! String(contentsOf: sourceURL!)
        print(source)
        let compiler = Compiler(virtualMachine: small)
        let element = compiler.compileChunk(source)
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
    public func openNewProcessorBrowser(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "ProcessorWindowController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
        
    @IBAction
    public func openNewMemoryBrowser(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "MemoryWindowController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
        
    @IBAction
    public func openNewArgonBrowser(_ sender:Any?)
        {
        let storyboard:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            guard let controller:NSWindowController = storyboard.instantiateController(withIdentifier: "ArgonBrowserWindowController") as? NSWindowController else
            {
            return
            }
        controller.showWindow(self)
        }
    }

