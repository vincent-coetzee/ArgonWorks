//
//  OperatorExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 14/10/21.
//

import Foundation

public class OperatorExpression: Expression
    {
    internal let operation: Operator
    
    init(operation: Operator)
        {
        self.operation = operation
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE OPERATOR EXPRESSION")
        self.operation = coder.decodeObject(forKey: "operation") as! Operator
        super.init(coder: coder)
//        print("END DECODE OPERATOR EXPRESSION")
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.operation,forKey: "operation")
        super.encode(with: coder)
        }
    }
    
