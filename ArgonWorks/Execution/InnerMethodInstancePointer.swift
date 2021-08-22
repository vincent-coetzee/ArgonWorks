//
//  InnerMethodInstancePointer.swift
//  InnerMethodInstancePointer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class InnerMethodInstancePointer: InnerPointer
    {
    public class func allocate(in vm: VirtualMachine) -> InnerMethodInstancePointer
        {
        let address = vm.managedSegment.allocateObject(sizeInBytes: Self.kMethodInstanceSizeInBytes)
        let pointer = InnerMethodInstancePointer(address: address)
        pointer.setClass(vm.topModule.argonModule.methodInstance)
        pointer.assignSystemSlots(from: vm.topModule.argonModule.methodInstance)
        pointer.headerTypeCode = TypeCode.methodInstance
        return(pointer)
        }

    public var localSlotCount:Int
        {
        return(InnerArrayPointer(address: self.slotValue(atKey:"localSlots")).count)
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kMethodInstanceSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_InvokableHeader","_InvokableMagicNumber","_InvokableClassPointer","_BehaviorHeader","_BehaviorMagicNumber","_BehaviorClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","code","localSlots","name","parameters","resultType"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
//    public func allocateCodeArray(arraySize:Int,in segment:ManagedSegment) -> InnerInstructionArrayPointer
//        {
//        let pointer = InnerInstructionArrayPointer.allocate(arraySize: arraySize, in: segment)
//        self.setSlotValue(pointer.address,atKey: "code")
//        return(pointer)
//        }
        
    public func callWithArguments(_ arguments: Words,in vm: VirtualMachine)
        {
//        context.stackSegment.push(vm[.mi])
//        context.stackSegment.push(vm[.ip])
//        for argument in arguments.reversed()
//            {
//            context.stackSegment.push(argument)
//            }
//        context.enter(
        }
    }
