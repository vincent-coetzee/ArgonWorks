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
        
    public required init?(coder: NSCoder)
        {
        self.variable = PseudoVariable(rawValue: coder.decodeString(forKey: "variable")!)!
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.variable.rawValue,forKey: "variable")
        super.encode(with: coder)
        }
    }
