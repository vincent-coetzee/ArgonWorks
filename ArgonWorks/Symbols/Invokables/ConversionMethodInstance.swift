//
//  ConversionMethodInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/12/21.
//

import Foundation

public class MakerMethodInstance: MethodInstance
    {
    public static func from(_ from: Type,to: Type) -> MakerMethodInstance
        {
        let method = MakerMethodInstance(label: from.label)
        method.returnType = to
        method.parameters = [Parameter(label: "from", relabel: nil, type: from, isVisible: false, isVariadic: false)]
        return(method)
        }
    }
