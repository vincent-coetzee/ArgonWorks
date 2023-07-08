//
//  PrivacyScope.swift
//  PrivacyScope
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public enum PrivacyScope:String,Storable
    {
    case exported = "EXPORTED"
    case `public` = "PUBLIC"
    case `private` = "PRIVATE"
    case children = "CHILDREN"
    
    public init(input: InputFile) throws
        {
        fatalError()
        }
    
    public func write(output: OutputFile) throws
        {
        try output.write(self)
        }
    }
