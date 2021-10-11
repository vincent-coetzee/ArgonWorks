//
//  VisualToken.swift
//  VisualToken
//
//  Created by Vincent Coetzee on 10/8/21.
//

import Foundation
import AppKit

fileprivate var TokenNumber:Int = 0

public class TokenRenderer
    {
    public enum Kind
        {
        case none
        case localSlot
        case classSlot
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
        case classParameter
        
        init(_ token:Token)
            {
            switch(token)
                {
            case .none:
                self = .none
            case .comment(_, _):
                self = .comment
            case .end(_):
                self = .none
            case .identifier(_, _):
                self = .identifier
            case .keyword(_, _):
                self = .keyword
            case .symbol(_, _):
                self = .operator
            case .hashString(_, _):
                self = .symbol
            case .string(_, _):
                self = .string
            case .integer(_, _):
                self = .integer
            case .byte(_, _):
                self = .byte
            case .date(_, _):
                self = .date
            case .time(_, _):
                self = .time
            case .dateTime(_, _):
                self = .dateTime
            case .float(_, _):
                self = .float
            case .character(_, _):
                self = .character
            case .boolean(_, _):
                self = .boolean
            case .operator(_, _):
                self = .operator
            case .keyPath(_, _):
                self = .keypath
            case .directive(_, _):
                self = .directive
            case .note(_, _):
                self = .note
            case .path(_, _):
                self = .path
            case .name(_, _):
                self = .name
            case .invisible(_, _):
                self = .none
                }
            }
        }
        
    internal var kind: Kind
        {
        get
            {
            fatalError()
            }
        set
            {
            self.attributes[self.currentToken.location.range]![.foregroundColor] = self.mapKindToForegroundColor(kind: newValue,systemClassNames: self.systemClassNames)
            }
        }
        
    public private(set) var attributes:Dictionary<NSRange,Dictionary<NSAttributedString.Key,Any>> = [:]
    private let systemClassNames: Array<String>
    private var currentToken:Token = Token.none


    init(systemClassNames: Array<String>)
        {
        self.systemClassNames = systemClassNames
        }
        
    public func set(kind someKind: Kind,forToken someToken: Token)
        {
        guard !someToken.isEnd else
            {
            return
            }
        self.attributes[someToken.location.range]![.foregroundColor] = self.mapKindToForegroundColor(kind: someKind,systemClassNames: self.systemClassNames)
        }
        
    public func processTokens(_ tokens: Tokens)
        {
        for token in tokens where !token.isEnd
            {
            if self.attributes[token.location.range].isNotNil
                {
                self.attributes[token.location.range]![.font] = SyntaxColorPalette.textFont
                }
            else
                {
                let start:[NSAttributedString.Key:Any] = [.font:SyntaxColorPalette.textFont,.foregroundColor: NSColor.argonBayside]
                self.attributes[token.location.range] = start
                }
            let color = self.mapTokenToForegroundColor(token: token)
            self.attributes[token.location.range]![.foregroundColor] = color
            }
        }
        
    public func setToken(_ token: Token)
        {
        guard !token.isEnd else
            {
            return
            }
        self.currentToken = token
        if var attributes = self.attributes[token.location.range]
            {
            attributes[.foregroundColor] = self.mapTokenToForegroundColor(token: token)
            self.attributes[token.location.range] = attributes
            }
        else
            {
            var attributes:[NSAttributedString.Key:Any] = [:]
            attributes[.foregroundColor] = self.mapTokenToForegroundColor(token: token)
            self.attributes[token.location.range] = attributes
            }
        }
        
    private func mapTokenToForegroundColor(token: Token) -> NSColor
        {
        switch(token)
            {
            case .name:
                return(SyntaxColorPalette.nameColor)
            case .invisible:
                return(NSColor.black)
            case .path:
                return(SyntaxColorPalette.pathColor)
            case .hashString:
                return(SyntaxColorPalette.symbolColor)
            case .note:
                return(NSColor.cyan)
            case .directive:
                return(SyntaxColorPalette.directiveColor)
            case .comment:
                return(SyntaxColorPalette.commentColor)
            case .end:
                return(NSColor.black)
            case .identifier:
                return(SyntaxColorPalette.identifierColor)
            case .keyword:
                return(SyntaxColorPalette.keywordColor)
            case .string:
                return(SyntaxColorPalette.stringColor)
            case .integer:
                return(SyntaxColorPalette.integerColor)
            case .float:
                return(SyntaxColorPalette.floatColor)
            case .symbol:
                return(SyntaxColorPalette.operatorColor)
            case .none:
                return(NSColor.cyan)
            case .operator:
                return(SyntaxColorPalette.operatorColor)
            case .character:
                return(SyntaxColorPalette.characterColor)
            case .boolean:
                return(SyntaxColorPalette.booleanColor)
            case .byte:
                return(SyntaxColorPalette.byteColor)
            case .keyPath:
                return(SyntaxColorPalette.keypathColor)
            case .date:
                return(SyntaxColorPalette.textColor)
            case .time:
                return(SyntaxColorPalette.textColor)
            case .dateTime:
                return(SyntaxColorPalette.textColor)
            }
        }
        
    public func mapKindToForegroundColor(kind:Kind,systemClassNames: Array<String>) -> NSColor
        {
        var localAttributes:[NSAttributedString.Key:Any] = [:]
        switch(kind)
            {
            case .none:
                break
            case .invisible:
                break
            case .keyword:
                localAttributes[.foregroundColor] = SyntaxColorPalette.keywordColor
            case .identifier:
                let identifier = self.currentToken.identifier
                if systemClassNames.contains(identifier)
                    {
                    localAttributes[.foregroundColor] = SyntaxColorPalette.systemClassColor
                    }
                else
                    {
                    localAttributes[.foregroundColor] = SyntaxColorPalette.identifierColor
                    }
            case .name:
                localAttributes[.foregroundColor] = SyntaxColorPalette.nameColor
            case .enumeration:
                localAttributes[.foregroundColor] = SyntaxColorPalette.enumerationColor
            case .comment:
                localAttributes[.foregroundColor] = SyntaxColorPalette.commentColor
            case .path:
                localAttributes[.foregroundColor] = SyntaxColorPalette.pathColor
            case .symbol:
                localAttributes[.foregroundColor] = SyntaxColorPalette.symbolColor
            case .string:
                localAttributes[.foregroundColor] = SyntaxColorPalette.stringColor
            case .class:
                localAttributes[.foregroundColor] = SyntaxColorPalette.classColor
            case .integer:
                localAttributes[.foregroundColor] = SyntaxColorPalette.integerColor
            case .float:
                localAttributes[.foregroundColor] = SyntaxColorPalette.floatColor
            case .directive:
                localAttributes[.foregroundColor] = SyntaxColorPalette.directiveColor
            case .methodInvocation:
                localAttributes[.foregroundColor] = SyntaxColorPalette.methodColor
            case .method:
                localAttributes[.foregroundColor] = SyntaxColorPalette.methodColor
            case .functionInvocation:
                localAttributes[.foregroundColor] = SyntaxColorPalette.functionColor
            case .function:
                localAttributes[.foregroundColor] = SyntaxColorPalette.functionColor
            case .localSlot:
                localAttributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .systemClass:
                localAttributes[.foregroundColor] = SyntaxColorPalette.systemClassColor
            case .classSlot:
                localAttributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .type:
                localAttributes[.foregroundColor] = SyntaxColorPalette.typeColor
            case .constant:
                localAttributes[.foregroundColor] = SyntaxColorPalette.constantColor
            case .module:
                localAttributes[.foregroundColor] = SyntaxColorPalette.identifierColor
            default:
                localAttributes[.foregroundColor] = NSColor.magenta
            }
        return(localAttributes[.foregroundColor]! as! NSColor)
        }
    }

        

