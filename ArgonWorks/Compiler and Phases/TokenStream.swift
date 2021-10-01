//
//  TokenStream.swift
//  Neon
//
//  Created by Vincent Coetzee on 30/11/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import Combine

public class TokenStream:Equatable
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
        
    private var reportingContext:ReportingContext = NullReportingContext.shared
    private var source:String = ""
    private var line:Int = 0
    private var lineAtTokenStart = 0
    private var currentChar:Unicode.Scalar = " "
    private var offset:String.Index = "".startIndex
    private var currentString:String  = ""
    private var keywords:[String] = []
    private var startIndex:Int = 0
//    private var keyValueCharacters = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_:"))
//    private var typeParameterCharacters = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._"))
    private var identifierCharacters = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-?"))
    private var nameCharacters = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "\\_-?"))
    private var identifierStartCharacters = NSCharacterSet.letters.union(CharacterSet(charactersIn: "_$"))
    private var pathCharacters = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_/."))
    private let alphanumerics = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
//    private let symbolString = NSCharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
    private let letters = NSCharacterSet.letters.union(CharacterSet(charactersIn: "_"))
    private let quoteCharacters = CharacterSet(charactersIn: "\"")
    private let digits = NSCharacterSet.decimalDigits
    private let whitespace = NSCharacterSet.whitespaces
    private let newline = NSCharacterSet.newlines
    private let symbols = CharacterSet(charactersIn: "=<>-+*/%!&|^\\/~:.,$()[]:.{},@;")
    private let hexDigits = CharacterSet(charactersIn: "avbdefABCDEF0123456789_")
    private let binaryDigits = CharacterSet(charactersIn: "01_")
    private let operatorSymbols = CharacterSet(charactersIn: "=<>-+*/%!&|^~@")
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
//    public var lexicalState:LexicalState = .scanning
//    private var errorSubject: PassthroughSubject<CompilerIssue, Never>?
    
    public var braceDepth:Int
        {
        return(self._braceDepth)
        }
        
    public var lineNumber:Int
        {
        get
            {
            return(self.line)
            }
        set
            {
            self.line = newValue
            }
        }
        
    private var atEnd:Bool
        {
        return(offset == source.endIndex)
        }
    
    private var atEndOfLine:Bool
        {
        return(newline.contains(self.currentChar))
        }
    
    init(source:String,context:ReportingContext)
        {
        self.reportingContext = context
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
        
    public func allTokens(withComments:Bool,context:ReportingContext) -> [Token]
        {
        self.reportingContext = context
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
        return(tokens.flatMap{($0.isComment || $0.isInvisible) ? nil : $0})
        }
        
    public func line(from:Int,to:Int) -> String
        {
        return(self.source.substring(with: from..<to))
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
        guard !self.atEnd else
            {
            self.currentChar = Unicode.Scalar(0)
            return(" ")
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
        offset = source.index(before: offset)
        if source.unicodeScalars[offset] == "\n"
            {
            self.line -= 1
            }
        self.currentChar = source.unicodeScalars[offset]
        if source.unicodeScalars[offset] == "\n"
            {
            self.line += 1
            }
        characterOffset -= 2
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
                let endIndex = source.distance(from: source.startIndex, to: offset)
                return(Token.comment(source.substring(with: startIndex..<endIndex),self.sourceLocation()))
                }
            return(self.nextToken())
            }
        else if self.currentChar == "*" && !atEnd
            {
            self.scanToEndOfComment()
            if parseComments
                {
                let endIndex = source.distance(from: source.startIndex, to: offset)
                return(Token.comment(source.substring(with: startIndex..<endIndex),self.sourceLocation()))
                }
            return(self.nextToken())
            }
        else
            {
             if self.currentChar == "="
                {
                self.nextChar()
                return(Token("/=",self.sourceLocation()))
                }
            return(Token("/",self.sourceLocation()))
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
        if self.keywords.contains(string)
            {
            return(.keyword(Token.Keyword(rawValue: string)!,self.sourceLocation()))
            }
        return(.identifier(string,self.sourceLocation()))
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
        return(.path(string,self.sourceLocation()))
        }
        
    public func nextToken() -> Token
        {
        self.tokenLine = line
        if !tokenStack.isEmpty
            {
            return(tokenStack.removeFirst())
            }
        tokenStart = characterOffset
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
        if self.currentChar == "<" && self.peekChar(at:0) == "/" && CharacterSet.letters.contains(self.peekChar(at:1))
            {
            self.nextChar()
            return(.symbol(Token.Symbol(rawValue:"<")!,self.sourceLocation()))
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
                return(.note(string,self.sourceLocation()))
                }
            }
        //
        // Is it a directive
        //
        else if self.currentChar == "%"
            {
            self.nextChar()
            if letters.contains(self.currentChar)
                {
                self.currentString = ""
                while letters.contains(self.currentChar)
                    {
                    self.currentString += String(self.currentChar)
                    self.nextChar()
                    }
                return(.directive(self.currentString,self.sourceLocation()))
                }
            else
                {
                return(.symbol(Token.Symbol(rawValue:"%")!,self.sourceLocation()))
                }
            }
        //
        // Is it a number
        //
        else if digits.contains(self.currentChar)
            {
            return(self.scanNumber())
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
            return(Token.end(self.sourceLocation()))
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
            return(.hashString(string,self.sourceLocation()))
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
        self.reportingContext.dispatchError(at: self.sourceLocation(), message: "Invalid character '\(self.currentChar)'")
        self.nextChar()
        return(self.nextToken())
        }
        
    private func scanCharacterLiteral() -> Token
        {
        self.nextChar()
        let characterValue = UInt16(self.currentChar.utf16[0])
        self.nextChar()
        if self.currentChar != "'"
            {
            self.reportingContext.dispatchError(at:self.sourceLocation(),message:"' expected after character constant")
            }
        self.nextChar()
        return(.character(characterValue,self.sourceLocation()))
        }
        
    private func scanMagnitudeLiteral() -> Token
        {
        self.nextChar()
        var day:String = ""
        while self.digits.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine && day.count <= 2
            {
            day += String(self.currentChar)
            self.nextChar()
            }
        if self.currentChar == "/"
            {
            self.nextChar()
            var month = ""
            while self.digits.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine && month.count <= 2
                {
                month += String(self.currentChar)
                self.nextChar()
                }
            if self.currentChar != "/"
                {
                self.reportingContext.dispatchError(at:self.sourceLocation(),message:"'/' expected in magnitude literal.")
                }
            self.nextChar()
            var year = ""
            while self.digits.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine && year.count <= 2
                {
                year += String(self.currentChar)
                self.nextChar()
                }
            return(.date(Argon.Date(day:day,month:month,year:year),self.sourceLocation()))
            }
        if self.currentChar == ":"
            {
            self.nextChar()
            let hour = day
            var minute = "0"
            var second = "0"
            var millisecond = ""
            while self.digits.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine && minute.count <= 2
                {
                minute += String(self.currentChar)
                self.nextChar()
                }
            if self.currentChar == ":"
                {
                while self.digits.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine && second.count <= 2
                    {
                    second += String(self.currentChar)
                    self.nextChar()
                    }
                if self.currentChar == ":"
                    {
                    while self.digits.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine && millisecond.count <= 2
                        {
                        millisecond += String(self.currentChar)
                        self.nextChar()
                        }
                    }
                return(.time(Argon.Time(hour:hour,minute:minute,second:second,millisecond:millisecond),self.sourceLocation()))
                }
            self.reportingContext.dispatchError(at:self.sourceLocation(),message:"'/' expected in magnitude literal.")
            }
        self.reportingContext.dispatchError(at:self.sourceLocation(),message:"Invalid magnitude literal.")
        return(.date(Argon.Date(day:0,month:0,year:0),self.sourceLocation()))
        }
        
    private func scanString() -> Token
        {
        self.startIndex = self.characterOffset
        var string = "\""
        self.nextChar()
        while !self.quoteCharacters.contains(self.currentChar) && !self.atEnd && !self.atEndOfLine
            {
            string += String(self.currentChar)
            self.nextChar()
            }
        self.nextChar()
        return(Token.string(string,self.sourceLocation()))
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
        return(.integer(number,self.sourceLocation()))
        }
    
    private func scanNumber() -> Token
        {
        self.startIndex = self.characterOffset
        var number:Int = 0
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
        while (digits.contains(self.currentChar) || self.currentChar == "_") && !atEnd
            {
            if self.currentChar == "_"
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
        if self.currentChar == "." && self.peekChar(at:0) == "." && self.peekChar(at:1) == "."
            {
            return(.integer(Argon.Integer(number),self.sourceLocation()))
            }
        else if self.currentChar == "." && self.peekChar(at:0) == "."
            {
            return(.integer(Argon.Integer(number),self.sourceLocation()))
            }
        else if self.currentChar == "."
            {
            self.nextChar()
            var factor = Double(0.0)
            var divisor = 10
            while (digits.contains(self.currentChar) || self.currentChar == "_") && !atEnd
                {
                if self.currentChar == "_"
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
            return(.float(Double(Double(number)+factor),self.sourceLocation()))
            }
        else
            {
            return(.integer(Argon.Integer(number),self.sourceLocation()))
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
        return(.integer(Argon.Integer(hexValue),self.sourceLocation()))
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
        return(.integer(Argon.Integer(binaryValue),self.sourceLocation()))
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
            return(.identifier(String(self.currentString),self.sourceLocation()))
            }
        if self.keywords.contains(self.currentString)
            {
            return(.keyword(Token.Keyword(rawValue:self.currentString)!,self.sourceLocation()))
            }
        return(.identifier(String(self.currentString),self.sourceLocation()))
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
            return(.keyword(Token.Keyword(rawValue:self.currentString)!,self.sourceLocation()))
            }
        return(.name(Name(self.currentString),self.sourceLocation()))
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
                    return(.symbol(.fullRange,self.sourceLocation()))
                    }
                return(.symbol(.halfRange,self.sourceLocation()))
                }
            return(.symbol(.stop,self.sourceLocation()))
            }
        if self.currentChar == "("
            {
            self.nextChar()
            return(.symbol(.leftParenthesis,self.sourceLocation()))
            }
        else if self.currentChar == ")"
            {
            self.nextChar()
            return(.symbol(.rightParenthesis,self.sourceLocation()))
            }
        else if self.currentChar == "}"
            {
            self.nextChar()
            if self.currentChar == "$"
                {
                self.nextChar()
                return(.symbol(.macroEnd,self.sourceLocation()))
                }
            self._braceDepth -= 1
            return(.symbol(.rightBrace,self.sourceLocation()))
            }
        else if self.currentChar == "{"
            {
            self.nextChar()
            self._braceDepth += 1
            return(.symbol(.leftBrace,self.sourceLocation()))
            }
        else if self.currentChar == "]"
            {
            self.nextChar()
            return(.symbol(.rightBracket,self.sourceLocation()))
            }
        else if self.currentChar == "["
            {
            self.nextChar()
            return(.symbol(.leftBracket,self.sourceLocation()))
            }
        else if self.currentChar == "/"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(.symbol(.divEquals,self.sourceLocation()))
                }
            else
                {
                return(self.scanOperator(withPrefix:"/"))
                }
            }
        else if self.currentChar == ","
            {
            self.nextChar()
            return(.symbol(.comma,self.sourceLocation()))
            }
        else if self.currentChar == ">"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(.symbol(.rightBrocketEquals,self.sourceLocation()))
                }
            else
                {
                return(self.scanOperator(withPrefix:">"))
                }
            }
        else if self.currentChar == ";"
            {
            self.nextChar()
            return(.symbol(.semicolon,self.sourceLocation()))
            }
        else if self.currentChar == ":"
            {
            self.nextChar()
            if self.currentChar == ":"
                {
                self.nextChar()
                return(.symbol(.gluon,self.sourceLocation()))
                }
            return(.symbol(.colon,self.sourceLocation()))
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
                return(.symbol(.and,self.sourceLocation()))
                }
            else if self.currentChar == "="
                {
                self.nextChar()
                return(.symbol(.bitAndEquals,self.sourceLocation()))
                }
            else
                {
                return(.symbol(.bitAnd,self.sourceLocation()))
                }
            }
        else if self.currentChar == "|"
            {
            self.nextChar()
            if self.currentChar == "|"
                {
                self.nextChar()
                return(.symbol(.or,self.sourceLocation()))
                }
            else if self.currentChar == "="
                {
                self.nextChar()
                return(.symbol(.bitOrEquals,self.sourceLocation()))
                }
            else
                {
                return(.symbol(.bitOr,self.sourceLocation()))
                }
            }
        else if self.currentChar == "+"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(.symbol(.addEquals,self.sourceLocation()))
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
                return(.symbol(.subEquals,self.sourceLocation()))
                }
            else if self.currentChar == ">"
                {
                self.nextChar()
                return(.symbol(.rightArrow,self.sourceLocation()))
                }
            else
                {
                return(.symbol(.sub,self.sourceLocation()))
                }
            }
        else if self.currentChar == "*"
            {
            self.nextChar()
            if self.currentChar == "="
                {
                self.nextChar()
                return(.symbol(.mulEquals,self.sourceLocation()))
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
                return(.symbol(.bitNotEquals,self.sourceLocation()))
                }
            else
                {
                return(self.scanOperator(withPrefix:"~"))
                }
            }
        else if !self.operatorSymbols.contains(self.currentChar)
            {
            self.reportingContext.dispatchError(at:self.sourceLocation(),message:"Invalid symbol character '\(self.currentChar)'.")
            self.nextChar()
            }
        while self.operatorSymbols.contains(self.currentChar) && !(self.currentChar == "<" && self.peekChar(at:0) == "/" && CharacterSet.letters.contains(self.currentChar))
            {
            operatorString += String(self.currentChar)
            self.nextChar()
            }
        if let symbolType = Token.Symbol(rawValue: operatorString)
            {
            return(.symbol(symbolType,self.sourceLocation()))
            }
        return(.operator(operatorString,self.sourceLocation()))
        }
    
    internal func sourceLocation() -> Location
        {
        self.tokenStop = self.characterOffset
        self.tokenStart = self.startIndex
        return(Location(line:tokenLine,lineStart: lineStart,lineStop: self.lineStart + self.lineLength,tokenStart:max(tokenStart - 1,0),tokenStop:tokenStop-1))
        }
    
    private func scanOperator(withPrefix startString:String) -> Token
        {
        var operatorString = startString
        if startString == "<" && self.currentChar == "/" && self.alphanumerics.contains(self.peekChar(at:0))
            {
            return(.symbol(Token.Symbol(rawValue: operatorString)!,self.sourceLocation()))
            }
        while self.operatorSymbols.contains(self.currentChar) && !(self.currentChar == "<" && self.peekChar(at:0) == "/" && self.alphanumerics.contains(self.peekChar(at:1)))
            {
            operatorString += String(self.currentChar)
            self.nextChar()
            }
        if let symbolType = Token.Symbol(rawValue: operatorString)
            {
            return(.symbol(symbolType,self.sourceLocation()))
            }
         return(.operator(operatorString,self.sourceLocation()))
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
