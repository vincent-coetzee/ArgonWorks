//
//  TokenSource.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public protocol TokenSource
    {
    var lineNumber: LineNumber { get set }
    func nextToken() -> Token
    func peekToken(count: Int) -> Token
    }
    
public class TokenHolder: TokenSource
    {
    public var lineNumber: LineNumber = EmptyLineNumber()
        
    private let tokens: Tokens
    private var tokenIndex: Int
    
    init(tokens: Tokens)
        {
        self.tokens = tokens
        self.tokenIndex = 0
        }
        
    public func nextToken() -> Token
        {
        let index = self.tokenIndex
        self.tokenIndex += 1
        return(self.tokens[index])
        }
        
    public func peekToken(count: Int) -> Token
        {
        let index = self.tokenIndex + (count - 1)
        return(self.tokens[index])
        }
    }
