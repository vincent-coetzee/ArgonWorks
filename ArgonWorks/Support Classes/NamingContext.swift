//
//  NamingContext.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public protocol NamingContext
    {
    var topModule: TopModule { get }
    var index: UUID { get }
    var primaryContext: NamingContext { get }
    func lookup(name:Name) -> Symbol?
    func lookup(label:Label) -> Symbol?
    func setSymbol(_ symbol:Symbol,atName: Name)
    }

public struct NullContext: NamingContext
    {
    public var topModule: TopModule
        {
        fatalError()
        }
        
    public var index: UUID
        {
        UUID()
        }
        
    public var primaryContext: NamingContext
        {
        return(self)
        }
        
    public func lookup(name:Name) -> Symbol?
        {
        nil
        }
        
    public func lookup(label:Label) -> Symbol?
        {
        nil
        }
        
    public func setSymbol(_ symbol:Symbol,atName: Name)
        {
        }
    }
