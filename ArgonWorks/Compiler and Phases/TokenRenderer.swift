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
        didSet
            {
            self.mapKindToColors(kind: self.kind,systemClassNames: self.systemClassNames)
            }
        }
        
    internal var mappings = Dictionary<NSRange,Dictionary<NSAttributedString.Key,Any>>()
    private var _attributes:Dictionary<NSAttributedString.Key,Any> = [:]
    private let systemClassNames: Array<String>
    
    internal var currentToken:Token?
        {
        willSet
            {
            if let token = self.currentToken
                {
                self.mappings[token.location.range] = self._attributes
                }
            }
        didSet
            {
            self._attributes = [.font: SyntaxColorPalette.textFont]
            self.kind = .none
            if let token = self.currentToken
                {
                self.mapTokenToColors(token: token)
                self.kind = Kind(token)
                }
            }
        }

    init(systemClassNames: Array<String>)
        {
        self.systemClassNames = systemClassNames
        self.kind = .none
        }
        
    public func mapTokenToColors(token: Token)
        {
        switch(token)
            {
            case .name:
                self._attributes[.foregroundColor] = SyntaxColorPalette.nameColor
            case .invisible:
                break
            case .path:
                self._attributes[.foregroundColor] = SyntaxColorPalette.pathColor
            case .hashString:
                self._attributes[.foregroundColor] = SyntaxColorPalette.symbolColor
            case .note:
                break
            case .directive:
                self._attributes[.foregroundColor] = SyntaxColorPalette.directiveColor
            case .comment:
                self._attributes[.foregroundColor] = SyntaxColorPalette.commentColor
            case .end:
                break
            case .identifier:
                self._attributes[.foregroundColor] = SyntaxColorPalette.identifierColor
            case .keyword:
                self._attributes[.foregroundColor] = SyntaxColorPalette.keywordColor
            case .string:
                self._attributes[.foregroundColor] = SyntaxColorPalette.stringColor
            case .integer:
                self._attributes[.foregroundColor] = SyntaxColorPalette.integerColor
            case .float:
                self._attributes[.foregroundColor] = SyntaxColorPalette.floatColor
            case .symbol:
                self._attributes[.foregroundColor] = SyntaxColorPalette.operatorColor
            case .none:
                self._attributes[.foregroundColor] = NSColor.argonNeonFuchsia
            case .operator:
                self._attributes[.foregroundColor] = SyntaxColorPalette.operatorColor
            case .character:
                self._attributes[.foregroundColor] = SyntaxColorPalette.characterColor
            case .boolean:
                self._attributes[.foregroundColor] = SyntaxColorPalette.booleanColor
            case .byte:
                self._attributes[.foregroundColor] = SyntaxColorPalette.byteColor
            case .keyPath:
                self._attributes[.foregroundColor] = SyntaxColorPalette.keypathColor
            case .date:
                self._attributes[.foregroundColor] = SyntaxColorPalette.textColor
            case .time:
                self._attributes[.foregroundColor] = SyntaxColorPalette.textColor
            case .dateTime:
                self._attributes[.foregroundColor] = SyntaxColorPalette.textColor
            }
        }
        
    public func mapKindToColors(kind:Kind,systemClassNames: Array<String>)
        {
        switch(kind)
            {
            case .none:
                break
            case .invisible:
                break
            case .keyword:
                self._attributes[.foregroundColor] = SyntaxColorPalette.keywordColor
            case .identifier:
                let identifier = self.currentToken!.identifier
                if systemClassNames.contains(identifier)
                    {
                    self._attributes[.foregroundColor] = SyntaxColorPalette.systemClassColor
                    }
                else
                    {
                    self._attributes[.foregroundColor] = SyntaxColorPalette.identifierColor
                    }
            case .name:
                self._attributes[.foregroundColor] = SyntaxColorPalette.nameColor
            case .comment:
                self._attributes[.foregroundColor] = SyntaxColorPalette.commentColor
            case .path:
                self._attributes[.foregroundColor] = SyntaxColorPalette.pathColor
            case .symbol:
                self._attributes[.foregroundColor] = SyntaxColorPalette.symbolColor
            case .string:
                self._attributes[.foregroundColor] = SyntaxColorPalette.stringColor
            case .class:
                self._attributes[.foregroundColor] = SyntaxColorPalette.classColor
            case .integer:
                self._attributes[.foregroundColor] = SyntaxColorPalette.integerColor
            case .float:
                self._attributes[.foregroundColor] = SyntaxColorPalette.floatColor
            case .directive:
                self._attributes[.foregroundColor] = SyntaxColorPalette.directiveColor
            case .methodInvocation:
                self._attributes[.foregroundColor] = SyntaxColorPalette.methodColor
            case .method:
                self._attributes[.foregroundColor] = SyntaxColorPalette.methodColor
            case .functionInvocation:
                self._attributes[.foregroundColor] = SyntaxColorPalette.functionColor
            case .function:
                self._attributes[.foregroundColor] = SyntaxColorPalette.functionColor
            case .localSlot:
                self._attributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .classSlot:
                self._attributes[.foregroundColor] = SyntaxColorPalette.slotColor
            case .type:
                self._attributes[.foregroundColor] = SyntaxColorPalette.typeColor
            case .constant:
                self._attributes[.foregroundColor] = SyntaxColorPalette.constantColor
            default:
                self._attributes[.foregroundColor] = NSColor.magenta
            }
        }
    }

        

