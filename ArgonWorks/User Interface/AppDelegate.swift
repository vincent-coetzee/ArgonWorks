//
//  AppDelegate.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/8/21.
//

import Cocoa

let showDebuggingOutput = false

@main
class AppDelegate: NSObject, NSApplicationDelegate
    {
    func applicationDidFinishLaunching(_ aNotification: Notification)
        {
        TopModule.resetTopModule()
//        let set = BitSet()
//        set.addBitField(named: "first",width: 63)
//        set.addBitField(named: "second",width: 7)
//        set.addBitField(named: "third",width: 46)
//        set.addBitField(named: "fourth",width: 19)
//        set.addBitField(named: "fifth",width: 60)
//        set.setBits(127, atName: "first")
//        set.setBits(127, atName: "second")
//        set.setBits(127, atName: "third")
//        assert(set.bits(atName: "first") == 127)
//        assert(set.bits(atName: "second") == 127)
//        assert(set.bits(atName: "third") == 127)
////        let families = NSFontManager.shared.availableFontFamilies.sorted{$0 < $1}
////        for family in families
////            {
////            print("\(family)")
////            if let fonts = NSFontManager.shared.availableMembers(ofFontFamily: family)
////                {
////                for items in fonts
////                    {
////                    let array = items as! NSArray
////                    let name = array[0]
////                    print("\t\(name)")
////                    }
////                }
////            }
////        let source = try! String(contentsOfFile: "/Users/vincent/Desktop/Argon.Base.Primitives.argon")
////        let compiler = Compiler(source: source,reportingContext: NullReportingContext.shared,tokenRenderer: NullTokenRenderer.shared)
////        compiler.compile()
//        let type1 = TypeVariable(index: 2000)
//        let type2 = TypeVariable(index: 2000)
//        assert(type1 == type2,"Type1 should == type2")
//        let type3 = TypeVariable(index: 2001)
//        assert(type1 != type3,"Type3 should not == type1")
//        let compiler:Compiler? = Compiler(source: "", reportingContext: NullReporter.shared, tokenRenderer: NullTokenRenderer.shared)
//        let items = ArgonModule.shared.lookupN(label: "-")
//        print(items)
//        let type = ArgonModule.shared.lookup(label: "Void") as! Type
//        print(type.fullName.displayString)
//        let slot1 = Slot(label: "slot1",type: ArgonModule.shared.integer)
//        let slot2 = Slot(label: "slot2",type: ArgonModule.shared.string)
//        let tuple1 = Tuple(.slot(slot1),.slot(slot2))
//        let context = TypeContext()
//        tuple1.initializeType(inContext: context)
//        print(tuple1.type.displayString)
//        let slot1Expression = SlotExpression(slot: slot1)
//        let slot2Expression = SlotExpression(slot: slot2)
//        let right1Expression = LiteralExpression(.integer(10))
//        let right2Expression = LiteralExpression(.string(StaticString(string: "hello")))
//        let assignmentExpression = AssignmentExpression(TupleExpression(slot1Expression,slot2Expression),TupleExpression(right1Expression,right2Expression))
//        assignmentExpression.initializeType(inContext: context)
//        print(assignmentExpression.lhs.type.displayString)
//        print(assignmentExpression.rhs.type.displayString)
//        let pointer = Word(object: 0)
//        print(pointer.bitString)
        let object = ArgonModule.shared.object
//        let address:Word = 1000000000
//        print(address.bitString)
//        let word1 = Word(array: address)
//        print(word1.bitString)
//        let word2 = word1.cleanAddress
//        print(word2.bitString)
//        var allocator:AddressAllocator? = AddressAllocator()
        ArgonModule.shared.layoutObjectSlots()
        object.printLayout()
        let array = ArgonModule.shared.array
        array.printLayout()
        let aClass = ArgonModule.shared.classType
        aClass.printLayout()
        let string = ArgonModule.shared.string
        string.printLayout()
        let slot = ArgonModule.shared.slot
        slot.printLayout()
        let symbol = ArgonModule.shared.symbol
        symbol.printLayout()
        let aType = ArgonModule.shared.typeType
        aType.printLayout()
        let anEnum = ArgonModule.shared.enumeration
        anEnum.printLayout()
        let instance = ArgonModule.shared.methodInstance
        instance.printLayout()
        let bucket = ArgonModule.shared.bucket
        bucket.printLayout()
        let treeNode = ArgonModule.shared.treeNode
        treeNode.printLayout()
        let methodInstance = ArgonModule.shared.methodInstance
        methodInstance.printLayout()
        let instructionBlock = ArgonModule.shared.instructionBlock
        instructionBlock.printLayout()
        let caseInstance = ArgonModule.shared.enumerationCaseInstance
        caseInstance.printLayout()
        let metaclass = ArgonModule.shared.metaclassType
        metaclass.printLayout()
        let dictionary = ArgonModule.shared.dictionary
        dictionary.printLayout()
        let node = ArgonModule.shared.treeNode
        node.printLayout()
        let vector = ArgonModule.shared.vector
        vector.printLayout()
        let block = ArgonModule.shared.block
        block.printLayout()
        let testClass = ArgonModule.shared.lookup(label: "ClassE") as! TypeClass
        testClass.printLayout()
        print()
        let payload = VMPayload()
        array.printLayout()
        block.printLayout()
        string.printLayout()
        ArrayPointer.test(inSegment: payload.staticSegment)
        StringPointer.test(inSegment: payload.staticSegment)
        let segment = payload.codeSegment
        let newObject = segment.allocateObject(ofType: testClass, extraSizeInBytes: 0)
        let pointer = ClassBasedPointer(address: newObject,type: testClass)
        pointer.setInteger(234,atSlot: "b1")
        ArgonModule.shared.printHierarchy(class: ArgonModule.shared.object as! TypeClass,depth:"")
        ArgonModule.shared.printHierarchy(class: ArgonModule.shared.object.type as! TypeClass,depth:"")
        let vulcan = ArgonModule.shared.lookup(label: "Vulcan") as! TypeClass
        print(vulcan.precedenceList)
        let human = ArgonModule.shared.lookup(label: "Human") as! TypeClass
        print(human.precedenceList)
        
        let bitSet = BitSet()
        bitSet.addBitField(named: "opcode", width: 8)
        bitSet.addBitField(named: "mode", width: 4)
        bitSet.addBitField(named: "operand1Kind", width: 5)
        bitSet.addBitField(named: "operand2Kind", width: 5)
        bitSet.addBitField(named: "resultKind",width: 5)
        bitSet.addBitField(named: "operand1Value",width: 64)
        bitSet.addBitField(named: "operand2Value",width: 64)
        bitSet.addBitField(named: "resultValue",width: 64)
        print("NUMBER OF BITS USED = \(bitSet.maximumFieldOffset)")
        
//        let payload = VMPayload()
//        ArgonModule.shared.dictionary.layoutObjectSlots()
//        let dPointer = DictionaryPointer(inSegment: payload.managedSegment)!
//        let someKeys = EnglishWord.randomWords(maximum: 200)
//        let someValues = EnglishWord.randomWords(maximum: 200)
//        let number = min(someKeys.count,someValues.count)
//        for index in 0..<number
//            {
//            let stringValue = payload.managedSegment.allocateString(someValues[index].word)
//            let stringKey = payload.managedSegment.allocateString(someKeys[index].word)
//            dPointer.setValue(stringValue,forKey: stringKey)
//            }
//        for index in 0..<number
//            {
//            let stringValue = payload.managedSegment.allocateString(someValues[index].word)
//            let stringKey = payload.managedSegment.allocateString(someKeys[index].word)
//            let value = dPointer.value(forKey: stringKey)
//            print("VALUE: \(StringPointer(dirtyAddress: stringValue)!.string) RESULT: \(StringPointer(dirtyAddress: value!)!.string)")
//            }
        
//        let payload = VMPayload()
//        let startWords = EnglishWord.randomWordsWithDuplicates(maximum: 50000)
//        for word in startWords
//            {
//            let symbol = payload.symbolRegistry.registerSymbol(word.word)
//            }
//        for word in startWords
//            {
//            let symbol = payload.symbolRegistry.registerSymbol(word.word)
//            }
//        for symbolIndex in 1..<50
//            {
//            for index:Word in 1..<50
//                {
//                print("SYMBOL IS \(Word(symbolIndex: symbolIndex,offset: index))")
//                }
//            }
            
        let module1 = Module(label: "Test")
        let entity = TypeClass(label: "Entity")
        entity.setModule(module1)
        entity.addSupertype(ArgonModule.shared.object)
        let legalEntity = TypeClass(label: "LegalEntity")
        legalEntity.setModule(module1)
        legalEntity.addSupertype(entity)
        let person = TypeClass(label: "Person")
        person.setModule(module1)
        person.addSupertype(legalEntity)
        let citizen = TypeClass(label: "Citizen")
        citizen.setModule(module1)
        citizen.addSupertype(person)
        let method1 = MethodInstance(label: "name")
        method1.setModule(module1)
        method1.parameters = [Parameter(label: "object", relabel: nil, type: entity, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: ArgonModule.shared.string, isVisible: false, isVariadic: false)]
        method1.returnType = ArgonModule.shared.void
        module1.addSymbol(method1)
        let method2 = MethodInstance(label: "name")
        method2.setModule(module1)
        method2.parameters = [Parameter(label: "object", relabel: nil, type: legalEntity, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: ArgonModule.shared.string, isVisible: false, isVariadic: false)]
        method2.returnType = ArgonModule.shared.void
        module1.addSymbol(method2)
        let method3 = MethodInstance(label: "name")
        method3.setModule(module1)
        method3.parameters = [Parameter(label: "object", relabel: nil, type: person, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: ArgonModule.shared.string, isVisible: false, isVariadic: false)]
        method3.returnType = ArgonModule.shared.void
        module1.addSymbol(method3)
        print(person.precedenceList)
        var instanceSet = module1.methodInstanceSet(withLabel: "name")
        instanceSet.display()
        var types = [person,ArgonModule.shared.string]
        print(instanceSet.mostSpecificInstance(forTypes: types))
        types = [legalEntity,ArgonModule.shared.string]
        print(instanceSet.mostSpecificInstance(forTypes: types))
        types = [entity,ArgonModule.shared.string]
        print(instanceSet.mostSpecificInstance(forTypes: types))
        print(person.precedenceList)
        let method4 = MethodInstance(label: "setName")
        method4.setModule(module1)
        method4.parameters = [Parameter(label: "object", relabel: nil, type: entity, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: ArgonModule.shared.string, isVisible: false, isVariadic: false)]
        method4.returnType = ArgonModule.shared.void
        module1.addSymbol(method4)
        let method5 = MethodInstance(label: "setName")
        method5.setModule(module1)
        method5.parameters = [Parameter(label: "object", relabel: nil, type: legalEntity, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: ArgonModule.shared.string, isVisible: false, isVariadic: false)]
        method5.returnType = ArgonModule.shared.void
        module1.addSymbol(method5)
        let method6 = MethodInstance(label: "setName")
        method6.setModule(module1)
        method6.parameters = [Parameter(label: "object", relabel: nil, type: person, isVisible: false, isVariadic: false),Parameter(label: "value", relabel: nil, type: ArgonModule.shared.string, isVisible: false, isVariadic: false)]
        method6.returnType = ArgonModule.shared.void
        module1.addSymbol(method6)
        types = [citizen,ArgonModule.shared.string]
        instanceSet = module1.methodInstanceSet(withLabel: "setName")
        print(instanceSet.mostSpecificInstance(forTypes: types))
////        let enumeration = ArgonModule.shared.enumeration
////        enumeration.printLayout()
////        let module = ArgonModule.shared.moduleType
////        module.printLayout()
//
//        Header.test()
//        Word.testWord()
//        StackSegment.testStackSegment()
//        allocator = nil
//        let payload = VMPayload()
//        payload.staticSegment.testSegment()
//        let symbol1 = "symbol1"
//        let symbol1Handle = payload.symbolRegistry.registerSymbol(symbol1)
//        print("SYMBOL1 = \(symbol1Handle)")
//        let symbol2 = "this-is-a-symbol"
//        let symbol2Handle = payload.symbolRegistry.registerSymbol(symbol2)
//        print("SYMBOL2 = \(symbol2Handle)")
//        let symbol3 = "symbol1"
//        let symbol3Handle = payload.symbolRegistry.registerSymbol(symbol3)
//        print("SYMBOL3 = \(symbol3Handle)")
//        
//        let module1 = Module(label: "module1")
//        let module2 = Module(label: "module2")
//        let class1 = TypeClass(label: "class1")
//        let class2 = TypeClass(label: "class2")
//        module1.setContainer(.symbol(TopModule.shared))
//        module1.addSymbol(module2)
//        module2.addSymbol(class1)
//        module1.addSymbol(class2)
//        assert(module1.lookup(name: Name("\\\\Argon\\Array")).isNotNil)
//        assert(module1.lookup(label: "module2").isNotNil)
//        assert(module2.lookup(label: "class1").isNotNil)
//        assert(module2.lookup(label: "class2").isNotNil)
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

