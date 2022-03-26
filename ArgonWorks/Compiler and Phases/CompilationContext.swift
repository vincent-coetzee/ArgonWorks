//
//  CompilationContext.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 24/3/22.
//

import Foundation

public class CompilationContext: ContainerSymbol,Scope
    {
    public var parentScope: Scope?
    
    public var enclosingMethodInstance: MethodInstance
        {
        self.parentScope!.enclosingMethodInstance
        }
    
    public func lookupType(label: Label) -> Type?
        {
        for aType in self.allSymbols.compactMap({$0 as? Type})
            {
            if aType.label == label
                {
                return(aType)
                }
            }
        return(self.parentScope?.lookupType(label: label))
        }
    
    public init(parentScope: Scope)
        {
        self.parentScope = parentScope
        super.init(label: "")
        }
        
    public required init(label: Label)
        {
        fatalError("Not implemented.")
        }
        
    public required init?(coder: NSCoder)
        {
        fatalError("Not implemented.")
        }
    }
