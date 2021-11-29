//
//  TestVisitor.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 28/11/21.
//

import Foundation

public class TestVisitor: Visitor
    {
    private var allIssues = CompilerIssues()
    
    public func accept(_ block: Block) throws
        {
        print("\(Swift.type(of: block)) \(block.displayString)")
        self.allIssues.append(contentsOf: block.issues)
        }
    
    public func accept(_ symbol: Symbol) throws
        {
        print("\(Swift.type(of: symbol)) \(symbol.displayString)")
        self.allIssues.append(contentsOf: symbol.issues)
        }
    
    public func accept(_ expression: Expression) throws
        {
        print("\(Swift.type(of: expression)) \(expression.displayString)")
        self.allIssues.append(contentsOf: expression.issues)
        }
    
    public func accept(_ argument: Argument) throws
        {
        print("\(Swift.type(of: argument)) \(argument.displayString)")
        }
        
    public func startVisit()
        {
        }
        
    public func endVisit()
        {
        print("FOUND \(self.allIssues.count) ISSUES")
        for issue in self.allIssues
            {
            print("\(issue.location.line): \(issue.message)")
            }
        }
    }
