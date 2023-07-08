//
//  OperatorExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/10/21.
//

import Foundation

public class OperatorExpression: Expression
    {
    internal let operators: MethodInstances
    internal let operatorLabel: Label
    internal var methodInstance: MethodInstance?
    
    init(operatorLabel: Label,operators: MethodInstances)
        {
        self.operators = operators
        self.operatorLabel = operatorLabel
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE OPERATOR EXPRESSION")
        self.operators = coder.decodeObject(forKey: "operators") as! MethodInstances
        self.operatorLabel = coder.decodeObject(forKey: "operatorLabel") as! String
        self.methodInstance = coder.decodeObject(forKey: "methodInstance") as? MethodInstance
        super.init(coder: coder)
//        print("END DECODE OPERATOR EXPRESSION")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.operators,forKey: "operators")
        coder.encode(self.operatorLabel,forKey: "operatorLabel")
        coder.encode(self.methodInstance,forKey: "methodInstance")
        super.encode(with: coder)
        }
    }
    
