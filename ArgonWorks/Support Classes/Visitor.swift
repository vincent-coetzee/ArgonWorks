//
//  Visitor.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/11/21.
//

import Foundation

public protocol Visitor
    {
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
    }
