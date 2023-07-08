//
//  Scope.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/10/21.
//

import Foundation

    
public protocol Scope: IssueHolder
    {
    var isMethodInstanceScope: Bool { get }
    var module: Module! { get }
    var parentScope: Scope? { get set }
    func addSymbol(_ symbol: Symbol)
    func addLocalSlot(_ localSlot: LocalSlot)
    func lookup(label: Label) -> Symbol?
    func lookup(name: Name) -> Symbol?
    func lookupN(label: Label) -> Symbols?
    func lookupN(name: Name) -> Symbols?
    func setContainer(_ scope: Scope?)
    }

extension Scope
    {
    public var containsMethodInstanceScope: Bool
        {
        if self.isMethodInstanceScope
            {
            return(true)
            }
        if self.parentScope.isNil
            {
            return(false)
            }
        return(self.parentScope!.containsMethodInstanceScope)
        }
        
    public mutating func setContainer(_ scope: Scope?)
        {
        self.parentScope = scope!
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
