//
//  SymbolFilter.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/9/21.
//

import Foundation

public struct SymbolFilter
    {
    public var children: Array<Symbol>
        {
        if let children = root?.children
            {
            if kind == .any
                {
                return(children)
                }
            if kind == .method
                {
                return(children.filter{$0 is Method || $0 is MethodInstance})
                }
            if kind == .class
                {
                return(children.filter{$0 is Class})
                }
            }
        return([])
        }
        
    private var root: Symbol?
    private var kind: ChildType
    
    public init(root:Symbol,kind: ChildType)
        {
        self.root = root
        self.kind = kind
        }
    }
