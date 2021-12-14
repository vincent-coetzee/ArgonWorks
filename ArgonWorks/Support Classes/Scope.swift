//
//  Scope.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/10/21.
//

import Foundation

public protocol ErrorScope
    {
    func appendIssue(at: Location,message: String)
    func appendWarningIssue(at: Location,message: String)
    }
    
public protocol Scope
    {
    var topModule: TopModule { get }
    var isMethodInstanceScope: Bool { get }
    var isClosureScope: Bool { get }
    var isInitializerScope: Bool { get }
    var isSlotScope: Bool { get }
    var enclosingScope: Scope { get }
    var enclosingBlockContext: BlockContext { get }
    var parent: Parent { get }
    func addSymbol(_ symbol: Symbol)
    func lookup(label: Label) -> Symbol?
    func lookup(name: Name) -> Symbol?
    func lookupN(label: Label) -> Symbols?
    func lookupN(name: Name) -> Symbols?
    func appendIssue(at: Location,message: String)
    }

extension Scope
    {        
    public var initializerScope: Scope
        {
        var scope: Scope = self
        while !scope.isInitializerScope
            {
            scope = scope.parent.enclosingScope
            }
        return(scope)
        }
        
    public func lookupPrefixOperatorInstances(label: Label) -> PrefixOperatorInstances?
        {
        if let items = self.lookupN(label: label)
            {
            let methods = items.compactMap{$0 as? PrefixOperatorInstance}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }
        
    public func lookupInfixOperatorInstances(label: Label) -> InfixOperatorInstances?
        {
        if let items = self.lookupN(label: label)
            {
            let methods = items.compactMap{$0 as? InfixOperatorInstance}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }
        
    public func lookupPostfixOperatorInstances(label: Label) -> PostfixOperatorInstances?
        {
        if let items = self.lookupN(label: label)
            {
            let methods = items.compactMap{$0 as? PostfixOperatorInstance}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }
        
    public func lookupMethodInstances(name: Name) -> Array<MethodInstance>?
        {
        if let items = self.lookupN(name: name)
            {
            let methods = items.filter{$0 is MethodInstance}.map{$0 as! MethodInstance}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }
        
    public func lookupFunctions(name: Name) -> Array<Function>?
        {
        if let items = self.lookupN(name: name)
            {
            let methods = items.filter{$0 is Function}.map{$0 as! Function}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }
        
    public func lookupTypes(name: Name) -> Types?
        {
        if let items = self.lookupN(name: name)
            {
            let types = items.filter{$0 is Type}.map{$0 as! Type}
            return(types.isEmpty ? nil : types)
            }
        return(nil)
        }
        
    public func lookupNonTypeSymbols(name: Name) -> Symbols?
        {
        if let items = self.lookupN(name: name)
            {
            let symbols = items.filter{!($0 is Type)}
            return(symbols.isEmpty ? nil : symbols)
            }
        return(nil)
        }
    }
