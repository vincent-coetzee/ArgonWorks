//
//  SemanticTokenRenderer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/10/21.
//

import Foundation

public enum TokenKind
        {
        case none
        case localSlot
        case classSlot
        case moduleSlot
        case instanceSlot
        case `class`
        case module
        case method
        case methodInvocation
        case function
        case functionInvocation
        case identifier
        case keyword
        case integer
        case float
        case string
        case symbol
        case path
        case name
        case invisible
        case note
        case directive
        case comment
        case end
        case `operator`
        case keypath
        case byte
        case character
        case boolean
        case date
        case time
        case dateTime
        case type
        case constant
        case enumeration
        case systemClass
        case typeAlias
        case genericClassParameter
        }
        
//public protocol SemanticTokenRenderer
//    {
//    func setKind(_ kind: TokenKind,ofToken token: ParseToken)
//    func update(_ string: String)
//    }
//
//public class NullTokenRenderer: SemanticTokenRenderer
//    {
//    public static let shared = NullTokenRenderer()
//    
//    public func setKind(_ kind: TokenKind,ofToken token: Token)
//        {
//        }
//        
//    public func update(_ string:String)
//        {
//        }
//    }
