//
//  Visitor.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/11/21.
//

import Foundation

public protocol VisitorReceiver
    {
    func visit(visitor: Visitor) throws
    }
    
public protocol Visitor
    {
    init()
    func startVisit()
    func endVisit()
    func accept(_ block: Block) throws
//    func accept(_ closureBlock: ClosureBlock) throws
//    func accept(_ elseBlock: ElseBlock) throws
//    func accept(_ expressionBlock: ExpressionBlock)
//    func accept(_ forkBlock: ForkBlock) throws
    
    func accept(_ symbol: Symbol) throws
    
    func accept(_ expression: Expression) throws
    
    func accept(_ argument: Argument) throws
    
//    func accept(_ tuple: Tuple) throws
    }

extension Visitor
    {
    public static func visit(_ receiver: VisitorReceiver) -> Self
        {
        let visitor = Self()
        do
            {
            visitor.startVisit()
            try receiver.visit(visitor: visitor)
            visitor.endVisit()
            }
        catch let error
            {
            fatalError("\(error)")
            }
        return(visitor)
        }
    }
