//
//  Parameter.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Parameter:Slot,Displayable
    {
    public override var displayString: String
        {
        return("\(self.label)::\(type.displayString)")
        }
        
    public override var typeCode:TypeCode
        {
        .parameter
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
    public var place: T3AInstruction.Operand = .none
    public let relabel: Label?
    
    init(label:Label,relabel:Label? = nil,type:Type,isVisible:Bool = false,isVariadic:Bool = false)
        {
        self.isVisible = isVisible
        self.isVariadic = isVariadic
        self.relabel = relabel
        super.init(label: label,type: type)
        }
    
    public override func emitCode(into buffer: T3ABuffer,using generator: CodeGenerator)
        {
        }
        
    required init(labeled: Label, ofType: Type) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
    
    public required init?(coder: NSCoder)
        {
        self.isVisible = coder.decodeBool(forKey: "isVisible")
        self.isVariadic = coder.decodeBool(forKey: "isVariadic")
        self.relabel = coder.decodeString(forKey: "relabel")
        super.init(coder: coder)
        }
        
     public required init(label: Label)
        {
        self.isVisible = true
        self.isVariadic = false
        self.relabel = nil
        super.init(label: label)
        }
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.isVisible,forKey: "isVisible")
        coder.encode(self.isVariadic,forKey: "isVariadic")
        coder.encode(self.relabel,forKey: "relabel")
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let newType = self.type!.freshTypeVariable(inContext: context)
        let newParameter = Parameter(label: self.label, relabel: self.relabel, type: newType, isVisible: self.isVisible, isVariadic: self.isVariadic)
        return(newParameter as! Self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        return(Parameter(label: self.label, relabel: self.relabel, type:  substitution.substitute(self.type!), isVisible: self.isVisible, isVariadic: self.isVariadic) as! Self)
        }
        
    public override func deepCopy() -> Self
        {
        return(Parameter(label: self.label, relabel: self.relabel, type: self.type!.deepCopy(), isVisible: self.isVisible, isVariadic: self.isVariadic) as! Self)
        }
        
    public func flatten() -> Parameter
        {
        Parameter(label: self.label, relabel: self.relabel, type: self.type!.type!, isVisible: self.isVisible, isVariadic: self.isVariadic)
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
