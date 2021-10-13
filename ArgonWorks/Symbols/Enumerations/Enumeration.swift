//
//  Enumeration.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/10/21.
//

import AppKit

public class Enumeration:Class
    {
    public override var asLiteralExpression: LiteralExpression?
        {
        LiteralExpression(.enumeration(self))
        }
        
    public override var isType: Bool
        {
        return(true)
        }
        
    public override var canBecomeAType: Bool
        {
        return(true)
        }
        
    public override var type: Type
        {
        get
            {
            return(.enumeration(self))
            }
        set
            {
            }
        }
        
    private var cases: EnumerationCases = []
    public var rawType: Type?
    
    public override init(label: Label)
        {
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder)
        {
        self.rawType = coder.decodeType(forKey: "rawType")
        self.cases = coder.decodeObject(forKey: "cases") as! EnumerationCases
        super.init(coder: coder)
        }
    
    public override var isEnumeration: Bool
        {
        return(true)
        }
        
    public override var iconName: String
        {
        return("IconEnumeration")
        }
        
    public override var children: Array<Symbol>
        {
        return(self.cases)
        }
        
    public override var childName: (String,String)
        {
        return(("case","cases"))
        }
        
    public override var typeCode:TypeCode
        {
        .enumeration
        }
        
    public override func addSymbol(_ symbol:Symbol)
        {
        if let aCase = symbol as? EnumerationCase
            {
            self.cases.append(aCase)
            aCase.setParent(self)
            return
            }
        fatalError("Attempt to add a symbol of type \(Swift.type(of: symbol)) to the enumeration called \(self.label)")
        }
        
    public override func isElement(ofType: Group.ElementType) -> Bool
        {
        return(ofType == .enumeration)
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
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encodeType(self.rawType,forKey: "rawType")
        coder.encode(self.cases,forKey: "cases")
        }
        
    public func caseWithLabel(_ label: Label) -> EnumerationCase?
        {
        for aCase in self.cases
            {
            if aCase.label == label
                {
                return(aCase)
                }
            }
        return(nil)
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
