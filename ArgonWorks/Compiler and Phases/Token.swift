//
//  Token.swift
//  Neon
//
//  Created by Vincent Coetzee on 30/11/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation

public typealias Tokens = Array<Token>

public enum Token:CustomStringConvertible,CustomDebugStringConvertible,Identifiable
    {
    public static let systemClassNames = ["Object","Array","List","Set","Dictionary","Integer","Float","Boolean","Byte","Character","Pointer","Tuple","String","Symbol","Date","Time","DateTime"]
    
    public static func == (lhs: Token,rhs: Token.Keyword) -> Bool
        {
        switch(lhs)
            {
            case .keyword(let keyword,_):
                return(rhs == keyword)
            default:
                return(false)
            }
        }
        
    public static func == (lhs: Token,rhs: Token.Symbol) -> Bool
        {
        switch(lhs)
            {
            case .symbol(let symbol,_):
                return(rhs == symbol)
            default:
                return(false)
            }
        }
        
    public static func == (lhs: Token,rhs: String) -> Bool
        {
        switch(lhs)
            {
            case .operator(let symbol,_):
                return(rhs == symbol)
            default:
                return(false)
            }
        }
        
    public var id: Int
        {
        self.location.tokenStart
        }
        
//    public static func == (lhs: Token, rhs: Token) -> Bool
//        {
//        switch(lhs,rhs)
//            {
//            case (.none,.none):
//                return(true)
//            case (.symbol(let symbol1,_),Token.symbol(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.comment(let symbol1,_),Token.comment(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.identifier(let symbol1,_),Token.identifier(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.keyword(let symbol1,_),Token.keyword(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.string(let symbol1,_),Token.string(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.integer(let symbol1,_),Token.integer(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.float(let symbol1,_),Token.float(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.character(let symbol1,_),Token.character(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.byte(let symbol1,_),Token.byte(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.hashString(let symbol1,_),Token.hashString(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.end(_),Token.end(_)):
//                return(true)
//            case (.boolean(let symbol1,_),Token.boolean(let symbol2,_)):
//                return(symbol1 == symbol2)
//            case (.operator(let symbol1,_),Token.operator(let symbol2,_)):
//                return(symbol1 == symbol2)
//        default:
//            fatalError()
//        }
//        }
    
    public enum Symbol:String,CaseIterable,Equatable
        {
        static func ==(lhs:Symbol,rhs:Token) -> Bool
            {
            return(rhs.isSymbol && rhs.symbol == lhs)
            }
            
        case bitAndEquals = "&="
        case bitOrEquals = "|="
        case bitNotEquals = "~="
        case bitXorEquals = "^="
        case bitNot = "~"
        case bitAnd = "&"
        case bitOr = "|"
        case bitXor = "^"
        case bitShiftRight = ">>"
        case bitShiftLeft = "<<"
        case none = ""
        case doubleBackSlash = "\\\\"
        case leftParenthesis = "("
        case rightParenthesis = ")"
        case leftBrace = "{"
        case rightBrace = "}"
        case leftBracket = "["
        case rightBracket = "]"
        case colon = ":"
        case gluon = "::"
        case stop = "."
        case comma = ","
        case dollar = "$"
        case hash = "#"
        case at = "@"
        case assign = "="
        case rightArrow = "->"
        case doubleQuote = "\""
        case singleQuote = "'"
        case leftBrocket = "<"
        case rightBrocket = ">"
        case halfRange = ".."
        case fullRange = "..."
        case leftBrocketEquals = "<="
        case not = "!"
        case and = "&&"
        case or = "||"
        case minusMinus
        case modulus = "%"
        case modulusEquals = "%="
        case macroStart = "${"
        case macroEnd = "}$"
        case noteStart = "!*"
        case noteEnd = "*!"
        case pow = "**"
        case plusPlus
        case mulEquals = "*="
        case divEquals = "/="
        case addEquals = "+="
        case subEquals = "-="
        case rightBrocketEquals = "=>"
        case shiftLeftEquals = "<<="
        case shiftRightEquals = ">>="
        case mul = "*"
        case sub = "-"
        case div = "/"
        case add = "+"
        case equals = "=="
        case notEquals = "!="
        case other
        case cast = "to"
        case backslash = "\\"

        }

    public enum Keyword:String,CaseIterable,Equatable
        {
        case ALIAS
        case AS
        case BY
        case CHANGE
        case CLAIMED
        case CLASS
        case CLOSED
        case CONSTANT
        case DELEGATE
        case ELSE
        case ENUMERATION
        case EXPORTED
        case EXTENSION
        case LOOP
        case FORK
        case FROM
        case FUNCTION
        case HANDLE
        case IF
        case IMPORT
        case IN
        case INFIX
        case IS
        case LET
        case LOADED
        case LOCAL
        case MAIN
        case MAKE
        case MAPPING
        case me
        case Me
        case METHOD
        case MODULE
        case NEXT
        case `nil`
        case OPERATOR
        case OPEN
        case OTHERWISE
        case POSTFIX
        case PREFIX
        case PRIVATE
        case PROTECTED
        case PUBLIC
        case READ
        case READONLY
        case RECLAIMED
        case REPEAT
        case RETURN
        case RESUME
        case SEALED
        case SELECT
        case SCOPED
        case SIGNAL
        case SLOT
        case SUBSCRIPT
        case `super`
        case TIMES
        case TO
        case INTERCEPTOR
        case INTERCEPT
        case TYPE
        case UNLOADED
        case UNSEALED
        case VERSION
        case WHEN
        case WHILE
        case WITH
        case WRITE
        }
        
    public enum Directive: String
        {
        case none
        case main
        case intrinsic
        case stub
        }
        
    public class Operator:Equatable
        {
        public static let assign = Operator("=")
        
        public static func ==(lhs:Operator,rhs:Operator) -> Bool
            {
            return(lhs.operatorName == rhs.operatorName)
            }
            
        public var name: String
            {
            return(self.operatorName)
            }
            
        private let operatorName:String
        
        init(_ string:String)
            {
            self.operatorName = string
            }
        }
        
    public enum TokenType
        {
        case none
        case comment
        case end
        case identifier
        case name
        case keyword
        case symbol
        case hashString
        case string
        case integer
        case byte
        case float
        case character
        case date
        case time
        case dateTime
        case boolean
        case primitive
        case tag
        case operation
        case keyPath
        case directive
        case note
        case path
        }
        
    public var tokenType:TokenType
        {
        switch(self)
            {
            case .name:
                return(.name)
            case .invisible:
                return(.none)
            case .hashString:
                return(.hashString)
            case .note:
                return(.note)
            case .directive:
                return(.directive)
            case .comment:
                return(.comment)
            case .end:
                return(.end)
            case .identifier:
                return(.identifier)
            case .keyword:
                return(.keyword)
            case .string:
                return(.string)
            case .integer:
                return(.integer)
            case .float:
                return(.float)
            case .symbol:
                return(.symbol)
            case .none:
                return(.none)
            case .operator:
                return(.operation)
            case .character:
                return(.character)
            case .boolean:
                return(.boolean)
            case .byte:
                return(.byte)
            case .keyPath:
                return(.keyPath)
            case .date:
                return(.date)
            case .time:
                return(.time)
            case .dateTime:
                return(.dateTime)
            case .path:
                return(.path)
            }
        }
        
    case none
    case comment(String,Location)
    case end(Location)
    case identifier(String,Location)
    case keyword(Keyword,Location)
    case symbol(Symbol,Location)
    case hashString(String,Location)
    case string(String,Location)
    case integer(Argon.Integer,Location)
    case byte(Argon.UInteger8,Location)
    case date(Argon.Date,Location)
    case time(Argon.Time,Location)
    case dateTime(Argon.DateTime,Location)
    case float(Double,Location)
    case character(Argon.Character,Location)
    case boolean(Bool,Location)
    case `operator`(String,Location)
    case keyPath(String,Location)
    case directive(String,Location)
    case note(String,Location)
    case path(String,Location)
    case name(Name,Location)
    case invisible(String,Location)
    
    public init(_ symbol:String,_ location:Location)
        {
        if let aSymbol = Symbol(rawValue: symbol)
            {
            self = .symbol(aSymbol,location)
            }
        else
            {
            self = .symbol(.other,location)
            }
        }
        
    public var customOperatorString:String
        {
        switch(self)
            {
            case .operator(let string,_):
                return(string)
            default:
                fatalError("")
            }
        }
        
    public var debugDescription:String
        {
        return(self.description)
        }
        
    public var description:String
        {
        switch(self)
            {
            case .name(let string,_):
                return(".name(\(string))")
//                return(".name()")
            case .invisible(let string,_):
                return(".invisible(\(string))")
//                return(".invisible(...)")
            case .path(let string,_):
                return(".path(\(string))")
            case .hashString(let string,_):
                return(".symbolString(\(string))")
//                return(".symbolString()")
            case .note(let string,_):
                return(".note(\(string))")
//                return(".note()")
            case .directive(let string,_):
                return(".directive(\(string))")
//                return(".directive()")
            case .comment(let string,_):
                return(".comment(\(string))")
//                return(".comment()")
            case .end:
                return(".end")
            case .identifier(let string,_):
                return(".identifier(\(string.description))")
//                return(".identifier()")
            case .keyword(let keyword,_):
                return(".keyword(\(keyword))")
            case .string(let string,_):
                return(".string(\(string))")
//                return(".string()")
            case .integer(let value,_):
                return(".integer(\(value))")
            case .float(let value,_):
                return(".float(\(value))")
            case .symbol(let value,_):
                return(".symbol(\(value))")
            case .none:
                return(".none")
            case .operator(let string,_):
                return(".operator(\(string))")
            case .character(let char, _):
                return(".character(\(char))")
            case .boolean(let boolean, _):
                return(".boolean(\(boolean))")
            case .byte(let value,_):
                return(".byte(\(value))")
            case .keyPath(let value,_):
                return(".keyPath(\(value))")
            case .date(let date, _):
                return(".date(\(date))")
            case .time(let time,_):
                return(".time(\(time))")
            case .dateTime(let value,_):
                return(".dateTime(\(value))")
            }
        }
        
//
//    public var asSymbolAttribute: SymbolAttribute
//        {
//        if !self.isSymbolAttribute
//            {
//            fatalError("This should not happen")
//            }
//        else
//            {
//            switch(self.keyword)
//                {
//                case .EXPORTED:
//                    return(.exported)
//                case .PUBLIC:
//                    return(.public)
//                case .PROTECTED:
//                    return(.protected)
//                case .PRIVATE:
//                    return(.private)
//                case .OPEN:
//                    return(.open)
//                case .CLOSED:
//                    return(.closed)
//                case .SEALED:
//                    return(.sealed)
//                case .UNSEALED:
//                    return(.unsealed)
//                default:
//                    fatalError("This should not happen")
//                }
//            }
//        }
        
    public var isSystemClassKeyword: Bool
        {
        if !self.isKeyword
            {
            return(false)
            }
        return(Self.systemClassNames.contains(self.keyword.rawValue))
        }
        
    public var isName:Bool
        {
        switch(self)
            {
            case .name:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isPathLiteral:Bool
        {
        switch(self)
            {
            case .path:
                return(true)
            default:
                return(false)
            }
        }

    public var isInvisible:Bool
        {
        switch(self)
            {
            case .invisible:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isPlusPlus:Bool
        {
        switch(self)
            {
            case .operator(let symbol,_):
                return(symbol == "++")
            default:
                return(false)
            }
        }
        
    public var isMinusMinus:Bool
        {
        switch(self)
            {
            case .operator(let symbol,_):
                return(symbol == "--")
            default:
                return(false)
            }
        }
        
    public var isSystemClassName:Bool
        {
        switch(self)
            {
            case .identifier(let keyword,_):
                return(Self.systemClassNames.contains(keyword))
            default:
                return(false)
            }
        }
        
    public var pathLiteral:String
        {
        switch(self)
            {
            case .path(let identifier,_):
                return(identifier)
            default:
                fatalError()
            }
        }
        
    public var invisible:String
        {
        switch(self)
            {
            case .invisible(let identifier,_):
                return(identifier)
            default:
                fatalError()
            }
        }
        
    public var isBooleanOperator:Bool
        {
        return( self.isAnd || self.isOr )
        }
        
    public var byteValue:Argon.Byte
        {
        switch(self)
            {
            case .byte(let value,_):
                return(value)
            default:
                fatalError("Invalid call on Byte")
            }
        }
        
    public var booleanLiteral:Argon.Boolean
        {
        switch(self)
            {
            case .boolean(let value,_):
                return(value ? .trueValue : .falseValue)
            default:
                fatalError("Invalid call on Boolean")
            }
        }
        
    public var isBooleanLiteral:Bool
        {
        switch(self)
            {
            case .boolean:
                return(true)
            default:
                return(false)
            }
        }
        
    public var characterLiteral:Argon.Character
        {
        switch(self)
            {
            case .character(let value,_):
                return(value)
            default:
                fatalError("Invalid call on Character")
            }
        }
        
    public var stringLiteral:Argon.String
        {
        switch(self)
            {
            case .string(let value,_):
                return(value)
            default:
                fatalError("Invalid call on String")
            }
        }
        
//    public var typeParameter:String
//        {
//        switch(self)
//            {
//            case .typeParameter(let value,_):
//                return(value)
//            default:
//                fatalError("Invalid call on String")
//            }
//        }
        
    public var hashStringLiteral:Argon.Symbol
        {
        switch(self)
            {
            case .hashString(let value,_):
                return(value)
            default:
                fatalError("Invalid call on HashString")
            }
        }
        
    public var hashString:String
        {
        switch(self)
            {
            case .hashString(let string,_):
                return(string)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var symbolTypeString:String
        {
        switch(self)
            {
            case .symbol(let type,_):
                return(type.rawValue)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var location:Location
        {
        switch(self)
            {
            case .name(_,let location):
                return(location)
            case .invisible(_,let location):
                return(location)
            case .byte(_,let location):
                return(location)
            case .path(_,let location):
                return(location)
            case .note(_,let location):
                return(location)
            case .directive(_,let location):
                return(location)
            case .hashString(_,let location):
                return(location)
            case .comment(_,let location):
                return(location)
            case .end(let location):
                return(location)
            case .identifier(_,let location):
                return(location)
            case .keyword(_,let location):
                return(location)
            case .character(_,let location):
                return(location)
            case .boolean(_,let location):
                return(location)
            case .string(_,let location):
                return(location)
            case .integer(_,let location):
                return(location)
            case .float(_,let location):
                return(location)
            case .symbol(_,let location):
                return(location)
            case .none:
                return(.zero)
            case .operator(_, let location):
                return(location)
            case .keyPath(_, let location):
                return(location)
            case .date(_,let location):
                return(location)
            case .time(_,let location):
                return(location)
            case .dateTime(_,let location):
                return(location)
            }
        }
        
    public var integerLiteral:Argon.Integer
        {
        switch(self)
            {
            case .integer(let value,_):
                return(value)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var dateLiteral:Argon.Date
        {
        switch(self)
            {
            case .date(let value,_):
                return(value)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var timeLiteral:Argon.Time
        {
        switch(self)
            {
            case .time(let value,_):
                return(value)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var dateTimeLiteral:Argon.DateTime
        {
        switch(self)
            {
            case .dateTime(let value,_):
                return(value)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var floatingPointLiteral:Double
        {
        switch(self)
            {
            case .float(let name,_):
                return(name)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var nameLiteral:Name
        {
        switch(self)
            {
            case .name(let name,_):
                return(name)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var operatorName:String
        {
        switch(self)
            {
            case .operator(let name,_):
                return(name)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var `operator`:Token.Operator
        {
        switch(self)
            {
            case .operator(let name,_):
                return(Operator(name))
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
    
    public var identifier:String
        {
        switch(self)
            {
            case .identifier(let name,_):
                return(name)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var note:String
        {
        switch(self)
            {
            case .note(let name,_):
                return(name)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var keyword:Keyword
        {
        switch(self)
            {
            case .keyword(let name,_):
                return(name)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self)) \(self)")
            }
        }
        
    public var keywordString:String
        {
        switch(self)
            {
            case .keyword(let name,_):
                return("\(name)")
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
    
    public var symbol:Symbol
        {
        switch(self)
            {
            case .symbol(let name,_):
                return(name)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var string:String
        {
        switch(self)
            {
            case .string(let name,_):
                return(name)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var integer:Argon.Integer
        {
        switch(self)
            {
            case .integer(let value,_):
                return(value)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
    
    public var floatingPoint:Double
        {
        switch(self)
            {
            case .float(let value,_):
                return(value)
            default:
                fatalError("This should not be called on a Token of class \(Swift.type(of: self))")
            }
        }
        
    public var isType:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .TYPE)
            default:
                return(false)
            }
        }
        
    public var isCastOperator:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .TO)
            default:
                return(false)
            }
        }
        
    public var isVersion:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .VERSION)
            default:
                return(false)
            }
        }
        
    public var isFork:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .FORK)
            default:
                return(false)
            }
        }
        
    public var isFrom:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .FROM)
            default:
                return(false)
            }
        }
        
    public var isTo:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .TO)
            default:
                return(false)
            }
        }
        
    public var isMake:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .MAKE)
            default:
                return(false)
            }
        }
        
    public var isPrivacyModifier:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .PROTECTED || value == .PUBLIC || value == .PRIVATE || value == .EXPORTED)
            default:
                return(false)
            }
        }
        
    public var isBy:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .BY)
            default:
                return(false)
            }
        }
        
    public var isRepeat:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .REPEAT)
            default:
                return(false)
            }
        }
        
    public var isNameComponent:Bool
        {
        return(self.isIdentifier)
        }
        
    public var isDateLiteral:Bool
        {
        switch(self)
            {
            case .date:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isTimeLiteral:Bool
        {
        switch(self)
            {
            case .time:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isDateTimeLiteral:Bool
        {
        switch(self)
            {
            case .dateTime:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isNext:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .NEXT)
            default:
                return(false)
            }
        }
        
    public var isResume:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .RESUME)
            default:
                return(false)
            }
        }
        
    public var isIs:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .IS)
            default:
                return(false)
            }
        }
        
    public var isNilLiteral:Bool
        {
        switch(self)
            {
            case .keyword(let keyword,_):
                return(keyword == .nil)
            default:
                return(false)
            }
        }
        
    public var isStop:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .stop)
            default:
                return(false)
            }
        }
        
    public var isRightArrow:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .rightArrow)
            default:
                return(false)
            }
        }
        
    public var isColon:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .colon)
            default:
                return(false)
            }
        }
        
    public var isIntegerLiteral:Bool
        {
        switch(self)
            {
            case .integer:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isFloatingPointLiteral:Bool
        {
        switch(self)
            {
            case .float:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isByteLiteral:Bool
        {
        switch(self)
            {
            case .byte:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isCharacterLiteral:Bool
        {
        switch(self)
            {
            case .character:
                return(true)
            default:
                return(false)
            }
        }
        
    public var byteLiteral:Argon.Byte
        {
        switch(self)
            {
            case .byte(let byte,_):
                return(byte)
            default:
                fatalError("byteLiteral invoked on non byte literal")
            }
        }
    
    public var isOperator:Bool
        {
        switch(self)
            {
            case .operator:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isByte:Bool
        {
        switch(self)
            {
            case .byte:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isTime:Bool
        {
        switch(self)
            {
            case .time:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isDateTime:Bool
        {
        switch(self)
            {
            case .dateTime:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isReturn:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .RETURN)
            default:
                return(false)
            }
        }
        
    public var isFunction:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .FUNCTION)
            default:
                return(false)
            }
        }
        
    public var isExported:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .EXPORTED)
            default:
                return(false)
            }
        }
        
    public var isSealed:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .SEALED)
            default:
                return(false)
            }
        }
        
    public var isUnsealed:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .UNSEALED)
            default:
                return(false)
            }
        }
        
    public var isOpen:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .OPEN)
            default:
                return(false)
            }
        }
        
    public var isClosed:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .CLOSED)
            default:
                return(false)
            }
        }
        
    public var isSymbolAttribute:Bool
        {
        return(self.isOpen || self.isClosed || self.isSealed || self.isUnsealed || self.isPublic || self.isPrivate || self.isProtected || self.isExported)
        }
        
    public var isLoaded:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .LOADED)
            default:
                return(false)
            }
        }
        
    public var isUnloaded:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .UNLOADED)
            default:
                return(false)
            }
        }
        
    public var isReclaimed:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .RECLAIMED)
            default:
                return(false)
            }
        }
        
    public var isMain:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .MAIN)
            default:
                return(false)
            }
        }
        
    public var isBackSlash:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .backslash)
            default:
                return(false)
            }
        }
        
    public var isHashString:Bool
        {
        switch(self)
            {
            case .hashString:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isForwardSlash:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .div)
            default:
                return(false)
            }
        }
        
    public var isNote:Bool
        {
        switch(self)
            {
            case .note:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isDirective:Bool
        {
        switch(self)
            {
            case .directive:
                return(true)
            default:
                return(false)
            }
        }
        
    public var directive: Directive
        {
        switch(self)
            {
            case .directive(let string,_):
                return(Directive(rawValue: string) ?? .none)
            default:
                fatalError()
            }
        }
        
    public var isRead:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .READ)
            default:
                return(false)
            }
        }
        
    public var isReadOnly:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .READONLY)
            default:
                return(false)
            }
        }
        
        
    public var isRangeOperator:Bool
        {
        return(self.isHalfRange || self.isFullRange)
        }
    
    public var isTimes:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .TIMES)
            default:
                return(false)
            }
        }
        
    public var isAlias:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .ALIAS)
            default:
                return(false)
            }
        }
        
    public var isSlot:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .SLOT)
            default:
                return(false)
            }
        }
        
    public var isCharacter:Bool
        {
        switch(self)
            {
            case .character:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isClass:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .CLASS)
            default:
                return(false)
            }
        }
        
    public var isChange:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .CHANGE)
            default:
                return(false)
            }
        }
    
    public var isLoop:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .LOOP)
            default:
                return(false)
            }
        }
        
    public var isIf:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .IF)
            default:
                return(false)
            }
        }
        
    public var isWith:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .WITH)
            default:
                return(false)
            }
        }
    
    public var isWhen:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .WHEN)
            default:
                return(false)
            }
        }
        
    public var isWrite:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .WRITE)
            default:
                return(false)
            }
        }
        
    public var isLowerMe:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .me)
            default:
                return(false)
            }
        }
        
    public var isSuper:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .super)
            default:
                return(false)
            }
        }
        
    public var isIn:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .IN)
            default:
                return(false)
            }
        }
        
    public var isOtherwise:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .OTHERWISE)
            default:
                return(false)
            }
        }
        
    public var isSelect:Bool
        {
         switch(self)
            {
            case .keyword(let value,_):
                return(value == .SELECT)
            default:
                return(false)
            }
        }
        
    public var isSignal:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .SIGNAL)
            default:
                return(false)
            }
        }
        
    public var isHandle:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .HANDLE)
            default:
                return(false)
            }
        }
        
    public var isScoped:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .SCOPED)
            default:
                return(false)
            }
        }
        
    public var isWhile:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .WHILE)
            default:
                return(false)
            }
        }
        
    public var isAccessModifier:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .EXPORTED || value == .PRIVATE || value == .PUBLIC || value == .PROTECTED)
            default:
                return(false)
            }
        }

    public var isHashStringLiteral:Bool
        {
        switch(self)
            {
            case .hashString:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isStringLiteral:Bool
        {
        switch(self)
            {
            case .string:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isLiteral:Bool
        {
        return(self.isStringLiteral || self.isIntegerLiteral || self.isFloatingPointLiteral || self.isHashStringLiteral || self.isByteLiteral || self.isCharacterLiteral)
        }
    
    
    public var isMethod:Bool
        {
        switch(self)
            {
            case .keyword(let keyword,_):
                return(keyword == .METHOD)
            default:
                return(false)
            }
        }

    public var isUpperMe:Bool
        {
        switch(self)
            {
            case .keyword(let keyword,_):
                return(keyword == .Me)
            default:
                return(false)
            }
        }
        
    public var isElse:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .ELSE)
            default:
                return(false)
            }
        }
    
    public var isNot:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .not)
            default:
                return(false)
            }
        }
        
    public var isNumber:Bool
        {
        switch(self)
            {
            case .integer:
                return(true)
            case .float:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isComma:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .comma)
            default:
                return(false)
            }
        }
    
    public var isBitAnd:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitAnd)
            default:
                return(false)
            }
        }

    public var isBitOr:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitOr)
            default:
                return(false)
            }
        }
        
    public var isBar:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitOr)
            default:
                return(false)
            }
        }
        
    public var isBitXor:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitXor)
            default:
                return(false)
            }
        }
        
    public var isBitXorEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitXorEquals)
            default:
                return(false)
            }
        }
        
    public var isHollowVariableIdentifier:Bool
        {
        switch(self)
            {
            case .identifier(let value,_):
                return(value.hasPrefix("?"))
            default:
                return(false)
            }
        }
        
    public var isBitNot:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitNot)
            default:
                return(false)
            }
        }
        
    public var isLeftBracket:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .leftBracket)
            default:
                return(false)
            }
        }
    
    public var isRightBracket:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .rightBracket)
            default:
                return(false)
            }
        }
    
    public var isLeftBrace:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .leftBrace)
            default:
                return(false)
            }
        }
    
    public var isRightBrace:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .rightBrace)
            default:
                return(false)
            }
        }
    
//    public var isTag:Bool
//        {
//        switch(self)
//            {
//            case .tag:
//                return(true)
//            default:
//                return(false)
//            }
//        }
//
        
    public var isLeftBrocket:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .leftBrocket)
            default:
                return(false)
            }
        }
    
    public var isRightBrocket:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .rightBrocket)
            default:
                return(false)
            }
        }
        
    public var isLogicalOperator:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .and || value == .or)
            default:
                return(false)
            }
        }

    public var isBitOperator:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitAnd || value == .bitOr || value == .bitXor)
            default:
                return(false)
            }
        }
        
    public var isPowerOperator:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .pow)
            default:
                return(false)
            }
        }
        
    public var isAdditionOperator:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .add || value == .sub)
            default:
                return(false)
            }
        }

    public var isMultiplicationOperator:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .mul || value == .div || value == .modulus)
            default:
                return(false)
            }
        }
        
    public var isRelationalOperator:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .rightBrocket || value == .rightBrocketEquals || value == .leftBrocket || value == .leftBrocketEquals || value == .equals || value == .notEquals)
            default:
                return(false)
            }
        }
        
    public var isLeftBrocketEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .leftBrocketEquals)
            default:
                return(false)
            }
        }
    
    public var isRightBrocketEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .rightBrocketEquals)
            default:
                return(false)
            }
        }
    
    public var isRightBitShift:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitShiftRight)
            default:
                return(false)
            }
        }
        
    public var isLeftBitShift:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitShiftLeft)
            default:
                return(false)
            }
        }
        
    public var isDollar:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .dollar)
            default:
                return(false)
            }
        }
        
    public var isFullRange:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .fullRange)
            default:
                return(false)
            }
        }
        
    public var isLeftPar:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .leftParenthesis)
            default:
                return(false)
            }
        }
    
    public var isRightPar:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .rightParenthesis)
            default:
                return(false)
            }
        }
    
    public var isHash:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .hash)
            default:
                return(false)
            }
        }
        
    public var isAt:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .at)
            default:
                return(false)
            }
        }
        
    public var isSubscript:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .SUBSCRIPT)
            default:
                return(false)
            }
        }
        
    public var isEnd:Bool
        {
        switch(self)
            {
            case .end:
                return(true)
            default:
                return(false)
            }
        }


    public var isHalfRange:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .halfRange)
            default:
                return(false)
            }
        }
    
    public var isMulEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .mulEquals)
            default:
                return(false)
            }
        }
    
    public var isSubEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .subEquals)
            default:
                return(false)
            }
        }
    
    public var isDivEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .divEquals)
            default:
                return(false)
            }
        }
    
    public var isAddEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .addEquals)
            default:
                return(false)
            }
        }
        
    public var isBitAndEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitAndEquals)
            default:
                return(false)
            }
        }
    
    public var isBitNotEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitNotEquals)
            default:
                return(false)
            }
        }
        
    public var isPower:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .pow)
            default:
                return(false)
            }
        }
        
//    public var isTypeParameter:Bool
//        {
//        switch(self)
//            {
//            case .typeParameter:
//                return(true)
//            default:
//                return(false)
//            }
//        }
//
    public var isBitOrEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitOrEquals)
            default:
                return(false)
            }
        }
        
    public var isMul:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .mul)
            default:
                return(false)
            }
        }
    
    public var isSub:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .sub)
            default:
                return(false)
            }
        }
    
    public var isDiv:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .div)
            default:
                return(false)
            }
        }
    
    public var isAdd:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .add)
            default:
                return(false)
            }
        }
        
    public var isKindOfAssignmentSymbol:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .assign || value == .addEquals || value == .subEquals || value == .divEquals || value == .mulEquals || value == .modulusEquals || value == .bitAndEquals || value == .bitOrEquals || value == .bitXorEquals || value == .bitNotEquals || value == .shiftLeftEquals || value == .shiftRightEquals)
            default:
                return(false)
            }
        }
    
    public var isModulus:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .modulus)
            default:
                return(false)
            }
        }
        
    public var isAnd:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .and)
            default:
                return(false)
            }
        }
        
    public var isOr:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .or)
            default:
                return(false)
            }
        }
        
    public var isModule:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .MODULE)
            default:
                return(false)
            }
        }
        
    public var isPrefix:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .PREFIX)
            default:
                return(false)
            }
        }
    
    public var isPostfix:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .POSTFIX)
            default:
                return(false)
            }
        }
    
    public var isInfix:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .INFIX)
            default:
                return(false)
            }
        }
    
    public var isEnumeration:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .ENUMERATION)
            default:
                return(false)
            }
        }
        
    public var isLet:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .LET)
            default:
                return(false)
            }
        }
        
    public var isImport:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .IMPORT)
            default:
                return(false)
            }
        }
        
    public var isMacroStart:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .macroStart)
            default:
                return(false)
            }
        }
        
    public var isMacroEnd:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .macroEnd)
            default:
                return(false)
            }
        }
        
    public var isPublic:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .PUBLIC)
            default:
                return(false)
            }
        }
        
    public var isPrivate:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .PRIVATE)
            default:
                return(false)
            }
        }
        
    public var isProtected:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .PROTECTED)
            default:
                return(false)
            }
        }
        
    public var isAs:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .AS)
            default:
                return(false)
            }
        }
        
    public var isConstant:Bool
        {
        switch(self)
            {
            case .keyword(let value,_):
                return(value == .CONSTANT)
            default:
                return(false)
            }
        }
        
    public var isAssign:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .assign)
            default:
                return(false)
            }
        }
        
    public var isEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .equals)
            default:
                return(false)
            }
        }
        
    public var isNotEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .notEquals)
            default:
                return(false)
            }
        }
    
    public var isBitShiftRight:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitShiftRight)
            default:
                return(false)
            }
        }
        
    public var isBitShiftLeft:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .bitShiftLeft)
            default:
                return(false)
            }
        }
        
    public var isBitShiftRightEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .shiftRightEquals)
            default:
                return(false)
            }
        }
        
    public var isBitShiftLeftEquals:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .shiftLeftEquals)
            default:
                return(false)
            }
        }
        
    public  var isComment:Bool
        {
        switch(self)
            {
            case .comment:
                return(true)
            default:
                return(false)
            }
        }

    public var isKeyword:Bool
        {
        switch(self)
            {
            case .keyword:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isKeyPath:Bool
        {
        switch(self)
            {
            case .keyPath:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isIdentifier:Bool
        {
        switch(self)
            {
            case .identifier:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isSymbol:Bool
        {
        switch(self)
            {
            case .symbol:
                return(true)
            default:
                return(false)
            }
        }
    
    public var isGluon:Bool
        {
        switch(self)
            {
            case .symbol(let value,_):
                return(value == .gluon)
            default:
                return(false)
            }
        }
    }
