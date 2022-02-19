//
//  MethodSignature.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/12/21.
//

import Foundation

public class MethodSelector
    {
    public var selector: String
        {
        return(self._selector)
        }
        
    private let _selector: String
    
    init(methodInstance:MethodInstance)
        {
        let typeNames = methodInstance.parameters.map{$0.type.displayString}
        let parmString = methodInstance.parameters.map{$0.isVisible ? $0.label + "::" + $0.type.displayString: "_::" + $0.type.displayString}.joined(separator: ",")
        self._selector = methodInstance.label + "(" + parmString + ")"
        }
    }
