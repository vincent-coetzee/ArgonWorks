//
//  Scope.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/10/21.
//

import Foundation

    
public protocol Scope: IssueHolder
    {
//    var asContainer: Container { get }
//    var moduleScope: Module? { get }
    var parentScope: Scope? { get set }
    var enclosingMethodInstance: MethodInstance { get }
    var enclosingModule: Module { get }
    func addSymbol(_ symbol: Symbol)
    func removeSymbol(_ symbol: Symbol)
    func addLocalSlot(_ localSlot: LocalSlot)
    func lookupMethod(label: Label) -> Method?
    func lookupType(label: Label) -> Type?
    func lookup(label: Label) -> Symbol?
//    func lookup(name: Name) -> Symbol?
    func lookupN(label: Label) -> Symbols?
//    func lookupN(name: Name) -> Symbols?
//    func setContainer(_ scope: Scope?) 
    }

extension Scope
    {
//    public var containsMethodInstanceScope: Bool
//        {
//        if self.firstMethodInstanceScope.isNotNil
//            {
//            return(true)
//            }
//        if self.parentScope.isNil
//            {
//            return(false)
//            }
//        return(self.parentScope!.containsMethodInstanceScope)
//        }
        
    public var enclosingModule: Module
        {
        if (self as? Module).isNotNil
            {
            return(self as! Module)
            }
        return(self.parentScope!.enclosingModule)
        }
        
    public func methodInstanceSet(withLabel: Label) -> MethodInstanceSet
        {
        MethodInstanceSet(instances: self.lookupN(label: withLabel)?.compactMap{$0 as? MethodInstance})
        }
        
    public mutating func setContainer(_ scope: Scope?)
        {
        self.parentScope = scope!
        }
        
    public func lookupEnumeration(label: Label) -> TypeEnumeration?
        {
        if let item = self.lookupType(label: label) as? TypeEnumeration
            {
            return(item)
            }
        return(nil)
        }
        
    public func lookupPrefixOperators(label: Label) -> Operators?
        {
        if let items = self.lookupN(label: label)
            {
            let methods = items.compactMap{$0 as? Operator}.filter{$0.isPrefix}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }
        
    public func lookupInfixOperators(label: Label) -> Operators?
        {
        if let items = self.lookupN(label: label)
            {
            let methods = items.compactMap{$0 as? Operator}.filter{$0.isInfix}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }
        
    public func lookupPostfixOperators(label: Label) -> Operators?
        {
        if let items = self.lookupN(label: label)
            {
            let methods = items.compactMap{$0 as? Operator}.filter{$0.isPostfix}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }
        
//    public func lookupMethodInstances(name: Name) -> Array<MethodInstance>?
//        {
//        if let items = self.lookupN(name: name)
//            {
//            let methods = items.filter{$0 is MethodInstance}.map{$0 as! MethodInstance}
//            return(methods.isEmpty ? nil : methods)
//            }
//        return(nil)
//        }
        
    public func lookupMethodInstances(label: Label) -> Array<MethodInstance>?
        {
        if let items = self.lookupN(label: label)
            {
            let methods = items.filter{$0 is MethodInstance}.map{$0 as! MethodInstance}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }
        
    public func lookupFunctions(label: Label) -> Array<Function>?
        {
        if let items = self.lookupN(label: label)
            {
            let methods = items.filter{$0 is Function}.map{$0 as! Function}
            return(methods.isEmpty ? nil : methods)
            }
        return(nil)
        }

    public func lookupTypes(label: Label) -> Types?
        {
        if let items = self.lookupN(label: label)
            {
            let types = items.filter{$0 is Type}.map{$0 as! Type}
            return(types.isEmpty ? nil : types)
            }
        return(nil)
        }
        
//    public func lookupNonTypeSymbols(name: Name) -> Symbols?
//        {
//        if let items = self.lookupN(name: name)
//            {
//            let symbols = items.filter{!($0 is Type)}
//            return(symbols.isEmpty ? nil : symbols)
//            }
//        return(nil)
//        }
        
    public func hasMethod(withSignature signature: MethodSignature) -> Bool
        {
        self.methodInstanceSet(withLabel: signature.label).instancesMatching(signature).isNotEmpty
        }
    }
