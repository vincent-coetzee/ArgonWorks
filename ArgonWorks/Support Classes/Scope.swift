//
//  Scope.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/10/21.
//

import Foundation

public protocol Scope
    {
    var topModule: TopModule { get }
    var isMethodInstanceScope: Bool { get }
    var isClosureScope: Bool { get }
    var isInitializerScope: Bool { get }
    var isSlotScope: Bool { get }
    var enclosingScope: Scope { get }
    func addSymbol(_ symbol: Symbol)
    func lookup(label: Label) -> Symbol?
    func lookup(name: Name) -> Symbol?
    func appendIssue(at: Location,message: String)
    func appendWarningIssue(at: Location,message: String)
    }

extension Scope
    {
    public var initializerScope: Scope
        {
        var scope: Scope = self
        while !scope.isInitializerScope
            {
            scope = scope.enclosingScope
            }
        return(scope)
        }
    }
