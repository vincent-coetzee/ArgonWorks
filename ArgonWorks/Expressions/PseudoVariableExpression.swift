//
//  PseudoVariableExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 2/10/21.
//

import Foundation

public class PseudoVariableExpression: Expression
    {
    public override var canBeScoped: Bool
        {
        return(true)
        }
        
    internal enum PseudoVariable: String
        {
        case vSELF
        case vSelf
        case vSuper
        
        public var displayString: String
            {
            switch(self)
                {
                case .vSELF:
                    return("Self")
                case .vSelf:
                    return("self")
                case .vSuper:
                    return("super")
                }
            }
        }
        
    public override var isSelf: Bool
        {
        return(variable == .vSelf)
        }
        
    public override var isSELF: Bool
        {
        return(variable == .vSELF)
        }
        
    public override var isSuper: Bool
        {
        return(variable == .vSuper)
        }
        
    public override var type: Type
        {
        return(self._type)
        }
        
    private let variable: PseudoVariable
    private var _type: Type = .unknown
    
    init(_ variable: PseudoVariable)
        {
        self.variable = variable
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.variable = PseudoVariable(rawValue: coder.decodeString(forKey: "variable")!)!
        super.init(coder: coder)
        }
        
    public override func slotWithLabel(_ label: Label) -> Slot?
        {
        return(self._type.slotWithLabel(label))
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.variable.rawValue,forKey: "variable")
        super.encode(with: coder)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        if let initializer = self.context.firstInitializer,let aClass = initializer.declaringClass
            {
            self._type = aClass.type
            }
        else
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "'\(self.variable.displayString)' is not available in the current context.")
            }
        }
    }
