//
//  ArgonWorxApp.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Interpreter
import FFI

struct ArgonWorxApp {

    init()
        {
        Thread.initThreads()
        let small = VirtualMachine.small
        let bottomClass = small.topModule.argonModule.class
        print("CLASS <= TYPE: \(bottomClass.isInclusiveSubclass(of: small.topModule.argonModule.typeClass))")
        print("CLASS <= OBJECT: \(bottomClass.isInclusiveSubclass(of: small.topModule.argonModule.object))")
        let functionClass = small.topModule.argonModule.function
        print("FUNCTION <= INVOKABLE: \(functionClass.isInclusiveSubclass(of: small.topModule.argonModule.invokable))")
        print("FUNCTION <= BEHAVIOR: \(functionClass.isInclusiveSubclass(of: small.topModule.argonModule.behavior))")
        print("FUNCTION <= OBJECT: \(functionClass.isInclusiveSubclass(of: small.topModule.argonModule.object))")
        print("FUNCTION <= MAGNITUDE: \(functionClass.isInclusiveSubclass(of: small.topModule.argonModule.magnitude))")
        let instance1 = MethodInstance(label:"methodA",parameters: [Parameter(label: "A", type: small.topModule.argonModule.integer.type),Parameter(label:"B",type: small.topModule.argonModule.boolean.type),Parameter(label: "C",type: small.topModule.argonModule.typeClass.type)],returnType: .class(small.topModule.argonModule.integer))
        let instance2 = MethodInstance(label:"methodA",parameters: [Parameter(label: "A", type: small.topModule.argonModule.integer.type),Parameter(label:"B",type: small.topModule.argonModule.string.type),Parameter(label: "C",type: small.topModule.argonModule.enumeration.type)],returnType: .class(small.topModule.argonModule.integer))
        let instance3 = MethodInstance(label:"methodA",parameters: [Parameter(label: "A", type: small.topModule.argonModule.integer.type),Parameter(label:"B",type: small.topModule.argonModule.collection.type),Parameter(label: "C",type: small.topModule.argonModule.class.type)],returnType: .class(small.topModule.argonModule.integer))
        let instance4 = MethodInstance(label:"methodA",parameters: [Parameter(label: "A", type: small.topModule.argonModule.integer.type),Parameter(label:"B",type: small.topModule.argonModule.array.type),Parameter(label: "C",type: small.topModule.argonModule.class.type)],returnType: .class(small.topModule.argonModule.integer))
        let method = Method(label: "MethodA")
        method.addInstance(instance1)
        method.addInstance(instance2)
        method.addInstance(instance3)
        method.addInstance(instance4)
        let signatures = method.methodSignatures
        let root = DispatchRootNode(signatures: signatures)
        print(root)
        let segment = small.managedSegment
        let string1 = segment.allocateString("This is a test string to see how it is allocated.")
        let string2 = string1
        let innerPointer = InnerStringPointer(address: string2)
        print(innerPointer.string)
        let theClass = small.topModule.argonModule.class
        theClass.layoutInMemory()
        let address = theClass.memoryAddress
        theClass.rawDumpFromAddress(address)
        let class1Pointer = InnerClassPointer(address: small.topModule.argonModule.array.memoryAddress)
        let slotsPointer = class1Pointer.slots
        print(slotsPointer.count)
        print(slotsPointer.size)
        let slot1Pointer = InnerSlotPointer(address: slotsPointer[4])
        print(slot1Pointer.name)
        print(slot1Pointer.typeCode)
        let byteArray = InnerByteArrayPointer.with([0,1,2,3,4,5,6,7,8,9,10,9,8,7,6,5,4,3,2,1,2,3,4,5,6,7,8,9,10,9,8,7,6,5,4,3,2,1])
        let someBytes = byteArray.bytes
        print(someBytes)
        let used = VirtualMachine.small.managedSegment.spaceUsed
        let usedK = used.size(inUnits: .kilobytes)
        let usedM = used.size(inUnits: .megabytes)
        print("BYTES USED IN ManagedSegment: \(used.displayString), \(usedK.displayString), \(usedM.displayString)" )
        let dictionary = InnerStringKeyDictionaryPointer.allocate(size: 2000, in: small)
        print("DICTIONARY PRIME IS: \(dictionary.prime)")
        let randomWords = EnglishWord.randomWords(maximum: 2000)
        var keyedValues = Dictionary<String,Word>()
        var index = 0
        for word in randomWords
            {
            let random = Word.random(in: 0...4000000000)
            keyedValues[word.word] = random
            index += 1
            }
        for (key,value) in keyedValues
            {
            let answer = dictionary[key]
            assert(answer == value,"EXPECTED VALUE \(value) FOR KEY BUT RECEIVED \(answer!)")
            }
        let allKeys = dictionary.keys
        let storedKeys = keyedValues.keys
        assert(allKeys.count == storedKeys.count,"STORED KEYS SIZE DOES NOT MATCH DICTIONARY KEYS SIZE")
        for key in storedKeys
            {
            assert(allKeys.contains(key),"DICTIONARY KEYS IS MISSING KEY \(key)")
            }
        let sourceURL = Bundle.main.url(forResource: "Basics", withExtension: "argon")
        let source = try! String(contentsOf: sourceURL!)
        print(source)
        let compiler = Compiler(source: source)
        compiler.compile()
        let library = DynamicLibrary(path: "/Users/vincent/Desktop/libXenon.dylib")
        let symbol = library.findSymbol("PrintString")
        let stringAddress = InnerStringPointer.allocateString("Can we c this string in c ?", in: small)
        var array = [stringAddress.address]
        CallSymbolWithArguments(symbol!.address!,&array,1)
        let pointer1 = UnsafeMutablePointer<ffi_type>.allocate(capacity: 1)
        pointer1.pointee = ffi_type_uint64
        var args:UnsafeMutablePointer<ffi_type>? = UnsafeMutablePointer<ffi_type>.allocate(capacity: 1)
        args!.pointee = ffi_type_uint64
        var interface:ffi_cif = ffi_cif()
        ffi_prep_cif(&interface,FFI_DEFAULT_ABI,1,&ffi_type_void,&args)
        let input:UnsafeMutablePointer<Word>? = UnsafeMutablePointer<Word>.allocate(capacity: 1)
        input!.pointee = stringAddress.address
        var voidValue:UnsafeMutableRawPointer? = UnsafeMutableRawPointer(input)
        ffi_call(&interface,MutateSymbol(symbol!.address!),nil,&voidValue)
//        print("SIZE AND STRIDE OF Instruction: \(MemoryLayout<Instruction>.stride) \(MemoryLayout<Instruction>.size)")
        let vector = InnerVectorPointer.allocate(arraySize: 20, in: small)
        var randomSet = Array<Word>()
        let randomCount = 100
        for _ in 0..<randomCount
            {
            randomSet.append(Word.random(in: 0...1000_000_000))
            }
        for random in randomSet
            {
            vector.append(random,in: small)
            }
        assert(vector.count == randomSet.count,"VECTOR COUNT SHOULD BE \(randomSet.count) BUT IS \(vector.count)")
        print("VECTOR COUNT = \(vector.count)")
        let timer = Timer()
        for value in randomSet
            {
            assert(vector.contains(value),"VECTOR SHOULD CONTAIN VALUE \(value) BUT DOES NOT")
            }
        let total = timer.stop()
        print("AVERAGE TIME TO contains = \(total/randomSet.count) milliseconds")
        print("ManagedSpace Used = \(small.managedSegment.spaceUsed.size(inUnits: .kilobytes).displayString)")
        print("ManagedSpace Freee = \(small.managedSegment.spaceFree.size(inUnits: .kilobytes).displayString)")
        let instancePointer = InnerInstancePointer.allocateInstance(ofClass: small.topModule.argonModule.class, in: small)
        print("InstancePointer.sizeInBytes = \(instancePointer.sizeInBytes)")
        print("InstancePointer.typeCode = \(instancePointer.typeCode)")
        let someObject = InnerPointer(address: small.topModule.argonModule.class.memoryAddress)
        let someClass = someObject.classPointer
        print("THE NAME OF THE CLASS: \(someClass.name)")
        let slotValues = someObject.slotValues
        for slotValue in slotValues
            {
            print("SLOT    : \(slotValue.slotIndex)")
            print("OFFSET  : \(slotValue.slotOffset)")
            print("NAME    : \(slotValue.slotName)")
            print("TYPE    : \(slotValue.slotClass.name)")
            print("VALUE   : \(slotValue.slotValue.bitString)")
            print("TYPECODE: \(slotValue.slotTypeCode)")
            }
        let general = GeneralPointer(address: small.topModule.argonModule.class.memoryAddress,class: small.topModule.argonModule.class)
        let slot = general.arrayElement(atIndex: 0,atLabel:"slots")
        let slotPointer = InnerSlotPointer(address: slot)
        print(slotPointer.name)
        let secondSlot = GeneralPointer(address: slot,class: small.topModule.argonModule.slot)
        let namePointer = InnerStringPointer(address: secondSlot.value(atLabel:"name"))
        print(namePointer.string)
        }
        
}
