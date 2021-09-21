//
//  PrivacyScope.swift
//  PrivacyScope
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public enum PrivacyScope:String,Codable
    {
    case exported = "EXPORTED"
    case `public` = "PUBLIC"
    case `private` = "PRIVATE"
    case children = "CHILDREN"
    }
