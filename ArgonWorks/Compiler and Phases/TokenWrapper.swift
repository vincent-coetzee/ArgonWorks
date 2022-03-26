//
//  TokenWrapper.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/2/22.
//

import Foundation

//public typealias PrefixHandler = (Parser,Token) -> Expression
//public typealias InfixHandler = (Parser,Token,Expression) -> Expression
//
//public enum TokenActionWrapper
//    {
//    case led(InfixHandler)
//    case nud(PrefixHandler)
//    }
//    
//public class DecoratedToken
//    {
//    public var lbp: Int
//        {
//        self.bindingPower
//        }
//        
//    public var bindingPower: Int = 0
//    public var operatorName: String
//        {
//        self.token.operatorString
//        }
//        
//    public var tokenType: ParseToken.TokenType
//        {
////        self.token.tokenType
//        .identifier
//        }
//        
//    public let token: Token
//    public var led: InfixHandler = { a,b,c -> Expression in Expression()}
//    public var nud: PrefixHandler = {(a,b) -> Expression in Expression()}
//    
//    init(token: Token)
//        {
//        self.token = token
//        }
//    }
//
