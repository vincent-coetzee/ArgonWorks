//
//  Parameter.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public enum ReferenceType: Int
    {
    case reference = 1
    case value = 0
    }
    
public class Parameter:LocalSlot,Displayable
    {
    public override var argonHash: Int
        {
        var hashValue = "\(Swift.type(of: self))\(self.label)".polynomialRollingHash
        hashValue = hashValue << 13 ^ self.type.argonHash
        if self.relabel.isNotNil
            {
            hashValue = hashValue << 13 ^ self.relabel!.argonHash
            }
        return(hashValue)
        }
        
    public override var displayString: String
        {
        return("\(self.label)::\(type.displayString)")
        }
        
    public override var typeCode:TypeCode
        {
        .parameter
        }
        
    public override var localLabel: Label
        {
        self.relabel.isNotNil ? self.relabel! : self.label
        }
        
    public var valueTag: Label
        {
        return(self.label)
        }
        
    public var tag: Label?
        {
        self.isVisible ? super.label : nil
        }
        
    public let isVisible:Bool
    public let isVariadic: Bool
    public let relabel: Label?
    public var referenceType: ReferenceType
    
    init(label:Label,relabel:Label? = nil,type:Type,isVisible:Bool = false,isVariadic:Bool = false,referenceType: ReferenceType = .value)
        {
        self.isVisible = isVisible
        self.isVariadic = isVariadic
        self.relabel = relabel
        self.referenceType = referenceType
        super.init(label: label,type: type,value: nil)
        }
    
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator)
        {
        let temp = buffer.nextTemporary
        buffer.add(.MOVE,.frameOffset(self.offset),temp)
        self.place = temp
        }
        
    required init(labeled: Label, ofType: Type) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
    
    public required init?(coder: NSCoder)
        {
        self.isVisible = coder.decodeBool(forKey: "isVisible")
        self.isVariadic = coder.decodeBool(forKey: "isVariadic")
        self.relabel = coder.decodeString(forKey: "relabel")
        self.referenceType = ReferenceType(rawValue: coder.decodeInteger(forKey: "referenceType"))!
        super.init(coder: coder)
        }
        
     public required init(label: Label)
        {
        self.isVisible = true
        self.isVariadic = false
        self.relabel = nil
        self.referenceType = .value
        super.init(label: label)
        }
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.isVisible,forKey: "isVisible")
        coder.encode(self.isVariadic,forKey: "isVariadic")
        coder.encode(self.relabel,forKey: "relabel")
        coder.encode(self.referenceType.rawValue,forKey: "referenceType")
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let newType = self.type.freshTypeVariable(inContext: context)
        let newParameter = Parameter(label: self.label, relabel: self.relabel, type: newType, isVisible: self.isVisible, isVariadic: self.isVariadic)
        return(newParameter as! Self)
        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? Parameter
            {
            return(self.label == second.label && self.type == second.type && self.relabel == second.relabel && self.isVisible == second.isVisible)
            }
        return(super.isEqual(object))
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        return(Parameter(label: self.label, relabel: self.relabel, type:  substitution.substitute(self.type), isVisible: self.isVisible, isVariadic: self.isVariadic) as! Self)
        }
        
    public func flatten() -> Parameter
        {
        Parameter(label: self.label, relabel: self.relabel, type: self.type.type, isVisible: self.isVisible, isVariadic: self.isVariadic)
        }
        
//    public func withSolution(_ solution: SolutionSpace) -> Parameter
//        {
//        let newType = self._type!.withSolution(solution)
//        return(Parameter(label: self.label, relabel: self.relabel, type: newType, isVisible: self.isVisible, isVariadic: self.isVariadic))
//        }
    }

public typealias Parameters = Array<Parameter>

extension Array where Element == Displayable
    {
    public var displayString: String
        {
        return("[" + self.map{$0.displayString}.joined(separator: ",") + "]")
        }
    }

extension Parameters
    {
    public func visit(visitor: Visitor) throws
        {
        for element in self
            {
            try element.visit(visitor: visitor)
            }
        }
    }
