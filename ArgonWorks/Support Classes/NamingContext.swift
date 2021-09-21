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
