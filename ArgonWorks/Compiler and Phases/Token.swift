//
//  Token.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/2/22.
//

import Cocoa

public protocol TokenHandler
    {
    func kindChanged(token: Token)
    func issueAdded(token: Token,issue: CompilerIssue)
    }
    
public class Token:CustomStringConvertible
    {
    public static var systemClassNames: Array<String> = []
    
    public enum Keyword:String,CaseIterable,Equatable
        {
        case ALIAS
        case AS
        case BY
        case CHANGE
        case CLAIMED
        case CLASS
        case CLOSED
        case COCOON
        case CONSTANT
        case DELEGATE
        case ELSE
        case ELSEIF
        case ENUMERATION
        case EXPORTED
        case EXTENSION
        case FOR
        case FORK
        case FROM
        case FUNCTION
        case HANDLE
        case IF
        case IMPORT
        case IN
        case INFIX
        case INITIALIZER
        case CAST
        case IS
        case LET
        case LOADED
        case LOCAL
        case LOOP
        case MACRO
        case MANDATORY
        case MAIN
        case MAKE
        case MAPPING
        case METHOD
        case MODULE
        case NEXT
        case `nil`
        case OPERATOR
        case OPEN
        case OTHERWISE
        case POSTFIX
        case PREFIX
        case PRIMITIVE
        case PRIVATE
        case PROTECTED
        case PUBLIC
        case READ
        case READONLY
        case RECLAIMED
        case REPEAT
        case RETURN
        case RESUME
        case ROLE
        case SEALED
        case SELECT
        case SCOPED
        case SIGNAL
        case SLOT
        case SUBSCRIPT
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

    public enum Symbol:String,CaseIterable,Equatable
        {
//        static func ==(lhs:Symbol,rhs:Token) -> Bool
//            {
//            return(rhs.isSymbol && rhs.symbol == lhs)
//            }
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
        case semicolon = ";"
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
        case minusMinus = "--"
        case modulus = "%"
        case modulusEquals = "%="
        case macroStart = "${"
        case macroStop = "}$"
        case noteStart = "!*"
        case noteEnd = "*!"
        case pow = "**"
        case plusPlus = "++"
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
        case backslash = "\\"
        case tester = "??"
        case ternary = "?"
        case cast = "!!"

        public var isOperator: Bool
            {
            switch(self)
                {
                case .macroStart,.macroStop,.noteStart,.noteEnd,.semicolon,.colon:
                    break
                case .none,.doubleBackSlash,.leftParenthesis,.rightParenthesis,.leftBracket,.rightBracket,.leftBrace,.rightBrace:
                    break
                case .gluon,.stop,.comma,.dollar,.hash,.at,.assign,.rightArrow,.doubleQuote,.singleQuote,.leftBrocket,.rightBrocket:
                    break
                case .halfRange,.fullRange,.not,.other,.cast,.backslash,.and,.or:
                    break
                case .equals,.notEquals,.leftBrocketEquals,.rightBrocketEquals:
                    break
                case .ternary,.tester:
                    break
                default:
                    return(true)
                }
            return(false)
            }
        }

    public var description: String
        {
        self.displayString
        }
        
    public var displayString: String
        {
        "Token()"
        }
        
        
    public var isAssignmentOperator: Bool
        {
        false
        }
        
    public var isModuleLevelKeyword: Bool
        {
        false
        }
        
    public var isIs: Bool
        {
        false
        }
        
    public var isType: Bool
        {
        false
        }
        
    public var isEnumeration: Bool
        {
        false
        }
        
    public var isPlusPlus: Bool
        {
        false
        }
        
    public var isMinusMinus: Bool
        {
        false
        }
        
    public var isFullRange: Bool
        {
        false
        }
        
    public var isAddEquals: Bool
        {
        false
        }
        
    public var isSubEquals: Bool
        {
        false
        }
        
    public var isMulEquals: Bool
        {
        false
        }
        
    public var isDivEquals: Bool
        {
        false
        }
        
    public var isModEquals: Bool
        {
        false
        }
        
    public var isBitAndEquals: Bool
        {
        false
        }
        
    public var isBitOrEquals: Bool
        {
        false
        }
        
    public var isBitXorEquals: Bool
        {
        false
        }
        
    public var isBitNotEquals: Bool
        {
        false
        }
        
    public var isPower: Bool
        {
        false
        }
        
    public var isWith: Bool
        {
        false
        }
        
    public var isFork: Bool
        {
        false
        }
        
    public var isElseIf: Bool
        {
        false
        }
        
    public var isWhile: Bool
        {
        false
        }
        
    public var isSignal: Bool
        {
        false
        }
        
    public var isHandle: Bool
        {
        false
        }
        
    public var isReturn: Bool
        {
        false
        }
        
    public var isBitAnd: Bool
        {
        false
        }
        
    public var isMake: Bool
        {
        false
        }
        
    public var isModule: Bool
        {
        false
        }
        
    public var isInitializer: Bool
        {
        false
        }
        
    public var isMandatory: Bool
        {
        false
        }
        
    public var isDateLiteral: Bool
        {
        false
        }
        
    public var isDateTimeLiteral: Bool
        {
        false
        }
        
    public var isTimeLiteral: Bool
        {
        false
        }
        
    public var isNilLiteral: Bool
        {
        false
        }
        
    public var isBooleanLiteral: Bool
        {
        false
        }
        
    public var isNot: Bool
        {
        false
        }
        
    public var isBitOr: Bool
        {
        false
        }
        
    public var isBitXor: Bool
        {
        false
        }
        
    public var isBitNot: Bool
        {
        false
        }
        
    public var operatorString: String
        {
        fatalError()
        }
        
    public var isSystemClassName: Bool
        {
        false
        }
        
    public var isTester: Bool
        {
        false
        }
        
    public var isCast: Bool
        {
        false
        }
        
    public var isTernary: Bool
        {
        false
        }
        
    public var isColon: Bool
        {
        false
        }
        
    public var isSemicolon: Bool
        {
        false
        }
        
    public var isAnd: Bool
        {
        false
        }
        
    public var isOr: Bool
        {
        false
        }
        
    public var isSub: Bool
        {
        false
        }
        
    public var isAdd: Bool
        {
        false
        }
        
    public var isMul: Bool
        {
        false
        }
        
    public var isDiv: Bool
        {
        false
        }
        
    public var isModulus: Bool
        {
        false
        }
        
    public var isLeftBrocket: Bool
        {
        false
        }
        
    public var isRightBrocket: Bool
        {
        false
        }
        
    public var isEquals: Bool
        {
        false
        }
        
    public var isNotEquals: Bool
        {
        false
        }
        
    public var isRightBrocketEquals: Bool
        {
        false
        }
        
    public var isLeftBrocketEquals: Bool
        {
        false
        }
        
    public var isAssign: Bool
        {
        false
        }
        
    public var isMethod: Bool
        {
        false
        }
        
    public var isRightPar: Bool
        {
        false
        }
        
    public var isLeftPar: Bool
        {
        false
        }
        
    public var isPrimitive: Bool
        {
        false
        }
        
    public var isIntegerLiteral: Bool
        {
        false
        }
        
    public var isFloatLiteral: Bool
        {
        false
        }
        
    public var isPathLiteral: Bool
        {
        false
        }
        
    public var isLet: Bool
        {
        false
        }
        
    public var isSelect: Bool
        {
        false
        }
        
    public var isWhen: Bool
        {
        false
        }
        
    public var isOtherwise: Bool
        {
        false
        }
        
    public var isIf: Bool
        {
        false
        }
        
    public var isClass: Bool
        {
        false
        }
        
    public var isSlot: Bool
        {
        false
        }
        
    public var isElse: Bool
        {
        false
        }
        
    public var isFor: Bool
        {
        false
        }
        
    public var isLoop: Bool
        {
        false
        }
        
    public var isAs: Bool
        {
        false
        }
        
    public var isStringLiteral: Bool
        {
        false
        }
        
    public var isSymbolLiteral: Bool
        {
        false
        }
        
    public var isRightArrow: Bool
        {
        false
        }
        
    public var isLeftBracket: Bool
        {
        false
        }
        
    public var isRightBracket: Bool
        {
        false
        }
        
    public var isLeftBrace: Bool
        {
        false
        }
        
    public var isRightBrace: Bool
        {
        false
        }
        
    public var isKeyword: Bool
        {
        false
        }
        
    public var isDirective: Bool
        {
        false
        }
        
    public var isIdentifier: Bool
        {
        false
        }
        
    public var isName: Bool
        {
        false
        }
        
    public var isEnd: Bool
        {
        false
        }
        
    public var isComment: Bool
        {
        false
        }
        
    public var isWhitespace: Bool
        {
        false
        }
        
    public var isGluon: Bool
        {
        false
        }
        
    public var isComma: Bool
        {
        false
        }
        
    public var identifier: String
        {
        fatalError()
        }
        
    public var pathLiteral: String
        {
        fatalError()
        }
        
    public var dateLiteral: Argon.Date
        {
        fatalError()
        }
        
    public var timeLiteral: Argon.Time
        {
        fatalError()
        }
        
    public var dateTimeLiteral: Argon.DateTime
        {
        fatalError()
        }
        
        
    public var symbolLiteral: StaticSymbol
        {
        fatalError()
        }
        
    public var nameLiteral: Name
        {
        fatalError()
        }
        
    public var stringLiteral: StaticString
        {
        fatalError()
        }
        
    public var floatLiteral: Argon.Float
        {
        fatalError()
        }
        
    public var integerLiteral: Argon.Integer
        {
        fatalError()
        }
        
    public var booleanLiteral: Argon.Boolean
        {
        fatalError()
        }
        
    public var keyword: Token.Keyword
        {
        fatalError()
        }
        
    internal var kind: TokenKind = .none
    internal var location: Location
    internal var issues = CompilerIssues()
    
    init(location: Location)
        {
        self.location = location
        }
        
    public func appendIssue(_ message: String)  -> CompilerIssue
        {
        let issue = CompilerIssue(location: self.location,message: message)
        self.issues.append(issue)
        return(issue)
        }
        
    public func appendIssue(at: Location,message: String,isWarning: Bool = false)
        {
        self.issues.append(CompilerIssue(location: at, message: message,isWarning: isWarning))
        }
        
    public func appendIssue(_ issue: CompilerIssue)
        {
        self.issues.append(issue)
        }
        
    public func appendIssues(_ issues: CompilerIssues)
        {
        self.issues.append(contentsOf: issues)
        }
    }
    
public class CommentToken: Token
    {
    public override var isWhitespace: Bool
        {
        true
        }
        
    public override var displayString: String
        {
        "CommentToken()"
        }
        
    private let comment: String
    
    init(comment: String,location: Location)
        {
        self.comment = comment
        super.init(location: location)
        self.kind = .comment
        let lineStop = self.location.lineStart + self.comment.count
        let tokenStop = self.location.tokenStart + self.comment.count
        self.location = Location(line: self.location.line, lineStart: self.location.lineStart, lineStop: lineStop, tokenStart: self.location.tokenStart, tokenStop: tokenStop)
        }
    }
    
public class KeywordToken: Token
    {
    public override var displayString: String
        {
        "KeywordToken(\(self._keyword))"
        }
        
    public override var isModuleLevelKeyword: Bool
        {
        self._keyword == .CLASS || self._keyword == .SLOT || self._keyword == .TYPE || self._keyword == .METHOD || self._keyword == .PRIMITIVE || self._keyword == .ENUMERATION || self._keyword == .FUNCTION || self._keyword == .MODULE
        }
        
    public override var isIs: Bool
        {
        self._keyword == .IS
        }
        
    public override var isWhile: Bool
        {
        self._keyword == .WHILE
        }
        
    public override var isFork: Bool
        {
        self._keyword == .FORK
        }
        
    public override var isType: Bool
        {
        self._keyword == .TYPE
        }
        
    public override var isReturn: Bool
        {
        self._keyword == .RETURN
        }
        
    public override var isSignal: Bool
        {
        self._keyword == .SIGNAL
        }
        
    public override var isEnumeration: Bool
        {
        self._keyword == .ENUMERATION
        }
        
    public override var isHandle: Bool
        {
        self._keyword == .HANDLE
        }
        
    public override var isElseIf: Bool
        {
        self._keyword == .ELSEIF
        }
        
    public override var isElse: Bool
        {
        self._keyword == .ELSE
        }
        
    public override var isWith: Bool
        {
        self._keyword == .WITH
        }
        
    public override var isMake: Bool
        {
        self._keyword == .MAKE
        }
        
    public override var isClass: Bool
        {
        self._keyword == .CLASS
        }
        
    public override var isSlot: Bool
        {
        self._keyword == .SLOT
        }
        
    public override var isModule: Bool
        {
        self._keyword == .MODULE
        }
        
    public override var isMethod: Bool
        {
        self._keyword == .METHOD
        }
        
    public override var isInitializer: Bool
        {
        self._keyword == .INITIALIZER
        }
        
    public override var isMandatory: Bool
        {
        self._keyword == .MANDATORY
        }
        
    public override var isPrimitive: Bool
        {
        self._keyword == .PRIMITIVE
        }
        
    public override var isAs: Bool
        {
        self._keyword == .AS
        }
        
    public override var isLet: Bool
        {
        self._keyword == .LET
        }
        
    public override var isSelect: Bool
        {
        self._keyword == .SELECT
        }
        
    public override var isWhen: Bool
        {
        self._keyword == .WHEN
        }
        
    public override var isOtherwise: Bool
        {
        self._keyword == .OTHERWISE
        }
        
    public override var isIf: Bool
        {
        self._keyword == .IF
        }

    public override var isFor: Bool
        {
        self._keyword == .FOR
        }
        
    public override var isLoop: Bool
        {
        self._keyword == .LOOP
        }
        
    public override var keyword: Token.Keyword
        {
        self._keyword
        }
        
    public override var isKeyword: Bool
        {
        true
        }
        
    private let _keyword: Token.Keyword
    
    init(keyword: Token.Keyword,location: Location)
        {
        self._keyword = keyword
        super.init(location: location)
        self.kind = .keyword
        let lineStop = self.location.lineStart + self._keyword.rawValue.count
        let tokenStop = self.location.tokenStart + self._keyword.rawValue.count
        self.location = Location(line: self.location.line, lineStart: self.location.lineStart, lineStop: lineStop, tokenStart: self.location.tokenStart, tokenStop: tokenStop)
        }
    }
    
public class OperatorToken: Token
    {
    public override var displayString: String
        {
        "OperatorToken(\(self.operatorString))"
        }
        
    public override var isAssignmentOperator: Bool
        {
        self.isAssign || self.isAddEquals || self.isSubEquals || self.isMulEquals || self.isDivEquals || self.isModEquals || self.isBitAndEquals || self.isBitOrEquals || self.isBitNotEquals || self.isBitXorEquals
        }
        
    public override var isFullRange: Bool
        {
        self.operatorString == "..."
        }
        
    public override var isSemicolon: Bool
        {
        self.operatorString == ";"
        }
        
    public override var isAddEquals: Bool
        {
        self.operatorString == "+="
        }
        
    public override var isSubEquals: Bool
        {
        self.operatorString == "-="
        }
        
    public override var isMulEquals: Bool
        {
        self.operatorString == "*="
        }
        
    public override var isDivEquals: Bool
        {
        self.operatorString == "/="
        }
        
    public override var isModEquals: Bool
        {
        self.operatorString == "%="
        }
        
    public override var isBitAndEquals: Bool
        {
        self.operatorString == "&="
        }
        
    public override var isBitOrEquals: Bool
        {
        self.operatorString == "|="
        }
        
    public override var isBitXorEquals: Bool
        {
        self.operatorString == "^="
        }
        
    public override var isBitNotEquals: Bool
        {
        self.operatorString == "~="
        }
        
    public override var isNot: Bool
        {
        self.operatorString == "!"
        }
        
    public override var isPower: Bool
        {
        self.operatorString == "**"
        }
        
    public override var isBitAnd: Bool
        {
        self.operatorString == "&"
        }
        
    public override var isBitOr: Bool
        {
        self.operatorString == "|"
        }
        
    public override var isBitXor: Bool
        {
        self.operatorString == "^"
        }
        
    public override var isBitNot: Bool
        {
        self.operatorString == "~"
        }
        
    public override var isAdd: Bool
        {
        self.operatorString == "+"
        }
        
    public override var isSub: Bool
        {
        self.operatorString == "-"
        }
        
    public override var isMul: Bool
        {
        self.operatorString == "*"
        }
        
    public override var isDiv: Bool
        {
        self.operatorString == "/"
        }
        
    public override var isModulus: Bool
        {
        self.operatorString == "%"
        }
        
    public override var isAnd: Bool
        {
        self.operatorString == "&&"
        }
        
    public override var isOr: Bool
        {
        self.operatorString == "||"
        }
        
    public override var isLeftBrocketEquals: Bool
        {
        self.operatorString == "<="
        }
        
    public override var isEquals: Bool
        {
        self.operatorString == "=="
        }
        
    public override var isRightBrocketEquals: Bool
        {
        self.operatorString == ">="
        }
        
    public override var isNotEquals: Bool
        {
        self.operatorString == "!="
        }
        
    public override var isTester: Bool
        {
        self.operatorString == "??"
        }
        
    public override var isCast: Bool
        {
        self.operatorString == "!!"
        }
        
    public override var isTernary: Bool
        {
        self.operatorString == "?"
        }
        
    public override var isColon: Bool
        {
        self.operatorString == ":"
        }
        
    public override var isAssign: Bool
        {
        self.operatorString == "="
        }
        
    public override var isRightArrow: Bool
        {
        self.operatorString == "->"
        }
        
    public override var isGluon: Bool
        {
        self.operatorString == "::"
        }
        
    public override var isComma: Bool
        {
        self.operatorString == ","
        }
        
    public override var isRightPar: Bool
        {
        self.operatorString == ")"
        }
        
    public override var isLeftPar: Bool
        {
        self.operatorString == "("
        }
        
    public override var isLeftBracket: Bool
        {
        self.operatorString == "["
        }
        
    public override var isRightBracket: Bool
        {
        self.operatorString == "]"
        }
        
    public override var isLeftBrocket: Bool
        {
        self.operatorString == "<"
        }
        
    public override var isRightBrocket: Bool
        {
        self.operatorString == ">"
        }
        
    public override var isLeftBrace: Bool
        {
        self.operatorString == "{"
        }
        
    public override var isRightBrace: Bool
        {
        self.operatorString == "}"
        }
        
    public override var operatorString: String
        {
        self._operatorString
        }
        
    public override var isPlusPlus: Bool
        {
        self._operatorString == "++"
        }
        
    public override var isMinusMinus: Bool
        {
        self._operatorString == "--"
        }
        
    public let _operatorString: String
    
    init(string: String,location: Location)
        {
        self._operatorString = string
        super.init(location: location)
        self.kind = .operator
        let lineStop = self.location.lineStart + self._operatorString.count
        let tokenStop = self.location.tokenStart + self._operatorString.count
        self.location = Location(line: self.location.line, lineStart: self.location.lineStart, lineStop: lineStop, tokenStart: self.location.tokenStart, tokenStop: tokenStop)
        }
    }
    
public class IdentifierToken: Token
    {
    public override var displayString: String
        {
        "IdentifierToken(\(self._identifier))"
        }
        
    public override var isSystemClassName: Bool
        {
        Self.systemClassNames.contains(self.identifier)
        }
        
    public override var isIdentifier: Bool
        {
        true
        }
        
    public override var identifier: String
        {
        self._identifier
        }
        
    public let _identifier: String
    
    init(identifier: String,location: Location)
        {
        self._identifier = identifier
        super.init(location: location)
        self.kind = .identifier
        let lineStop = self.location.lineStart + self._identifier.count
        let tokenStop = self.location.tokenStart + self._identifier.count
        self.location = Location(line: self.location.line, lineStart: self.location.lineStart, lineStop: lineStop, tokenStart: self.location.tokenStart, tokenStop: tokenStop)
        }
    }
    
public class LiteralToken: Token
    {
    public override var displayString: String
        {
        "LiteralToken(\(self.literal))"
        }
        
    public override var isDateLiteral: Bool
        {
        if case Literal.date(_) = self.literal
            {
            return(true)
            }
        return(false)
        }
        
    public override var isTimeLiteral: Bool
        {
        if case Literal.time(_) = self.literal
            {
            return(true)
            }
        return(false)
        }
        
    public override var isDateTimeLiteral: Bool
        {
        if case Literal.dateTime(_) = self.literal
            {
            return(true)
            }
        return(false)
        }
        
    public override var isIntegerLiteral: Bool
        {
        if case Literal.integer(_) = self.literal
            {
            return(true)
            }
        return(false)
        }
        
    public override var isStringLiteral: Bool
        {
        if case Literal.string(_) = self.literal
            {
            return(true)
            }
        return(false)
        }
        
    public override var isFloatLiteral: Bool
        {
        if case Literal.float(_) = self.literal
            {
            return(true)
            }
        return(false)
        }
        
    public override var isSymbolLiteral: Bool
        {
        if case Literal.symbol(_) = self.literal
            {
            return(true)
            }
        return(false)
        }
        
    public override var dateLiteral: Argon.Date
        {
        if case let Literal.date(aSymbol) = self.literal
            {
            return(aSymbol)
            }
        fatalError()
        }
        
    public override var timeLiteral: Argon.Time
        {
        if case let Literal.time(aSymbol) = self.literal
            {
            return(aSymbol)
            }
        fatalError()
        }
        
    public override var dateTimeLiteral: Argon.DateTime
        {
        if case let Literal.dateTime(aSymbol) = self.literal
            {
            return(aSymbol)
            }
        fatalError()
        }
        
    public override var symbolLiteral: StaticSymbol
        {
        if case let Literal.symbol(aSymbol) = self.literal
            {
            return(aSymbol)
            }
        fatalError()
        }
        
    public override var stringLiteral: StaticString
        {
        if case let Literal.string(aSymbol) = self.literal
            {
            return(aSymbol)
            }
        fatalError()
        }
        
    public override var floatLiteral: Argon.Float
        {
        if case let Literal.float(aSymbol) = self.literal
            {
            return(aSymbol)
            }
        fatalError()
        }
        
    public override var booleanLiteral: Argon.Boolean
        {
        if case let Literal.boolean(aSymbol) = self.literal
            {
            return(aSymbol)
            }
        fatalError()
        }
        
    public override var integerLiteral: Argon.Integer
        {
        if case let Literal.integer(aSymbol) = self.literal
            {
            return(aSymbol)
            }
        fatalError()
        }
        
    private let literal: Literal
    
    init(float: Argon.Float,location: Location)
        {
        self.literal = .float(float)
        super.init(location: location)
        self.kind = .float
        }
        
    init(integer: Argon.Integer,location: Location)
        {
        self.literal = .integer(integer)
        super.init(location: location)
        self.kind = .integer
        }
        
    init(string: StaticString,location: Location)
        {
        self.literal = .string(string)
        super.init(location: location)
        self.kind = .string
        }
        
    init(character: Argon.Character,location: Location)
        {
        self.literal = .character(character)
        super.init(location: location)
        self.kind = .character
        }
        
    init(byte: Argon.Byte,location: Location)
        {
        self.literal = .byte(byte)
        super.init(location: location)
        self.kind = .byte
        }
        
    init(date: Argon.Date,location: Location)
        {
        self.literal = .date(date)
        super.init(location: location)
        self.kind = .date
        }
        
    init(time: Argon.Time,location: Location)
        {
        self.literal = .time(time)
        super.init(location: location)
        self.kind = .time
        }
        
    init(dateTime: Argon.DateTime,location: Location)
        {
        self.literal = .dateTime(dateTime)
        super.init(location: location)
        self.kind = .dateTime
        }
        
    init(symbol: StaticSymbol,location: Location)
        {
        self.literal = .symbol(symbol)
        super.init(location: location)
        self.kind = .symbol
        }
    }
    
public class PathToken: Token
    {
    private let path: String
    
    init(path: String,location: Location)
        {
        self.path = path
        super.init(location: location)
        }
    }
    
public class EndToken: Token
    {
    public override var isEnd: Bool
        {
        true
        }
    }
