//
//  TokenStream.swift
//  Neon
//
//  Created by Vincent Coetzee on 30/11/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import Combine

public class TokenStream:Equatable, TokenSource
    {
    public static func == (lhs: TokenStream, rhs: TokenStream) -> Bool
        {
        return(lhs.source == rhs.source)
        }
    
    private struct StreamPosition
        {
        public let current:Unicode.Scalar
        public let line:Int
        public let offset:Int
        public let index:String.Index
        public let length:Int
        public let start:Int
        
        public init(current:Unicode.Scalar,line:Int,offset:Int,index:String.Index,length:Int,start:Int)
            {
            self.current = current
            self.line = line
            self.offset = offset
            self.index = index
            self.length = length
            self.start = start
            }
        }
        
    private var source:String = ""
    private var line:Int = 0
    private var lineAtTokenStart = 0
    private var currentChar:Unicode.Scalar = " "
    private var offset:String.Index = "".startIndex
    private var currentString:String  = ""
    private var keywords:[String] = []
    private var startIndex:Int = 0
    private var identifierCharacters = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-?"))
    private var nameCharacters = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "\\_-?"))
    private var identifierStartCharacters = NSCharacterSet.letters.union(CharacterSet(charactersIn: "_$"))
    private var pathCharacters = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_/."))
    private let alphanumerics = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
    private let letters = NSCharacterSet.letters.union(CharacterSet(charactersIn: "_"))
//    private let quoteCharacters = CharacterSet(charactersIn: "\"")
    private let digits = NSCharacterSet.decimalDigits
    private let whitespace = NSCharacterSet.whitespaces
    private let newline = NSCharacterSet.newlines
    private let symbols = CharacterSet(charactersIn: "=<>-+*/%!&|^\\/~:.,$()[]:.{},;?")
    private let hexDigits = CharacterSet(charactersIn: "avbdefABCDEF0123456789_")
    private let binaryDigits = CharacterSet(charactersIn: "01_")
    private let operatorSymbols = CharacterSet(charactersIn: "=>-+*/%!&|^~@?")
    private let hashStringCharacters = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
    private var tokenStart:Int = 0
    private var tokenStop:Int = 0
    private var lineStart:Int = 0
    private var lineStop:Int = 0
    private var characterOffset = 0
    public var parseComments:Bool = false
    public var parseInvisibles:Bool = false
    private var tokenStack:[Token] = []
    private var lineLength:Int = 0
    private var tokenLine:Int = 0
    private var positionStack = Stack<StreamPosition>()
    private var _braceDepth = 0
    public var lineNumber:LineNumber = EmptyLineNumber()
    private var withComments = false
    private var issues = CompilerIssues()
    public var braceDepth:Int
        {
        return(self._braceDepth)
        }
        
//    public var lineNumber:Int
//        {
//        get
//            {
//            return(self.line)
//            }
//        set
//            {
//            self.line = newValue
//            }
//        }
        
    private var atEnd:Bool
        {
        return(offset >= source.endIndex)
        }
    
    private var atEndOfLine:Bool
        {
        return(newline.contains(self.currentChar))
        }
    
    init(source:String,withComments: Bool = true)
        {
        self.withComments = withComments
        self.source = source
        self.initState()
        self.initKeywords()
        }
    
    public func reset(source string:String)
        {
        source = string
        self.initState()
        self.initKeywords()
        }
        
    public func allTokens(withComments:Bool) -> [Token]
        {
        self.parseComments = withComments
        self.parseInvisibles = withComments
        var tokens:[Token] = []
        var token:Token
        repeat
            {
            token = self.nextToken()
            tokens.append(token)
            }
        while !token.isEnd
        if withComments
            {
            return(tokens)
            }
        return(tokens.flatMap{$0.isComment ? nil : $0})
        }
        
    public func line(from:Int,to:Int) -> String
        {
        return(self.source.substring(with: from..<to))
        }
        
    private func appendIssue(at: Location,message: String)
        {
        self.issues.append(CompilerIssue(location: at, message: message))
        }
        
    private func initState()
        {
        tokenStart = 0
        tokenStop = 0
        lineStart = 0
        lineLength = 0
        startIndex = 0
        characterOffset = 0
        line = 1
        self.currentChar = Unicode.Scalar(" ")
        offset = source.startIndex
        }
    
    @discardableResult
    @inline(__always)
    private func nextChar() -> Unicode.Scalar
        {
        guard self.offset < self.source.endIndex else
            {
            self.currentChar = Unicode.Scalar(0)
            return(Unicode.Scalar(0))
            }
        self.currentChar = source.unicodeScalars[offset]
        if self.currentChar == "\n"
            {
            self.line += 1
            lineStart = self.characterOffset
            lineLength = 0
            }
        self.offset = self.source.index(after:offset)
        self.characterOffset += 1
        self.lineLength += 1
        return(self.currentChar)
        }
    
    @inline(__always)
    public func pushPosition()
        {
        let position = StreamPosition(current: self.currentChar, line: self.line, offset: self.characterOffset, index: self.offset, length: self.lineLength, start: self.lineStart)
        self.positionStack.push(position)
        }
        
    @inline(__always)
    public func popPosition()
        {
        let position = self.positionStack.pop()
        self.currentChar = position.current
        self.line = position.line
        self.characterOffset = position.offset
        self.offset = position.index
        self.lineLength = position.length
        self.lineStart = position.start
        }
        
    @discardableResult
    @inline(__always)
    private func peekChar(at count:Int) -> Unicode.Scalar
        {
        var index = offset
        for _ in 0..<count
            {
            index = source.index(after: index)
            }
        if index < source.endIndex
            {
            return(source.unicodeScalars[index])
            }
        return(UnicodeScalar(" "))
        }
        
    public func rewindChar()
        {
        offset = source.index(before: offset)
        if source.unicodeScalars[offset] == "\n"
            {
            self.line -= 1
            }
        self.currentChar = source.unicodeScalars[offset]
        self.characterOffset -= 1
        }
    
    @discardableResult
    private func eatSpace() -> String
        {
        var space = ""
        while (whitespace.contains(self.currentChar) || newline.contains(self.currentChar)) && !atEnd
            {
            if whitespace.contains(self.currentChar)
                {
                space += self.eatWhitespace()
                }
            if newline.contains(self.currentChar)
                {
                space += self.eatNewline()
                }
            }
        return(space)
        }
    
    @inline(__always)
    private func scanToEndOfLine()
        {
        while !newline.contains(self.currentChar) && !atEnd
            {
            self.nextChar()
            }
        }
    
    @inline(__always)
    private func scanToEndOfComment()
        {
        while self.currentChar != "*" && !atEnd
            {
            self.nextChar()
            }
        self.nextChar()
        if self.currentChar == "/"
            {
            self.nextChar()
            return
            }
        else
            {
            self.scanToEndOfComment()
            }
        }
    
    public func pushBack(_ token:Token)
        {
        tokenStack.append(token)
        }
    
    @discardableResult
    public func scanTextUntilCommaOrLeftParenthesis() -> String
        {
        let scalar1:UnicodeScalar = ","
        let scalar2:UnicodeScalar = ")"
        var text:String = ""
        while self.currentChar != scalar1 && self.currentChar != scalar2 && !self.atEnd
            {
            text.append(String(self.currentChar))
            self.nextChar()
            }
        if !atEnd
            {
            self.nextChar()
            }
        return(text)
        }
        
    @discardableResult
    public func scanTextUntilMacroEnd() -> String
        {
        let scalar1:UnicodeScalar = "}"
        let scalar2:UnicodeScalar = "$"
        var text:String = ""
        while self.currentChar != scalar1 && self.peekChar(at: 0) != scalar2 && !self.atEnd
            {
            text.append(String(self.currentChar))
            self.nextChar()
            }
        if !atEnd
            {
            self.nextChar()
            self.nextChar()
            }
        return(text)
        }
        
    private func scanInvisible()
        {
        self.eatSpace()
        }
        
    private func scanComment() -> Token
        {
        self.nextChar()
        if self.currentChar == "/" && !atEnd
            {
            self.scanToEndOfLine()
            if self.parseComments
                {
//                let anIndex = self.source.index(self.source.startIndex,offsetBy: self.startIndex)
                let endIndex = source.distance(from: source.startIndex, to: offset)
                return(CommentToken(comment: source.substring(with: (startIndex-1)..<endIndex),location: self.sourceLocation()))
                }
            return(self.nextToken())
            }
        else if self.currentChar == "*" && !atEnd
            {
            self.scanToEndOfComment()
            if parseComments
                {
                let endIndex = source.distance(from: source.startIndex, to: offset)
                return(CommentToken(comment: source.substring(with: startIndex..<endIndex),location: self.sourceLocation()))
                }
            return(self.nextToken())
            }
        else
            {
             if self.currentChar == "="
                {
                self.nextChar()
                 return(OperatorToken(string: "/=",location: self.sourceLocation()))
                }
            return(OperatorToken(string: "/",location: self.sourceLocation()))
            }
        }
        
    private func scanIdentifier(_ start:String) -> Token
        {
        self.startIndex = self.characterOffset
        var string = start
        self.nextChar()
        while self.identifierCharacters.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine && !(self.currentChar == "-" && self.peekChar(at:0) == ">")
            {
            string += self.currentChar
            self.nextChar()
            }
        if self.identifierCharacters.contains(self.currentChar) && !(self.currentChar == "-" && self.peekChar(at:0) == ">")
            {
            string += self.currentChar
            self.nextChar()
            }
        if self.keywords.contains(string)
            {
            return(KeywordToken(keyword: Token.Keyword(rawValue: string)!,location: self.sourceLocation()))
            }
        return(IdentifierToken(identifier: string,location: self.sourceLocation()))
        }
        ///
        /// If we have found a "/" or a "." that means this was actually a path and
        /// not an identifier, so change to a path and return a path not
        /// an identifier.
        ///
    private func scanPath(with: String) -> Token
        {
        var string = with
        self.nextChar()
        while self.pathCharacters.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine
            {
            string += self.currentChar
            self.nextChar()
            }
        return(PathToken(path: string,location: self.sourceLocation()))
        }
        
    public func peekToken(count: Int) -> Token
        {
        for index in 0..<count
            {
            let token = self.nextToken()
            self.tokenStack.append(token)
            if index == count - 1
                {
                return(token)
                }
            }
        return(self.tokenStack[count-1])
        }
        
    public func nextToken() -> Token
        {
        let token = self._nextToken()
        if !self.issues.isEmpty
            {
            token.appendIssues(self.issues)
            self.issues = []
            }
        return(token)
        }
        
    private func _nextToken() -> Token
        {
        if self.currentChar == Unicode.Scalar(0)
            {
            return(EndToken(location: self.sourceLocation()))
            }
        let token = self.scanToken()
        if !self.withComments && token.isWhitespace
            {
            return(self.nextToken())
            }
        return(token)
        }
        
    private func scanToken() -> Token
        {

        self.tokenLine = line
        if !self.tokenStack.isEmpty
            {
            return(self.tokenStack.removeFirst())
            }
        self.scanInvisible()
//            {
//            return(invisible)
//            }
        ///
        ///
        /// Check to see if this is that odd case of a "</" occurring, handle
        /// it if it is
        ///
        ///
        self.startIndex = self.characterOffset
        self.tokenStart = self.characterOffset
        if self.currentChar == "<" && self.peekChar(at:0) == "/" && CharacterSet.letters.contains(self.peekChar(at:1))
            {
            self.nextChar()
            return(OperatorToken(string:"<",location: self.sourceLocation()))
            }
        else if self.currentChar == "<"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:"<=",location: self.sourceLocation()))
                }
            return(OperatorToken(string:"<",location: self.sourceLocation()))
            }
        else if self.currentChar == "$" && self.peekChar(at: 0) == "{"
            {
            self.nextChar()
            self.nextChar()
            let text = self.scanTextUntilMacroEnd()
            self.tokenStack.append(LiteralToken(string: Argon.addStatic(StaticString(string: text)),location: self.sourceLocation()))
//            self.tokenStack.append(.symbol(.macroStop,location: self.sourceLocation()))
            return(OperatorToken(string:"${",location: self.sourceLocation()))
            }
        ///
        ///
        /// Is this the start of a name which is of the form \zzzzzz\aaaaaa\gggg
        ///
        ///
        else if self.currentChar == "\\"
            {
            return(self.scanName(with: String(self.currentChar)))
            }
        else if self.identifierStartCharacters.contains(self.currentChar)
            {
            return(self.scanIdentifier(String(self.currentChar)))
            }
        //
        // Is it a comment of some sort
        //
        else if self.currentChar == "/" && (self.peekChar(at:0) == "/" || self.peekChar(at:0) == "*") && !self.atEnd && !self.atEndOfLine
            {
            self.startIndex = self.characterOffset
            return(self.scanComment())
            }
        ///
        /// Is this the start of a path
        ///
        else if self.currentChar == "/" && self.letters.contains(self.peekChar(at:0))
            {
            return(self.scanPath(with: String(self.currentChar)))
            }
        ///
        ///
        /// Is it a text delimiter
        ///
        ///
        else if self.currentChar == "!" && self.peekChar(at:0) == "*"
            {
            self.nextChar()
            self.nextChar()
            var string = ""
            while !(self.currentChar == "*" && self.peekChar(at:0) == "!") && !self.atEnd
                {
                string += String(self.currentChar)
                self.nextChar()
                }
            if self.currentChar == "*" && self.peekChar(at:0) == "!"
                {
                self.nextChar()
                self.nextChar()
                string = string.replacingOccurrences(of: "\n", with: " ")
                string = string.replacingOccurrences(of: "\t", with: " ")
//                return(.note(string,location: self.sourceLocation()))
                fatalError()
                }
            }
        //
        // Is it a directive
        //
//        else if self.currentChar == "%"
//            {
//            self.nextChar()
//            if letters.contains(self.currentChar)
//                {
//                self.currentString = ""
//                while letters.contains(self.currentChar)
//                    {
//                    self.currentString += String(self.currentChar)
//                    self.nextChar()
//                    }
//                return(.directive(self.currentString,location: self.sourceLocation()))
//                }
//            else
//                {
//                self.rewindChar()
//                return(self.scanSymbol())
//                }
//            }
        //
        // Is it a number
        //
        else if self.currentChar == "-" && self.peekChar(at: 0) == ">"
            {
            self.nextChar()
            self.nextChar()
            return(OperatorToken(string:"->",location: self.sourceLocation()))
            }
        else if digits.contains(self.currentChar)
            {
            let number = self.scanNumber()
            return(number)
            }
        //
        // Is it a string
        //
        else if self.currentChar == Unicode.Scalar("\"")
            {
            return(self.scanString())
            }
        //
        // Is it a symbol
        //
        else if symbols.contains(self.currentChar)
            {
            return(self.scanSymbol())
            }
        //
        // Is it the end of the file
        //
        else if atEnd
            {
            return(EndToken(location: self.sourceLocation()))
            }
        //
        // Is it a hash string called a Symbol in the language
        //
        else if self.currentChar == "#"
            {
            self.startIndex = self.characterOffset
            var string:String = "#"
            self.nextChar()
            while hashStringCharacters.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine
                {
                string += String(self.currentChar)
                self.nextChar()
                }
            return(LiteralToken(symbol: Argon.addStatic(StaticSymbol(string: string)),location: self.sourceLocation()))
            }
        //
        // Is it a date, time or date time literal
        //
        else if self.currentChar == "@"
            {
            return(self.scanMagnitudeLiteral())
            }
        //
        // Is it a character literal
        //
        else if self.currentChar == "'"
            {
            return(self.scanCharacterLiteral())
            }
        else if self.currentChar == "⇦"
            {
            self.nextChar()
            return(OperatorToken(string: "=", location: self.sourceLocation()))
            }
        else if self.currentChar != Unicode.Scalar(0)
            {
            self.appendIssue(at: self.sourceLocation(), message: "Invalid character '\(self.currentChar)'")
            self.nextChar()
            }
        return(self.nextToken())
        }
        
    private func scanCharacterLiteral() -> Token
        {
        self.nextChar()
        let characterValue = UInt16(self.currentChar.utf16[0])
        self.nextChar()
        if self.currentChar != "'"
            {
            self.appendIssue(at:self.sourceLocation(),message:"' expected after character constant")
            }
        self.nextChar()
        return(LiteralToken(character: characterValue,location: self.sourceLocation()))
        }
        
    private func scanNumericElement(maximum: Int) -> Int
        {
        var number = ""
        while self.digits.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine
            {
            number += String(self.currentChar)
            self.nextChar()
            }
        if let value = Int(number)
            {
            return(value > maximum ? maximum : value)
            }
        return(-1)
        }
        
    private func scanMagnitudeLiteral() -> Token
        {
        self.nextChar()
        var day = 0
        var month = 0
        var year = 0
        var hasDate = false
        var hasTime = false
        var hour = 0
        var minute = 0
        var second = 0
        var millisecond = 0
        
        if self.currentChar != "("
            {
            self.appendIssue(at:self.sourceLocation(),message:"'(' expected after '@'.")
            }
        self.nextChar()
        let first = self.scanNumericElement(maximum: 60)
        if self.currentChar == "/"
            {
            day = first
            self.nextChar()
            month = self.scanNumericElement(maximum: 12)
            if self.currentChar != "/"
                {
                self.appendIssue(at:self.sourceLocation(),message:"'/' expected in date literal.")
                }
            self.nextChar()
            year = self.scanNumericElement(maximum: 65535)
            hasDate = true
            }
        if self.currentChar == ")"
            {
            self.nextChar()
            }
        else
            {
            hasTime = true
            hour = self.scanNumericElement(maximum: 24)
            if self.currentChar == ":"
                {
                hasTime = true
                self.nextChar()
                minute = self.scanNumericElement(maximum: 60)
                if self.currentChar == ":"
                    {
                    second = self.scanNumericElement(maximum: 60)
                    if self.currentChar == ":"
                        {
                        millisecond = self.scanNumericElement(maximum: 1000)
                        }
                    }
                }
            else
                {
                self.appendIssue(at:self.sourceLocation(),message:"':' expected in time literal.")
                }
            if self.currentChar != ")"
                {
                self.appendIssue(at:self.sourceLocation(),message:"')' was expected after magnitude date/time literal.")
                }
            self.nextChar()
            }
        if hasDate && hasTime
            {
            return(LiteralToken(dateTime: Argon.DateTime(day: day, month: month, year: year, hour: hour, minute: minute, second: second, millisecond: millisecond),location: self.sourceLocation()))
            }
        else if hasTime
            {
            return(LiteralToken(time: Argon.Time(hour: hour, minute: minute, second: second, millisecond: millisecond),location: self.sourceLocation()))
            }
        return(LiteralToken(date: Argon.Date(day:day,month:month,year:year),location: self.sourceLocation()))
        }
        
    private func scanString() -> Token
        {
        self.startIndex = self.characterOffset
        var string = ""
        self.nextChar()
        while self.currentChar != "\"" && !self.atEnd && !self.atEndOfLine
            {
            string += String(self.currentChar)
            self.nextChar()
            }
        self.nextChar()
        return(LiteralToken(string: Argon.addStatic(StaticString(string: string)),location: self.sourceLocation()))
        }
    
    @inline(__always)
    private func eatNewline() -> String
        {
        var space = ""
        while newline.contains(self.currentChar) && !atEnd
            {
            space += self.currentChar
            self.nextChar()
            }
        return(space)
        }
    
    @inline(__always)
    private func eatWhitespace() -> String
        {
        var space:String = ""
        while whitespace.contains(self.currentChar) && !self.atEnd
            {
            space += self.currentChar
            self.nextChar()
            }
        return(space)
        }
    
    public func markPosition() -> String.Index
        {
        return(self.offset)
        }
        
    public func setPosition(_ position:String.Index)
        {
        self.offset = position
        self.nextChar()
        }
    
    public func scanPositiveInteger() -> Token
        {
        self.startIndex = self.characterOffset
        var number:Argon.Integer = 0
        while digits.contains(self.currentChar) && !atEnd
            {
            number *= 10
            number += Argon.Integer(String(self.currentChar))!
            self.nextChar()
            }
        return(LiteralToken(integer: number,location: self.sourceLocation()))
        }
    
    private func scanNumber() -> Token
        {
        print("scanNumber")
        self.startIndex = self.characterOffset
        var sign = 1
        var number:Int = 0
        if self.currentChar == "-"
            {
            sign = -1
            self.nextChar()
            }
        if self.currentChar == "0"
            {
            self.nextChar()
            if self.currentChar == "x"
                {
                return(self.scanHexNumber())
                }
            else if self.currentChar == "b"
                {
                return(self.scanBinaryNumber())
                }
            else
                {
                self.rewindChar()
                }
            }
        repeat
            {
            while self.currentChar == "_" && !self.atEnd
                {
                self.nextChar()
                }
            if digits.contains(self.currentChar)
                {
                number *= 10
                number += Int(String(self.currentChar))!
                self.nextChar()
                }
            }
        while (digits.contains(self.currentChar) || self.currentChar == "_") && !self.atEnd
        if self.currentChar == "." && self.peekChar(at:0) == "." && self.peekChar(at:1) == "."
            {
            return(LiteralToken(integer: Argon.Integer(number * sign),location: self.sourceLocation()))
            }
        else if self.currentChar == "." && self.peekChar(at:0) == "."
            {
            return(LiteralToken(integer: Argon.Integer(number * sign),location: self.sourceLocation()))
            }
        else if self.currentChar == "."
            {
            self.nextChar()
            var factor = Double(0.0)
            var divisor = 10
            while (digits.contains(self.currentChar) || self.currentChar == "_") && !self.atEnd
                {
                while self.currentChar == "_" && !self.atEnd
                    {
                    self.nextChar()
                    }
                if digits.contains(self.currentChar)
                    {
                    factor += Double(String(self.currentChar))! / Double(divisor)
                    divisor *= 10
                    self.nextChar()
                    }
                }
            return(LiteralToken(float: Double(sign) * Double(Double(number)+factor),location: self.sourceLocation()))
            }
        else
            {
            return(LiteralToken(integer: Argon.Integer(number * sign),location: self.sourceLocation()))
            }
        }
    
    private func scanHexNumber() -> Token
        {
        self.startIndex = self.characterOffset
        self.nextChar()
        var hexValue = 0
        while hexDigits.contains(self.currentChar)
            {
            hexValue *= 16
            let uppercased = String(self.currentChar).uppercased()
            switch(uppercased)
                {
                case "A":
                    hexValue += 10
                case "B":
                    hexValue += 11
                case "C":
                    hexValue += 12
                case "D":
                    hexValue += 13
                case "E":
                    hexValue += 14
                case "F":
                    hexValue += 15
                default:
                    hexValue += Int(String(self.currentChar))!
                }
            nextChar()
            }
        return(LiteralToken(integer: Argon.Integer(hexValue),location: self.sourceLocation()))
        }
    
    private func scanBinaryNumber() -> Token
        {
        self.startIndex = self.characterOffset
        nextChar()
        var binaryValue:UInt64 = 0
        while binaryDigits.contains(self.currentChar)
            {
            binaryValue *= 2
            if self.currentChar == "1"
                {
                binaryValue += 1
                }
            nextChar()
            }
        return(LiteralToken(integer: Argon.Integer(binaryValue),location: self.sourceLocation()))
        }
        
    private func scanIdentifier(with:String) -> Token
        {
        self.currentString = with
        repeat
            {
            self.currentString.append(String(self.currentChar))
            self.nextChar()
            }
        while self.identifierCharacters.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine
        if currentString == "?"
            {
            self.nextChar()
            return(IdentifierToken(identifier: String(self.currentString),location: self.sourceLocation()))
            }
        if self.keywords.contains(self.currentString)
            {
            return(KeywordToken(keyword: Token.Keyword(rawValue:self.currentString)!,location: self.sourceLocation()))
            }
        return(IdentifierToken(identifier: String(self.currentString),location: self.sourceLocation()))
        }
        
    private func scanName(with:String) -> Token
        {
        self.currentString = ""
        repeat
            {
            self.currentString.append(String(self.currentChar))
            self.nextChar()
            }
        while self.nameCharacters.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine
        if self.keywords.contains(self.currentString)
            {
            return(KeywordToken(keyword: Token.Keyword(rawValue:self.currentString)!,location: self.sourceLocation()))
            }
        fatalError()
//        return(.name(Name(self.currentString),location: self.sourceLocation()))
        }
        
    private func scanSymbol() -> Token
        {
        self.startIndex = self.characterOffset
        var operatorString:String = ""
        if self.currentChar == "."
            {
            self.nextChar()
            if self.currentChar == "."
                {
                self.nextChar()
                if self.currentChar == "."
                    {
                    self.nextChar()
                    return(OperatorToken(string:"...",location: self.sourceLocation()))
                    }
                return(OperatorToken(string:"..",location: self.sourceLocation()))
                }
            return(OperatorToken(string:".",location: self.sourceLocation()))
            }
        if self.currentChar == "("
            {
            self.nextChar()
            return(OperatorToken(string:"(",location: self.sourceLocation()))
            }
        else if self.currentChar == ")"
            {
            self.nextChar()
            return(OperatorToken(string:")",location: self.sourceLocation()))
            }
        else if self.currentChar == "}"
            {
            self.nextChar()
            if self.currentChar == "$"
                {
                self.nextChar()
                return(OperatorToken(string:"}$",location: self.sourceLocation()))
                }
            self._braceDepth -= 1
            return(OperatorToken(string:"}",location: self.sourceLocation()))
            }
        else if self.currentChar == "{"
            {
            self.nextChar()
            self._braceDepth += 1
            return(OperatorToken(string:"{",location: self.sourceLocation()))
            }
        else if self.currentChar == "]"
            {
            self.nextChar()
            return(OperatorToken(string:"]",location: self.sourceLocation()))
            }
        else if self.currentChar == "["
            {
            self.nextChar()
            return(OperatorToken(string:"[",location: self.sourceLocation()))
            }
        else if self.currentChar == "/"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:"/=",location: self.sourceLocation()))
                }
            else
                {
                return(self.scanOperator(withPrefix:"/"))
                }
            }
        else if self.currentChar == ","
            {
            self.nextChar()
            return(OperatorToken(string:",",location: self.sourceLocation()))
            }
        else if self.currentChar == ">"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:">=",location: self.sourceLocation()))
                }
            else
                {
                return(self.scanOperator(withPrefix:">"))
                }
            }
        else if self.currentChar == ";"
            {
            self.nextChar()
            return(OperatorToken(string:";",location: self.sourceLocation()))
            }
        else if self.currentChar == ":"
            {
            self.nextChar()
            if self.currentChar == ":"
                {
                self.nextChar()
                return(OperatorToken(string:"::",location: self.sourceLocation()))
                }
            return(OperatorToken(string:":",location: self.sourceLocation()))
            }
        else if self.currentChar == "="
            {
            self.nextChar()
            return(self.scanOperator(withPrefix: "="))
            }
        else if self.currentChar == "&"
            {
            self.nextChar()
            if self.currentChar == "&"
                {
                self.nextChar()
                return(OperatorToken(string:"&&",location: self.sourceLocation()))
                }
            else if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:"&=",location: self.sourceLocation()))
                }
            else
                {
                return(OperatorToken(string:"&",location: self.sourceLocation()))
                }
            }
        else if self.currentChar == "|"
            {
            self.nextChar()
            if self.currentChar == "|"
                {
                self.nextChar()
                return(OperatorToken(string:"||",location: self.sourceLocation()))
                }
            else if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:"|=",location: self.sourceLocation()))
                }
            else
                {
                return(OperatorToken(string:"|",location: self.sourceLocation()))
                }
            }
        else if self.currentChar == "+"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:"+=",location: self.sourceLocation()))
                }
            else
                {
                return(self.scanOperator(withPrefix:"+"))
                }
            }
        else if self.currentChar == "-"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:"-=",location: self.sourceLocation()))
                }
            else if self.currentChar == ">"
                {
                self.nextChar()
                return(OperatorToken(string:"->",location: self.sourceLocation()))
                }
            else
                {
                return(OperatorToken(string:"-",location: self.sourceLocation()))
                }
            }
        else if self.currentChar == "*"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:"*=",location: self.sourceLocation()))
                }
            else
                {
                return(self.scanOperator(withPrefix:"*"))
                }            }
        else if self.currentChar == "~"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:"~=",location: self.sourceLocation()))
                }
            else
                {
                return(self.scanOperator(withPrefix:"~"))
                }
            }
        else if self.currentChar == "?"
            {
            self.nextChar()
            if self.currentChar == "?"
                {
                self.nextChar()
                return(OperatorToken(string:"??",location: self.sourceLocation()))
                }
            return(OperatorToken(string:"?",location: self.sourceLocation()))
            }
        else if self.currentChar == "!"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(OperatorToken(string:"!=",location: self.sourceLocation()))
                }
            else if self.currentChar == "!"
                {
                self.nextChar()
                return(OperatorToken(string:"!!",location: self.sourceLocation()))
                }
            return(OperatorToken(string:"!",location: self.sourceLocation()))
            }
        else if !self.operatorSymbols.contains(self.currentChar)
            {
            self.appendIssue(at:self.sourceLocation(),message:"Invalid symbol character '\(self.currentChar)'.")
            self.nextChar()
            }
        while self.operatorSymbols.contains(self.currentChar) && !(self.currentChar == "<" && self.peekChar(at:0) == "/" && CharacterSet.letters.contains(self.currentChar))
            {
            operatorString += String(self.currentChar)
            self.nextChar()
            }
        return(OperatorToken(string:operatorString,location: self.sourceLocation()))
        }
    
    internal func sourceLocation() -> Location
        {
        self.tokenStop = self.characterOffset
        self.tokenStart = self.startIndex
        return(Location(line: self.line,lineStart: lineStart,lineStop: self.lineStart + self.lineLength,tokenStart:max(tokenStart - 1,0),tokenStop:tokenStop-1))
        }
    
    private func scanOperator(withPrefix startString:String) -> Token
        {
        var operatorString = startString
        if startString == "<" && self.currentChar == "/" && self.alphanumerics.contains(self.peekChar(at:0))
            {
            return(OperatorToken(string:operatorString,location: self.sourceLocation()))
            }
        if self.currentChar == "<"
            {
            return(OperatorToken(string:operatorString,location: self.sourceLocation()))
            }
        while self.operatorSymbols.contains(self.currentChar) && !(self.currentChar == "<" && self.peekChar(at:0) == "/" && self.alphanumerics.contains(self.peekChar(at:1)))
            {
            operatorString += String(self.currentChar)
            self.nextChar()
            }
         return(OperatorToken(string:operatorString,location: self.sourceLocation()))
        }
        
    private func initKeywords()
        {
        self.keywords = []
        for keyword in Token.Keyword.allCases
            {
            self.keywords.append(keyword.rawValue)
            }
        }
    }

extension String
    {
    func index(from: Int) -> Index
        {
        return self.index(startIndex, offsetBy: from)
        }

    func substring(from: Int) -> String
        {
        let fromIndex = self.index(from: from)
        return(String(self[fromIndex...]))
        }

    func substring(to: Int) -> String
        {
        let toIndex = index(from: to)
        return(String(self[..<toIndex]))
        }

    func substring(with r: Range<Int>) -> String
        {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return(String(self[startIndex..<endIndex]))
        }
    }

extension String
    {
    public static func +=(lhs:inout String,rhs:Unicode.Scalar)
        {
        lhs += String(rhs)
        }
    }
