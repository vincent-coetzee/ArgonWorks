//
//  Invokable.swift
//  Invokable
//
//  Created by Vincent Coetzee on 9/8/21.
//

import AppKit

public class Invocable: Symbol,Scope,StackFrame
    {
    public override var iconName: String
        {
        "IconMethod"
        }
        
    public override var iconTint: NSColor
        {
        SyntaxColorPalette.methodColor
        }
        
    public override var segmentType: Segment.SegmentType
        {
        .code
        }
        
    public var enclosingMethodInstance: MethodInstance
        {
        fatalError()
        }
        
    public var parentScope: Scope?
        {
        get
            {
            self.module
            }
        set
            {
//            self.module = newValue as? Module
            if newValue.isNil
                {
            fatalError()
            }
            self.setModule(newValue as! Module)
            }
        }
    
    public func removeSymbol(_ symbol: Symbol)
        {
        fatalError()
        }
        
    public override func addSymbol(_ symbol: Symbol)
        {
        if symbol is LocalSlot
            {
            self.addLocalSlot(symbol as! LocalSlot)
            }
        else if symbol is Parameter
            {
            self.addParameterSlot(symbol as! Parameter)
            }
        else
            {
            fatalError("Attempting to add symbol of type \(symbol) to an Invocable")
            }
        }
    
    public override var argonHash: Int
        {
        self.displayString.polynomialRollingHash
        }
        
    public var arity: Int
        {
        self.parameters.count
        }
        
    public var invocationLabel: Label
        {
        let labels = self.parameters.map{$0.type.displayString}.joined(separator: "_")
        return(self.label + "_" + labels)
        }
        
    public override var isInvokable: Bool
        {
        return(true)
        }
        
    public var instructions: Array<T3AInstruction>
        {
        fatalError()
        }
        
    internal var localSymbols = Symbols()
    internal var cName: String
    internal var parameters: Parameters
    public var returnType: Type
    private var nextLocalSlotOffset = StackSegment.kFirstTemporaryOffset
    private var nextParameterOffset = StackSegment.kFirstArgumentOffset
    internal var localCount = 0
    
    public required init?(coder: NSCoder)
        {
        self.localSymbols = coder.decodeObject(forKey: "localSymbols") as! Symbols
        self.cName = coder.decodeString(forKey: "cName")!
        self.parameters = coder.decodeObject(forKey: "parameters") as! Parameters
        self.returnType = coder.decodeObject(forKey: "returnType") as! Type
        self.nextLocalSlotOffset = coder.decodeInteger(forKey: "nextLocalSlotOffset")
        self.nextParameterOffset = coder.decodeInteger(forKey: "nextParameterOffset")
        super.init(coder: coder)
        }
        
    init(label:Label,argonModule: ArgonModule)
        {
        self.cName = ""
        self.parameters = Parameters()
        self.returnType = argonModule.void
        super.init(label: label)
        }
        
    public required init(label: Label)
        {
        fatalError()
        }
        
    public override func encode(with coder: NSCoder)
        {
//        print("ENCODE INVOKABLE \(self.label)")
        coder.encode(self.localSymbols,forKey: "localSymbols")
        coder.encode(self.cName,forKey: "cName")
        coder.encode(self.parameters,forKey: "parameters")
        coder.encode(self.returnType,forKey: "returnType")
        coder.encode(self.nextParameterOffset,forKey: "nextParameterOffset")
        coder.encode(self.nextLocalSlotOffset,forKey: "nextLocalSlotOffset")
        super.encode(with: coder)
        }
        
//    public override func isElement(ofType: Group.ElementType) -> Bool
//        {
//        return(ofType == .method)
//        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        for symbol in self.localSymbols
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(self.module.lookup(label: label))
        }
        
    public func addTemporaries(_ types: Types)
        {
        for aType in types
            {
            self.localSymbols.append(aType)
            }
        }
        
    public override func addLocalSlot(_ localSlot:LocalSlot)
        {
        self.localSymbols.append(localSlot)
        localSlot.frame = self
        localSlot.offset = self.nextLocalSlotOffset
        self.nextLocalSlotOffset -= 8
        self.localCount += 1
        }
        
    public func addParameterSlot(_ parameter:Parameter)
        {
        self.localSymbols.append(parameter)
        parameter.frame = self
        parameter.offset = self.nextParameterOffset
        self.nextParameterOffset += 8
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        self.returnType = context.voidType
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let copy = Self.init(label: label)
        copy.parameters = self.parameters.map{substitution.substitute($0)}
        copy.returnType = substitution.substitute(self.returnType)
        copy.cName = self.cName
        return(copy)
        }
    }
    
public class SingleParameterInvokable: Symbol
    {
    private var parameter: Parameter
    private var result: Parameter
    
    public static func with(label:Label,parameters parms: Parameters,returnType: Type) -> Array<SingleParameterInvokable>
        {
        let extra = Parameter(label:"returnType",type: returnType)
        let parameters = parms + [extra]
        var invokables = Array<SingleParameterInvokable>()
        for index in stride(from: 0, through: parameters.count, by: 2)
            {
            let parm = parameters[index]
            let value = parameters[index + 1]
            invokables.append(SingleParameterInvokable(label: label + "\(index)", parameter: parm,result: value))
            }
        return(invokables)
        }
        
    init(label:Label,parameter: Parameter,result: Parameter)
        {
        self.parameter = parameter
        self.result = result
        super.init(label: label)
        }
    
 
        
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init(label: Label)
        {
        self.result = Parameter(label:"")
        self.parameter = Parameter(label:"")
        super.init(label: label)
        }
}

extension Array where Element == Parameter
    {
    public var second: Element
        {
        return(self[1])
        }
    }
