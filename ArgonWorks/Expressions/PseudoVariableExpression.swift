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
        
    private let variable: PseudoVariable
    
    init(_ variable: PseudoVariable)
        {
        self.variable = variable
        super.init()
        }
        
    init(_ variable: PseudoVariable,_ aClass:Class?)
        {
        self.variable = variable
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.variable = PseudoVariable(rawValue: coder.decodeString(forKey: "variable")!)!
        super.init(coder: coder)
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        fatalError()
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        PseudoVariableExpression(self.variable, nil) as! Self
        }
        
    public override func initializeType(inContext context: TypeContext)
        {
        if self.variable == .vSelf || self.variable == .vSELF || self.variable == .vSuper
            {
            let aType = (self.enclosingScope.initializerScope as! Initializer).declaringType
            self.type = aType
            }
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.variable.rawValue,forKey: "variable")
        super.encode(with: coder)
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
    }
