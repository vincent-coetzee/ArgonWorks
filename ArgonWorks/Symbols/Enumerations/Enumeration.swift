//
//  Enumeration.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/10/21.
//

import Foundation

public class Enumeration:Class
    {
    private var cases: EnumerationCases = []
    public var rawType: Type?
    
    public override var isEnumeration: Bool
        {
        return(true)
        }
        
    public override var typeCode:TypeCode
        {
        .enumeration
        }
        
    @discardableResult
    public override func addSymbol(_ symbol:Symbol) -> Self
        {
        if let aCase = symbol as? EnumerationCase
            {
            self.cases.append(aCase)
            aCase.setParent(self)
            return(self)
            }
        fatalError("Attempt to add a symbol of type \(Swift.type(of: symbol)) to the enumeration called \(self.label)")
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        for aCase in self.cases
            {
            if aCase.symbol == label
                {
                return(aCase)
                }
            }
        return(self.parent.lookup(label: label))
        }
        
    public override func layoutInMemory()
        {
//        guard !self.isMemoryLayoutDone else
//            {
//            return
//            }
//        let pointer = InnerEnumerationPointer.allocate(in: vm)
//        pointer.setSlotValue(InnerStringPointer.allocateString(self.label, in: vm).address,atKey:"name")
//        pointer.setSlotValue(rawType?.memoryAddress ?? 0,atKey:"valueType")
//        let casesPointer = InnerArrayPointer.allocate(arraySize: self.cases.count, elementClass: vm.argonModule.enumerationCase,in: vm)
//        pointer.casesPointer = casesPointer
//        var rawValueIndex = 0
//        for aCase in self.cases
//            {
//            let casePointer = InnerEnumerationCasePointer.allocate(in: vm)
//            casesPointer.append(casePointer.address)
//            casePointer.setSlotValue(InnerStringPointer.allocateString(aCase.symbol, in: vm).address,atKey:"symbol")
//            casePointer.setSlotValue(pointer.address,atKey:"enumeration")
//            casePointer.setSlotValue(aCase.caseSizeInBytes,atKey:"caseSizeInBytes")
//            casePointer.setSlotValue(rawValueIndex,atKey:"index")
//            if aCase.rawValue.isNil
//                {
//                casePointer.setSlotValue(0,atKey:"rawValue")
//                }
//            else
//                {
//                if aCase.rawValue!.isStringLiteral
//                    {
//                    casePointer.setSlotValue(InnerStringPointer.allocateString(aCase.rawValue!.stringLiteral, in: vm).address,atKey:"rawValue")
//                    }
//                else if aCase.rawValue!.isSymbolLiteral
//                    {
//                    casePointer.setSlotValue(InnerStringPointer.allocateString(aCase.rawValue!.symbolLiteral, in: vm).address,atKey:"rawValue")
//                    }
//                else if aCase.rawValue!.isIntegerLiteral
//                    {
//                    casePointer.setSlotValue(Word(bitPattern: aCase.rawValue!.integerLiteral),atKey:"rawValue")
//                    }
//                }
//            if aCase.associatedTypes.count > 0
//                {
//                let arrayPointer = InnerArrayPointer.allocate(arraySize: aCase.associatedTypes.count, elementClass: vm.argonModule.class,in: vm)
//                casePointer.associatedTypesPointer = arrayPointer
//                for aType in aCase.associatedTypes
//                    {
//                    arrayPointer.append(aType.memoryAddress)
//                    }
//                }
//            rawValueIndex += 1
//            }
//        print("LAID OUT ENUMERATION \(self.label) AT ADDRESS \(self.memoryAddress.addressString)")
        }
    }
