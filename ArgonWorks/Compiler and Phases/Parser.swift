//
//  Parser.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/9/21.
//

import Foundation

public enum ParseError: Error
    {
    case endOfSourceFound
    }
    
public enum Context: Equatable
    {
    case block(Block)
    case node(Node)

    public func addSymbol(_ symbol:Symbol)
        {
        switch(self)
            {
            case .node(let node):
                Transaction.recordAddSymbol(symbol, to: .node(node))
                node.addSymbol(symbol)
            case .block(let block):
                Transaction.recordAddSymbol(symbol, to: .block(block))
                block.addSymbol(symbol)
            }
        }
        
    public func setSymbol(_ symbol:Symbol,atName: Name)
        {
        switch(self)
            {
            case .node(let node):
                node.setSymbol(symbol,atName: atName)
            case .block(let block):
                block.setSymbol(symbol,atName: atName)
            }
        }
        
    public func lookup(name: Name) -> Symbol?
        {
        switch(self)
            {
            case .node(let node):
                return(node.lookup(name: name))
            case .block(let block):
                return(block.lookup(name: name))
            }
        }
        
    public func lookup(label: Label) -> Symbol?
        {
        switch(self)
            {
            case .node(let node):
                return(node.lookup(label: label))
            case .block(let block):
                return(block.lookup(label: label))
            }
        }
    }
        
public class Parser: CompilerPass
    {
    private var tokens = Array<Token>()
    private var tokenIndex = 0
    internal private(set) var token:Token = .none
    private var lastToken:Token = .none
    public let compiler:Compiler
    private var namingContext: NamingContext
    private var contextStack = Stack<Context>()
    private var currentContext:Context = .node(Node(label: ""))
    private var node:ParseNode?
    internal var visualToken:TokenRenderer
    private var source: String?
    public var wasCancelled = false
    public var currentTag = 0
    
    public static func parseChunk(_ source:String,in compiler:Compiler) -> ParseNode?
        {
        Parser(compiler: compiler).parseChunk(source)
        }
        
    init(compiler:Compiler)
        {
        self.currentTag = compiler.currentTag
        self.compiler = compiler
        self.namingContext = compiler.namingContext
        self.visualToken = TokenRenderer(systemClassNames: compiler.systemClassNames)
        self.reportingContext = compiler.reportingContext
        }
        
    public var reportingContext:ReportingContext = NullReportingContext.shared
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    @discardableResult
    public func nextToken() throws -> Token
        {
        if self.token.isEnd
            {
            throw(ParseError.endOfSourceFound)
            }
        self.lastToken = self.token
        self.token = self.tokens[self.tokenIndex]
        self.visualToken.setToken(self.token)
        self.tokenIndex += 1
        while self.token.isComment || self.token.isInvisible
            {
            print(self.token)
            self.token = self.tokens[self.tokenIndex]
            self.visualToken.setToken(self.token)
            self.tokenIndex += 1
            }
        print(token)
        return(self.token)
        }
        
    private func peekToken1() throws -> Token
        {
        return(self.peekToken(0))
        }
        
    private func peekToken2() throws -> Token
        {
        return(self.peekToken(1))
        }
        
    private func peekToken(_ index:Int) -> Token
        {
        let newToken = self.tokens[self.tokenIndex + index]
        if newToken.isComment || newToken.isInvisible
            {
            return(self.peekToken(index+1))
            }
        return(newToken)
        }
        
    private func pushContext(_ aNode:Node)
        {
        let context = Context.node(aNode)
        if self.contextStack.contains(context)
            {
            fatalError("Stack already contains this context")
            }
        aNode.setParent(self.currentContext)
        self.contextStack.push(self.currentContext)
        self.currentContext = context
        }
        
   private func pushContext(_ block:Block)
        {
        let context = Context.block(block)
        if self.contextStack.contains(context)
            {
            fatalError("Stack already contains this context")
            }
        block.setParent(self.currentContext)
        self.contextStack.push(self.currentContext)
        self.currentContext = context
        }
        
    private func popContext()
        {
        self.currentContext = self.contextStack.pop()
        }
        
    private func initParser(source:String) throws
        {
        self.source = source
        self.currentContext = .node(self.compiler.topModule)
        let stream = TokenStream(source: source, context: self.reportingContext)
        self.tokens = stream.allTokens(withComments: true, context: self.reportingContext)
        self.visualToken.processTokens(self.tokens)
        try self.nextToken()
        }
        
    @discardableResult
    public func parseChunk(_ source:String) -> ParseNode?
        {
        do
            {
            try self.initParser(source: source)
            let result = try self.parsePrivacyModifier
                {
                (scope:PrivacyScope?) -> ParseNode? in
                if self.token.isEnd
                    {
                    return(nil)
                    }
                var directive: Token.Directive?
                if self.token.isDirective
                    {
                    directive = token.directive
                    try self.nextToken()
                    }
                if !self.token.isKeyword
                    {
                    self.reportingContext.dispatchError(at: self.token.location, message: "KEYWORD expected.")
                    return(nil)
                    }
                if self.token.isKeyword
                    {
                    switch(self.token.keyword)
                        {
                        case .MAIN:
                                return(try self.parseMain())
                        case .MODULE:
                                return(try self.parseModule())
                        case .CLASS:
                                return(try self.parseClass())
                        case .CONSTANT:
                                return(try self.parseConstant())
                        case .METHOD:
                                return(try self.parseMethod(directive: directive))
                        case .FUNCTION:
                                return(try self.parseFunction())
                        case .TYPE:
                                return(try self.parseTypeAlias())
                        case .ENUMERATION:
                                return(try self.parseEnumeration())
                        default:
                            break
                        }
                    }
                return(self.node)
                }
            return(result)
            }
        catch
            {
            return(nil)
            }
        }
        
    private func chompKeyword() throws
        {
        if self.token.isKeyword
            {
            try self.nextToken()
            }
        }
        
    private func parseLabel() throws -> String
        {
        if !self.token.isIdentifier
            {
            self.reportingContext.dispatchWarning(at: self.token.location, message: "An identifier was expected here but \(self.token) was found.")
            return(Argon.nextName("LABEL"))
            }
        let string = self.token.identifier
        try self.nextToken()
        return(string)
        }
        
    private func parseName() throws -> Name
        {
        if self.token.isName
            {
            let name = self.token.nameLiteral
            try self.nextToken()
            return(name)
            }
        else if self.token.isIdentifier
            {
            let name = Name(self.token.identifier)
            try self.nextToken()
            return(name)
            }
        self.reportingContext.dispatchError(at: self.token.location, message: "A name was expected but a \(self.token) was found.")
        return(Name("error"))
        }
        
    @discardableResult
    private func parsePrivacyModifier(_ closure: (PrivacyScope?) throws -> ParseNode?) throws -> ParseNode?
        {
        let modifier = self.token.isKeyword ? PrivacyScope(rawValue: self.token.keyword.rawValue) : nil
        if self.token.isPrivacyModifier
            {
            try self.chompKeyword()
            }
        var value = try closure(modifier)
        value?.privacyScope = modifier
        return(value)
        }
        
    internal func parseBraces<T>(_ closure: () throws -> T) throws -> T
        {
        if !self.token.isLeftBrace
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "'{' expected but a '\(self.token)' was found.")
            }
        else
            {
            try self.nextToken()
            }
        let result = try closure()
        if !self.token.isRightBrace
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "'}' expected but a '\(self.token)' was found.")
            }
        else
            {
            try self.nextToken()
            }
        return(result)
        }
        
    @discardableResult
    private func parseMain() throws -> ParseNode
        {
        try self.nextToken()
        if self.token.isModule
            {
            return(try self.parseMainModule())
            }
        else
            {
            return(try self.parseMainMethod())
            }
        }
    
    private func parseMainMethod() throws -> Method
        {
        let method = try self.parseMethod()
        method.isMain = true
        return(method)
        }
        
    private func parseMainModule() throws -> Module
        {
        try self.nextToken()
        let label = try self.parseLabel()
        let module = MainModule(label: label)
        module.tag = self.currentTag
        self.currentContext.addSymbol(module)
        try self.parseModule(into: module)
        self.node = module
        return(module)
        }
    
    private func parsePath() throws -> Token
        {
        if self.token.isPathLiteral
            {
            self.visualToken.kind = .path
            try self.nextToken()
            return(self.lastToken)
            }
        self.dispatchError("Path expected for a library module but \(self.token) was found.")
        return(.path("",Location.zero))
        }
        
    private func parseModule() throws -> Module
        {
        let location = self.token.location
        try self.nextToken()
        self.visualToken.kind = .module
        let name = try self.parseName()
        var module = self.currentContext.lookup(name: name) as? Module
        var isNew = false
        if self.token.isLeftPar
            {
            try self.parseParentheses
                {
                let path = try self.parsePath().pathLiteral
                if module != nil
                    {
                    self.cancelCompletion()
                    self.dispatchError("Module \(name.displayString) already exists and can not be merged with a LibraryModule.")
                    }
                else
                    {
                    module = LibraryModule(label: name.last,path: path)
                    isNew = true
                    }
                }
            }
        else if module.isNil
            {
            module = Module(label: name.last)
            module?.tag = self.currentTag
            isNew = true
            }
        if isNew
            {
            self.currentContext.addSymbol(module!)
            module?.addDeclaration(location)
            }
        else
            {
            module?.addReference(location)
            }
        try self.parseModule(into: module!)
        self.node = module
        return(module!)
        }
        
    private func parseDirective(_ closure: ([Token.Directive]) throws -> Void) throws
        {
        var directives: [Token.Directive] = []
        
        while self.token.isDirective
            {
            directives.append(self.token.directive)
            try self.nextToken()
            }
        try closure(directives)
        }
        
    private func parseModule(into module:Module) throws
        {
        self.pushContext(module)
        try self.parseBraces
            {
            () throws -> Void in
            while !self.token.isRightBrace
                {
                if self.token.isEnd
                    {
                    return
                    }
                var directive: Token.Directive?
                if self.token.isDirective
                    {
                    directive = self.token.directive
                    try self.nextToken()
                    }
                if !self.token.isKeyword
                    {
                    self.reportingContext.dispatchError(at: self.token.location, message: "Keyword expected but \(self.token) found.")
                    try self.nextToken()
                    }
                else
                    {
                    try self.parsePrivacyModifier
                        {
                        modifier in
                        if !self.token.isKeyword
                            {
                            return(nil)
                            }
                        switch(self.token.keyword)
                            {
                            case .IMPORT:
                                    return(try self.parseImport())
                            case .FUNCTION:
                                    return(try self.parseFunction())
                            case .MAIN:
                                    return(try self.parseMain())
                            case .MODULE:
                                    return(try self.parseModule())
                            case .CLASS:
                                    return(try self.parseClass())
                            case .TYPE:
                                    return(try self.parseTypeAlias())
                            case .METHOD:
                                    return(try self.parseMethod(directive: directive))
                            case .CONSTANT:
                                    return(try self.parseConstant())
                            case .SCOPED:
                                    let scoped = try self.parseScopedSlot()
                                    scoped.tag = self.currentTag
                                    module.addSymbol(scoped)
                                    return(scoped)
                            case .ENUMERATION:
                                    return(try self.parseEnumeration())
                            case .SLOT:
                                    let slot = try self.parseSlot()
                                    slot.tag = self.currentTag
                                    module.addSymbol(slot)
                                    return(slot)
                            case .INTERCEPTOR:
                                    let interceptor = try self.parseInterceptor()
                                    interceptor.tag = self.currentTag
                                    module.addSymbol(interceptor)
                                    return(interceptor)
                            default:
                                self.reportingContext.dispatchError(at: self.token.location, message: "A declaration for a module element was expected but \(self.token) was found.")
                                try self.nextToken()
                                return(Symbol(label:""))
                            }
                        }
                    }
                }
            }
        self.popContext()
        }
        
    private func parseImport() throws -> Import
        {
        try self.nextToken()
        let label = try self.parseLabel()
        var path:String?
        if self.token.isLeftPar
            {
            try self.parseParentheses
                {
                if !self.token.isPathLiteral
                    {
                    self.dispatchError("Path expected in parentheses after import name.")
                    }
                path = self.token.pathLiteral
                }
            }
        return(Import(label: label,path: path))
        }
        
    private func parseInterceptor() throws -> Interceptor
        {
        return(Interceptor(label:"Interceptor",parameters: []))
        }
        
    private func parseScopedSlot() throws -> ScopedSlot
        {
        return(ScopedSlot(label:"Slot",type: TopModule.shared.argonModule.integer.type))
        }
        
    private func parseHashString() throws -> String
        {
        if self.token.isHashStringLiteral
            {
            let string = self.token.hashStringLiteral
            try self.nextToken()
            return(string)
            }
        self.reportingContext.dispatchError(at: self.token.location, message: "A symbol was expected but \(self.token) was found.")
        try self.nextToken()
        return("#HashString")
        }
        
    private func parseEnumeration() throws -> Enumeration
        {
        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let label = try self.parseLabel()
        let enumeration = Enumeration(label: label)
        enumeration.rawType = TopModule.shared.argonModule.integer.type
        enumeration.tag = self.currentTag
        self.currentContext.addSymbol(enumeration)
        self.pushContext(enumeration)
        enumeration.addDeclaration(location)
        if self.token.isGluon
            {
            try self.nextToken()
            let type = try self.parseType()
            enumeration.rawType = type
            }
        try self.parseBraces
            {
            () throws -> Void in
            while !self.token.isRightBrace
                {
                try self.parseCase(into: enumeration)
                }
            }
        self.popContext()
        self.stopClip(into:enumeration)
        let methodInstance = MethodInstance(label: "_\(label)",parameters: [Parameter(label: "symbol", type: TopModule.shared.argonModule.symbol.type, isVisible: false, isVariadic: false)],returnType: .enumeration(enumeration))
        methodInstance.addDeclaration(location)
        let method = Method(label: "_\(label)")
        method.addDeclaration(location)
        method.tag = self.currentTag
        self.currentContext.addSymbol(method)
        method.addInstance(methodInstance)
        return(enumeration)
        }
        
    private func parseLiteral() throws -> LiteralExpression
        {
        var literal:LiteralExpression
        if self.token.isIntegerLiteral
            {
            literal = LiteralExpression(.integer(self.token.integerLiteral))
            }
        else if self.token.isStringLiteral
            {
            literal = LiteralExpression(.string(self.token.stringLiteral))
            }
        else if self.token.isHashStringLiteral
            {
            literal = LiteralExpression(.symbol(self.token.hashStringLiteral))
            }
        else
            {
            literal = LiteralExpression(.integer(0))
            self.reportingContext.dispatchError(at: self.token.location, message: "Integer, String or Symbol literal expected for rawValue of ENUMERATIONCASE")
            }
        try self.nextToken()
        return(literal)
        }
        
    private func parseCase(into enumeration: Enumeration) throws
        {
        self.startClip()
        let location = self.token.location
        let name = try self.parseHashString()
        var types = Array<Type>()
        if self.token.isLeftPar
            {
            try self.parseParentheses
                {
                repeat
                    {
                    try self.parseComma()
                    let type = try self.parseType()
                    if self.token.isEnd
                        {
                        return
                        }
                    types.append(type)
                    }
                while self.token.isComma
                }
            }
        let aCase = EnumerationCase(symbol: name,types: types,enumeration: enumeration)
        aCase.tag = self.currentTag
        enumeration.addSymbol(aCase)
        aCase.addDeclaration(location)
        if self.token.isAssign
            {
            try self.nextToken()
            aCase.rawValue = try self.parseLiteral()
            }
        self.stopClip(into: aCase)
        }
        
    private func parseSlot() throws -> Slot
        {
        try self.nextToken()
        self.visualToken.kind = .classSlot
        let location = self.token.location
        let label = try self.parseLabel()
        var type: Type?
        if self.token.isGluon
            {
            try self.nextToken()
            type = try self.parseType()
            }
        var initialValue:Expression?
        if self.token.isAssign
            {
            try self.nextToken()
            initialValue = try self.parseExpression()
            }
        var readBlock:VirtualReadBlock?
        var writeBlock:VirtualWriteBlock?
        if self.token.isLeftBrace
            {
            try self.parseBraces
                {
                if self.token.isRead
                    {
                    try self.nextToken()
                    readBlock = VirtualReadBlock()
                    try self.parseBraces
                        {
                        try self.parseBlock(into: readBlock!)
                        }
                    }
                if self.token.isWrite
                    {
                    var variableLabel: String? = nil
                    try self.nextToken()
                    if self.token.isLeftPar
                        {
                        try self.parseParentheses
                            {
                            variableLabel = try self.parseLabel()
                            }
                        }
                    writeBlock = VirtualWriteBlock()
                    writeBlock!.newValueLabel = variableLabel
                    try self.parseBraces
                        {
                        try self.parseBlock(into: writeBlock!)
                        }
                    }
                }
            }
        var slot: Slot?
        if readBlock.isNotNil
            {
            let aSlot = VirtualSlot(label: label,type: type ?? .class(VoidClass.voidClass))
            aSlot.addDeclaration(location)
            aSlot.writeBlock = writeBlock
            aSlot.readBlock = readBlock
            slot = aSlot
            }
        else
            {
            slot = Slot(label: label,type: type ?? .class(VoidClass.voidClass))
            slot?.addDeclaration(location)
            }
        slot!.initialValue = initialValue
        return(slot!)
        }
        
    private func parseClassSlot() throws -> Slot
        {
        try self.nextToken()
        let slot = try self.parseSlot()
        slot.isClassSlot = true
        return(slot)
        }
        
    private func parseClassParameters() throws -> Classes
        {
        let typeParameters = try self.parseBrockets
            {
            () throws -> Classes in
            var types = Classes()
            repeat
                {
                try self.parseComma()
                let name = try self.parseName()
                if let type = self.currentContext.lookup(name: name) as? Class
                    {
                    types.append(type)
                    }
                else
                    {
                    let type = GenericClassParameter(label: name.last)
                    types.append(type)
                    self.currentContext.addSymbol(type)
                    }
                }
            while self.token.isComma
            return(types)
            }
        return(typeParameters)
        }
        
    @discardableResult
    private func parseClass() throws -> Class
        {
        try self.nextToken()
        let location = self.token.location
        self.visualToken.kind = .class
        let label = try self.parseLabel()
        var parameters = Classes()
        if self.token.isLeftBrocket
            {
            parameters = try self.parseClassParameters()
            }
        var aClass:Class
        if parameters.isEmpty
            {
            aClass = Class(label: label)
            }
        else
            {
            aClass = GenericClass(label: label,genericClassParameters: parameters)
            }
        if parameters.filter({$0.isGenericClassParameter}).count > 0
            {
            let classParameters = parameters.filter{$0.isGenericClassParameter}.map{$0 as! GenericClassParameter}
            if parameters.count != classParameters.count
                {
                self.cancelCompletion()
                self.dispatchError("Class \(label) can not be half instanciated, either all of the class parameters must be classes or none of them.")
                }
            }
        aClass.tag = self.currentTag
        aClass.addDeclaration(location)
        self.currentContext.addSymbol(aClass)
        self.pushContext(aClass)
        if self.token.isGluon
            {
            try self.nextToken()
            repeat
                {
                try self.parseComma()
                self.visualToken.kind = .class
                let otherClassName = try self.parseName()
                let forwardClass = ForwardReferenceClass(name: otherClassName, context: self.currentContext)
                forwardClass.addDeclaration(location)
                aClass.superclassReferences.append(forwardClass)
                }
            while self.token.isComma
            }
        if aClass.superclassReferences.isEmpty
            {
            aClass.superclassReferences.append(ForwardReferenceClass(name: Name("\\\\Argon\\Object"),context: self.currentContext))
            }
        try self.parseBraces
            {
            while self.token.isSlot || self.token.isClass
                {
                if self.token.isSlot
                    {
                    let slot = try self.parseSlot()
                    slot.tag = self.currentTag
                    aClass.addSymbol(slot)
                    }
                else if self.token.isClass
                    {
                    let slot = try self.parseClassSlot()
                    slot.tag = self.currentTag
                    aClass.metaclass?.addSymbol(slot)
                    }
                }
            }
        print(aClass.containedClassParameters)
        self.popContext()
        print("PARSED CLASS: \(aClass.displayString)")
        print("CLASS PARAMETERS: \(aClass.parametricClasses?.displayString ?? "")")
        self.node = aClass
        return(aClass)
        }
        
    @discardableResult
    private func parseConstant() throws -> Constant
        {
        let location = self.token.location
        try self.nextToken()
        self.visualToken.kind = .constant
        let label = try self.parseLabel()
        var type:Type = .class(VoidClass.voidClass)
        if self.token.isGluon
            {
            try self.parseGluon()
            type = try self.parseType()
            }
        if !self.token.isAssign
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "'=' expected to follow the declaration of a CONSTANT.")
            }
        try self.nextToken()
        let value = try self.parseExpression()
        let constant = Constant(label: label,type: type,value: value)
        constant.addDeclaration(location)
        constant.tag = self.currentTag
        self.currentContext.addSymbol(constant)
        return(constant)
        }
        
    private func dispatchError(_ message:String)
        {
        self.reportingContext.dispatchError(at: self.token.location,message: message)
        }
        
    private func dispatchError(at location: Location,_ message:String)
        {
        self.reportingContext.dispatchError(at: location,message: message)
        }
        
    internal func parseParentheses<T>(_ closure: () throws -> T)  throws -> T
        {
        if !self.token.isLeftPar
            {
            self.dispatchError("'(' was expected but \(self.token) was found.")
            }
        else
            {
            try self.nextToken()
            }
        let value = try closure()
        if !self.token.isRightPar
            {
            self.dispatchError("')' was expected but \(self.token) was found.")
            }
        else
            {
            try self.nextToken()
            }
        return(value)
        }
        
    private func parseComma() throws
        {
        if self.token.isComma
            {
            try self.nextToken()
            }
        }
        
    private func parseGluon() throws
        {
        if !self.token.isGluon
            {
            self.dispatchError("'::' was expected but '\(self.token)' was found.")
            }
        else
            {
            try self.nextToken()
            }
        }
        
    private func parseType() throws -> Type
        {
        let location = self.token.location
        var name:Name
        self.visualToken.kind = .class
        if self.token.isIdentifier && self.token.isSystemClassName
            {
            self.visualToken.kind = .type
            let lastPart = self.token.identifier
            name = Name("\\\\Argon\\" + lastPart)
            }
        else if self.token.isIdentifier
            {
            self.visualToken.kind = .type
            name = Name(self.token.identifier)
            if let symbol = self.currentContext.lookup(name: name),symbol.isEnumeration
                {
                self.visualToken.kind = .enumeration
                }
            }
        else if self.token.isName
            {
            self.visualToken.kind = .type
            name = self.token.nameLiteral
            }
        else if self.token.isLeftPar
            {
            return(try self.parseMethodType())
            }
        else
            {
            self.dispatchError("A type name was expected but \(self.token) was found.")
            name = Name()
            }
        try self.nextToken()
        if name == Name("\\\\Argon\\Array")
            {
            ///
            ///
            /// At this stage do nothing but at a later stage we need to add
            /// in the parsing of the more exotic array dimensions
            ///
            ///
            }
        let parameters = try self.parseTypeParameters()
        if let symbol = self.currentContext.lookup(name: name)
            {
            if symbol.isEnumeration || symbol.isTypeAlias || symbol.isClassParameter
                {
                symbol.addReference(location)
                return(symbol.asType)
                }
            else if symbol.isClass
                {
                var clazz = Type.class(symbol as! Class)
                if !clazz.isGenericClass && !parameters.isEmpty
                    {
                    self.reportingContext.dispatchError(at: location, message: "Class '\(name)' is not a parameterized class but there are class parameters defined for it.")
                    try self.nextToken()
                    }
                else if clazz.isGenericClass && !parameters.isEmpty
                    {
                    clazz = (clazz.class as! GenericClass).instanciate(withTypes: parameters, reportingContext: self.reportingContext)
                    }
                clazz.class.addReference(location)
                return(clazz)
                }
            else
                {
                self.reportingContext.dispatchError(at: location, message: "A type was expected but was not found, the identifier '\(name)' was found.")
                try self.nextToken()
                return(.class(Class(label:"")))
                }
            }
        if name.isEmpty
            {
            self.reportingContext.dispatchError(at: location, message: "An invalid type reference was encountered.")
            name = Name("1_name")
            }
        let clazz = Type.forwardReference(name,self.currentContext)
//        clazz.addDeclaration(location)
        return(clazz)
        }
        
    private func parseMethodType() throws -> Type
        {
        let location = self.token.location
        let types = try self.parseParentheses
            {
            () throws -> [Type] in
            var types = Types()
            repeat
                {
                try self.parseComma()
                let type = try self.parseType()
                types.append(type)
                }
            while self.token.isComma
            return(types)
            }
        if !self.token.isRightArrow
            {
            self.reportingContext.dispatchError(at: location, message: "'->' was expected in a method reference type but '\(self.token)' was found.")
            }
        try self.nextToken()
        let returnType = try self.parseType()
        let reference = Type.method("",types,returnType)
        return(reference)
        }
        
    private func parseTypeParameters() throws -> Types
        {
        if self.token.isLeftBrocket
            {
            let list = try self.parseBrockets
                {
                () throws -> Types in
                var list = Types()
                while !self.token.isRightBrocket
                    {
                    try self.parseComma()
                    list.append(try self.parseType())
                    }
                return(list)
                }
            return(list)
            }
        return([])
        }
        
    internal func parseBrockets<T>(_ closure: () throws -> T) throws -> T
        {
        if self.token.isLeftBrocket
            {
            try self.nextToken()
            }
        else
            {
            self.dispatchError("'<' was expected but \(self.token) was found.")
            }
        let value = try closure()
        if self.token.isRightBrocket
            {
            try self.nextToken()
            }
        else
            {
            self.dispatchError("'>' was expected but \(self.token) was found.")
            }
        return(value)
        }
        
    private func parseParameters(_ localTypes:GenericClassParameters? = nil) throws -> Parameters
        {
        let list = try self.parseParentheses
            {
            () throws -> Parameters in
            var parameters = Parameters()
            repeat
                {
                try self.parseComma()
                if !self.token.isRightPar
                    {
                    parameters.append(try self.parseParameter())
                    }
                }
            while self.token.isComma && !self.token.isRightPar
            return(parameters)
            }
        return(list)
        }
        
    private func parseMethodGenericParameters() throws -> GenericClassParameters
        {
        var parameters = GenericClassParameters()
        try self.parseBrockets
            {
            repeat
                {
                try self.parseComma()
                self.visualToken.kind = .type
                let label = try self.parseLabel()
                parameters.append(GenericClassParameter(label: label))
                }
            while self.token.isComma
            }
        return(parameters)
        }
        
    @discardableResult
    private func parseMethod(directive: Token.Directive? = nil) throws -> ArgonWorks.Method
        {
        try self.nextToken()
        let location = self.token.location
        self.visualToken.kind = .method
        let name = try self.parseLabel()
        let existingMethod = self.currentContext.lookup(label: name) as? Method
        let localScope = TemporaryLocalScope(label:  "")
        var isGenericMethod = false
        self.pushContext(localScope)
        var types: GenericClassParameters = []
        if self.token.isLeftBrocket
            {
            types = try self.parseMethodGenericParameters()
            localScope.addTemporaries(types)
            isGenericMethod = true
            }
        let list = try self.parseParameters()
        var returnType: Type = .class(VoidClass.voidClass)
        if self.token.isRightArrow
            {
            try self.nextToken()
            returnType = try self.parseType()
            }
        if existingMethod.isNotNil
            {
            existingMethod!.addReference(location)
            if list.count != existingMethod!.proxyParameters.count
                {
                self.cancelCompletion()
                self.dispatchError("The multimethod '\(existingMethod!.label)' is defined,this parameter set is different to the existing one.")
                }
            if returnType != existingMethod!.returnType
                {
                self.cancelCompletion()
                self.dispatchError("The multimethod '\(existingMethod!.label)' declared in line \(existingMethod!.declaration?.line ?? 0) is defined with a return type of '\(existingMethod!.returnType.label)' different from this return type.")
                }
            for (yours,mine) in zip(list,existingMethod!.proxyParameters)
                {
                if yours.tag != mine.tag
                    {
                    self.dispatchError("The multimethod '\(existingMethod!.label)' has tag '\(mine.tag)' in the position of '\(yours.tag)', tags must match on multimethod instances.")
                    }
                if yours.isHidden != mine.isHidden
                    {
                    self.dispatchError("The multimethod '\(existingMethod!.label)' has tag '\(mine.tag)' which differs in visibility from the tag '\(yours.tag)'.")
                    }
                }
            }
        self.popContext()
        var instance: MethodInstance?
        if directive != .intrinsic
            {
            instance = MethodInstance(label: name,parameters: list,returnType: returnType)
            instance!.isGenericMethod = isGenericMethod
            if isGenericMethod
                {
                instance?.genericParameters = types
                }
            instance!.mergeTemporaryScope(localScope)
            instance!.addDeclaration(location)
            }
        var method: Method?
        if existingMethod.isNotNil && directive != .intrinsic
            {
            existingMethod?.addInstance(instance!)
            }
        else
            {
            method = Method(label: name)
            method!.isIntrinsic = directive == .intrinsic
            method!.isGenericMethod = isGenericMethod
            method!.addDeclaration(location)
            method?.tag = self.currentTag
            self.currentContext.addSymbol(method!)
            if instance != nil
                {
                method!.addInstance(instance!)
                }
            }
        instance?.block.addParameters(list)
        if directive != .intrinsic
            {
            try self.parseBraces
                {
                self.pushContext(instance!)
                try self.parseBlock(into: instance!.block)
                self.popContext()
                }
            if returnType != .class(VoidClass.voidClass) && !instance!.block.hasReturnBlock
                {
                self.cancelCompletion()
                self.dispatchError(at: location,"This method has a return value but there is no RETURN statement in the body of the method.")
                }
            }
        if instance != nil
            {
            self.currentContext.addSymbol(instance!.method)
            }
        return(method ?? existingMethod!)
        }
        
    private func parseStatements() throws -> Expressions
        {
        return(Expressions())
        }
        
    private func parseExpression() throws -> Expression
        {
        let location = self.token.location
        let lhs = try self.parseAsExpression()
        lhs.addDeclaration(location)
        if self.token.isAssign
            {
            try self.nextToken()
            let rhs = try self.parseAsExpression()
            return(AssignmentExpression(lhs,Token.Operator("="),rhs))
            }
        print("PARSED EXPRESSION:")
        print(lhs.displayString)
        return(lhs)
        }
        
    private func parseAsExpression() throws -> Expression
        {
//        let location = self.token.location
//        var lhs = try self.parseScopeExpression()
//        if self.token.isAs
//            {
//            try self.nextToken()
//            let rhs = try self.parseType()
//            if self.token.isEnd
//                {
//                return(Expression())
//                }
//            lhs = lhs.cast(into: rhs)
//            lhs.addDeclaration(location)
//            }
//        return(lhs)
        return(try self.parseScopeExpression())
        }
        
    private func parseScopeExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseSlotExpression()
        lhs.addDeclaration(location)
        var child:String
        while self.token.isGluon
            {
            if !lhs.canBeScoped
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "An expression that can be scoped is required before a gluon.")
                lhs = LiteralExpression(.class(Class(label:"")))
                }
            try self.nextToken()
            if self.token.isIdentifier
                {
                child = self.token.identifier
                try self.nextToken()
                }
            else if self.token.isHashStringLiteral
                {
                child = self.token.hashStringLiteral
                try self.nextToken()
                }
            else
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "An identifier was expected after the gluon, but '\(self.token)' was found.")
                try self.nextToken()
                child = ""
                }
            if let expression = lhs.scopedExpression(for: child)
                {
                lhs = expression
                }
            else
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "The reference '\(child)' is not valid in the current context.")
                }
            if self.token.isLeftPar && lhs.isEnumerationCaseExpression
                {
                lhs = try self.parseAssociatedValues(with: lhs)
                }
            }
        return(lhs)
        }
        
    private func parseAssociatedValues(with lhs: Expression) throws -> Expression
        {
        let theCase = lhs.enumerationCase
        try self.nextToken()
        if theCase.associatedTypes.isEmpty
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "The case '\(theCase.label)' does not have any associated values.")
            }
        var values = Array<Expression>()
        var index = 0
        while index < theCase.associatedTypes.count && !self.token.isRightPar
            {
            values.append(try self.parseExpression())
            try self.parseComma()
            index += 1
            }
        if !self.token.isRightPar
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "A ')' was expected after the associated values for '\(theCase.label)' but it was not found.")
            }
        try self.nextToken()
        return(EnumerationInstanceExpression(caseLabel: theCase.label,enumeration: theCase.enumeration, enumerationCase: theCase, associatedValues: values))
        }
        
    private func parseSlotExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseIncDecExpression()
        lhs.addDeclaration(location)
        while self.token.isRightArrow
            {
            try self.nextToken()
            lhs = lhs.slot(try self.parseSlotSelectorExpression())
            }
        return(lhs)
        }
        
    private func parseIncDecExpression() throws -> Expression
        {
        let location = self.token.location
        let expression = try self.parseArrayExpression()
        expression.addDeclaration(location)
        if self.token.isPlusPlus || self.token.isMinusMinus
            {
            let symbol = self.token.operator
            try self.nextToken()
            return(SuffixExpression(expression,symbol))
            }
        return(expression)
        }

    private func parseArrayExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseBooleanExpression()
        lhs.addDeclaration(location)
        while self.token.isLeftBracket
            {
            try self.nextToken()
            let rhs = try self.parseExpression()
            if !self.token.isRightBracket
                {
                self.dispatchError("']' expected but \(self.token) was found.")
                }
            try self.nextToken()
            lhs = lhs.index(rhs)
            }
        return(lhs)
        }
        
    private func parseBooleanExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseComparisonExpression()
        lhs.addDeclaration(location)
        while self.token.isAnd || self.token.isOr
            {
            let symbol = token.symbol
            try self.nextToken()
            lhs = lhs.operation(symbol,try self.parseComparisonExpression())
            }
        return(lhs)
        }
        
    private func parseComparisonExpression() throws -> Expression
        {
        let location = self.token.location
        let lhs = try self.parseArithmeticExpression()
        lhs.addDeclaration(location)
        if self.token.isLeftBrocket || self.token.isLeftBrocketEquals || self.token.isEquals || self.token.isRightBrocket || self.token.isRightBrocketEquals || self.token.isNotEquals
            {
            let symbol = self.token.symbol
            try self.nextToken()
            let rhs = try self.parseArithmeticExpression()
            return(lhs.operation(symbol,rhs))
            }
        return(lhs)
        }
        
    private func parseArithmeticExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseMultiplicativeExpression()
        lhs.addDeclaration(location)
        while self.token.isAdd || self.token.isSub
            {
            let symbol = token.symbol
            try self.nextToken()
            lhs = lhs.operation(symbol,try self.parseMultiplicativeExpression())
            }
        return(lhs)
        }
        
    private func parseMultiplicativeExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseBitExpression()
        lhs.addDeclaration(location)
        while self.token.isMul || self.token.isDiv || self.token.isModulus
            {
            let symbol = token.symbol
            try self.nextToken()
            lhs = lhs.operation(symbol,try self.parseBitExpression())
            }
        return(lhs)
        }
        
    private func parseBitExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseUnaryExpression()
        lhs.addDeclaration(location)
        while self.token.isBitAnd || self.token.isBitOr || self.token.isBitXor
            {
            let symbol = token.symbol
            try self.nextToken()
            lhs = lhs.operation(symbol,try self.parseUnaryExpression())
            }
        return(lhs)
        }
        
    private func parseUnaryExpression() throws -> Expression
        {
        if self.token.isSub || self.token.isBitNot || self.token.isNot
            {
            return(try self.parseUnaryExpression().unary(self.token.symbol))
            }
        else
            {
            let location = self.token.location
            let term = try self.parsePrimary()
            term.addDeclaration(location)
            return(term)
            }
        }
        
    private func parseGeneratorExpression() throws -> Expression
        {
        try self.nextToken()
//        let variables = self.parseGenerativeVariables()
        while !self.token.isRightBracket
            {
            try self.nextToken()
            }
        try self.nextToken()
        return(Expression())
        }
        
    private func parseGenerativeVariables() -> Array<Label>
        {
        return([])
        }
        
    private func parsePrimary() throws -> Expression
        {
        if self.token.isLeftBracket
            {
            return(try self.parseGeneratorExpression())
            }
        else if self.token.isIntegerLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.integer(self.lastToken.integerLiteral)))
            }
        else if self.token.isFloatingPointLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.float(self.lastToken.floatingPointLiteral)))
            }
        else if self.token.isStringLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.string(self.lastToken.stringLiteral)))
            }
        else if self.token.isHashStringLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.symbol(self.lastToken.hashStringLiteral)))
            }
        else if self.token.isNilLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.nil))
            }
        else if self.token.isBooleanLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.boolean(self.lastToken.booleanLiteral)))
            }
        else if self.token.isIdentifier
            {
            return(try self.parseIdentifierTerm())
            }
        else if self.token.isGluon
            {
            return(try self.parseEnumerationCaseExpression())
            }
        else if self.token.isLeftPar
            {
            return(try self.parseParentheses
                {
                let expression = try self.parseExpression()
                if self.token.isComma
                    {
                    let tuple = TupleExpression()
                    tuple.append(expression)
                    while self.token.isComma
                        {
                        tuple.append(try self.parseExpression())
                        }
                    return(tuple)
                    }
                return(expression)
                })
            }
        else if self.token.isLeftBrace
            {
            return(try self.parseClosureTerm())
            }
        else
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "This expression is invalid.")
            try self.nextToken()
            return(Expression())
//            fatalError("Invalid parse state \(self.lastToken) \(self.token)")
            }
        }
        
    private func parseEnumerationCaseExpression() throws -> Expression
        {
        try self.nextToken()
        if !self.token.isIdentifier
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "When a gluon is used to begin an enumeration case, it must be followed by an identifier.")
            try self.nextToken()
            return(Expression())
            }
        self.visualToken.kind = .enumeration
        let theCaseKey = self.token.identifier
        try self.nextToken()
        return(EnumerationInstanceExpression(caseLabel: theCaseKey,enumeration: nil, enumerationCase: nil, associatedValues: nil))
        }
        
    private func parseSlotSelectorExpression() throws -> Expression
        {
        self.visualToken.kind = .classSlot
        let location = self.token.location
        let first = try self.parseLabel()
        let lhs = SlotSelectorExpression(selector: first)
        lhs.addDeclaration(location)
        return(lhs)
        }
        
    private func parseIdentifierTerm() throws -> Expression
        {
        let location = self.token.location
        if try self.peekToken1().isLeftPar
            {
            self.visualToken.kind = .methodInvocation
            }
        let name = try self.parseName()
        let aSymbol = self.currentContext.lookup(name: name)
        if let symbol = aSymbol as? Enumeration
            {
            let enumeration = LiteralExpression(.enumeration(symbol))
            enumeration.addDeclaration(location)
            return(enumeration)
            }
        else if let symbol = aSymbol as? Class
            {
            var clazz = Type.class(symbol)
            if clazz.isGenericClass
                {
                let genericClass = clazz.class as! GenericClass
                if !self.token.isLeftBrocket
                    {
                    self.cancelCompletion()
                    self.dispatchError(at: self.token.location, message: "A '<' was expected after a generic class reference but \(self.token) was found.")
                    }
                else
                    {
                    let types = try self.parseTypeParameters()
                    clazz = genericClass.instanciate(withTypes: types, reportingContext: self.reportingContext)
                    }
                }
            if self.token.isLeftPar
                {
                return(try self.parseInstanciationTerm(ofClass: clazz.class))
                }
            let literal = LiteralExpression(.class(clazz.class))
            literal.addDeclaration(location)
            return(literal)
            }
        else if let symbol = aSymbol as? Module
            {
            let module = LiteralExpression(.module(symbol))
            module.addDeclaration(location)
            return(module)
            }
        else if let symbol = aSymbol as? Constant
            {
            return(LiteralExpression(.constant(symbol)))
            }
        else if let symbol = aSymbol as? Slot
            {
            let read = LocalSlotExpression(slot: symbol)
            read.addDeclaration(location)
            return(read)
            }
        else if self.token.isLeftPar
            {
            return(try self.parseInvocationTerm(name))
            }
        else
            {
            let term = LocalSlotExpression(slot: Slot(label: name.last, type: .class(VoidClass.voidClass)))
            term.addDeclaration(location)
            return(term)
            }
        }
        
    private func parseClosureTerm() throws -> BlockExpression
        {
        let closure = ClosureBlock()
        let location = self.token.location
        try self.parseBraces
            {
            if self.token.isWith
                {
                try self.nextToken()
                closure.parameters = try self.parseParameters()
                }
            if self.token.isRightArrow
                {
                try self.nextToken()
                closure.returnType = try self.parseType()
                }
            for parameter in closure.parameters
                {
                closure.addLocalSlot(parameter)
                }
            while !self.token.isRightBrace
                {
                try self.parseBlock(into: closure)
                }
            }
        let block = BlockExpression(block: closure)
        block.addDeclaration(location)
        return(block)
        }
        
    private func parseInvocationTerm(method: Method) throws -> Expression
        {
        let location = self.token.location
        let args = try self.parseParentheses
            {
            try self.parseArguments()
            }
        let expression = MethodInvocationExpression(method: method,arguments: args)
        expression.addDeclaration(location)
        return(expression)
        }
        
    private func parseArguments() throws -> Arguments
        {
        var arguments = Arguments()
        while !self.token.isRightPar
            {
            repeat
                {
                try self.parseComma()
                arguments.append(try self.parseArgument())
                }
            while self.token.isComma
            }
        return(arguments)
        }
        
    private func parseArgument() throws -> Argument
        {
        if try self.token.isIdentifier && self.peekToken1().isGluon
            {
            let tag = token.identifier
            try self.nextToken()
            try self.nextToken()
            return(Argument(tag: tag, value: try self.parseExpression()))
            }
        return(Argument(tag: nil,value: try self.parseExpression()))
        }
        
    private func parseInvocationTerm(_ name:Name) throws -> Expression
        {
        let location = self.token.location
        self.visualToken.kind = .methodInvocation
        let method = self.currentContext.lookup(name: name) as? Method
        if method.isNotNil
            {
            return(try self.parseInvocationTerm(method: method!))
            }
        let args = try self.parseParentheses
            {
            try self.parseArguments()
            }
        let expression = InvocationExpression(name: name,arguments: args, location: self.token.location,context: self.currentContext, reportingContext: self.reportingContext)
        expression.addDeclaration(location)
        return(expression)
        }
        
    private func parseInstanciationTerm(ofClass aClass: Class) throws -> Expression
        {
        let location = self.token.location
        var arguments = Arguments()
        try self.parseParentheses
            {
            () throws -> Void in
            if !self.token.isRightPar
                {
                repeat
                    {
                    try self.parseComma()
                    arguments.append(try self.parseArgument())
                    }
                while self.token.isComma
                }
            }
        let invocation = ClassInstanciationTerm(type: aClass,arguments: arguments)
        invocation.addDeclaration(location)
        return(invocation)
        }
        
    private func parseBlock(into block: Block) throws
        {
        while !self.token.isRightBrace
            {
            if self.token.isEnd
                {
                return
                }
            if self.token.isSelect
                {
                try self.parseSelectBlock(into: block)
                }
            else if self.token.isIf
                {
                try self.parseIfBlock(into: block)
                }
            else if self.token.isWhile
                {
                try self.parseWhileBlock(into: block)
                }
            else if self.token.isFork
                {
                try self.parseForkBlock(into: block)
                }
            else if self.token.isLoop
                {
                try self.parseLoopBlock(into: block)
                }
            else if self.token.isSignal
                {
                try self.parseSignalBlock(into: block)
                }
            else if self.token.isHandle
                {
                try self.parseHandleBlock(into: block)
                }
            else if self.token.isIdentifier
                {
                try self.parseIdentifierBlock(into: block)
                }
            else if self.token.isReturn
                {
                try self.parseReturnBlock(into: block)
                }
            else if self.token.isLet
                {
                try self.parseLetBlock(into: block)
                }
            else
                {
                self.dispatchError("A statement was expected but \(self.token) was found.")
                try self.nextToken()
                }
            }
        }
        
    private func parseSelectBlock(into block: Block) throws
        {
        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let value = try self.parseParentheses
            {
            return(try self.parseExpression())
            }
        let selectBlock = SelectBlock(value: value)
        selectBlock.addDeclaration(location)
        block.addBlock(selectBlock)
        try self.parseBraces
            {
            while !self.token.isRightBrace && !self.token.isOtherwise
                {
                if !self.token.isWhen
                    {
                    self.dispatchError("WHEN expected after SELECT clause")
                    try self.nextToken()
                    }
                try self.nextToken()
                let location1 = self.token.location
                let inner = try self.parseParentheses
                    {
                    try self.parseExpression()
                    }
                let when = WhenBlock(condition: inner)
                when.addDeclaration(location1)
                selectBlock.addWhen(block: when)
                try self.parseBraces
                    {
                    try self.parseBlock(into: when)
                    }
                }
            if self.token.isOtherwise
                {
                let otherwise = OtherwiseBlock()
                try self.nextToken()
                try self.parseBraces
                    {
                    try self.parseBlock(into: otherwise)
                    }
                selectBlock.addOtherwise(block: otherwise)
                }
            }
        self.stopClip(into: selectBlock)
        }
        
    private func parseElseIfBlock(into block: IfBlock) throws
        {
        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let expression = try self.parseExpression()
        let statement = ElseIfBlock(condition: expression)
        block.elseBlock = statement
        statement.addDeclaration(location)
        try self.parseBraces
            {
            try self.parseBlock(into: statement)
            }
        if try self.token.isElse && self.peekToken1().isIf
            {
            try self.nextToken()
            try self.parseElseIfBlock(into: statement)
            }
        if self.token.isElse
            {
            try self.nextToken()
            let elseClause = ElseBlock()
            statement.elseBlock = elseClause
            try self.parseBraces
                {
                try self.parseBlock(into: elseClause)
                }
            }
        self.stopClip(into: statement)
        }
        
    private func parseIfBlock(into block: Block) throws
        {
        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let expression = try self.parseExpression()
        let statement = IfBlock(condition: expression)
        block.addBlock(statement)
        statement.addDeclaration(location)
        try self.parseBraces
            {
            try self.parseBlock(into: statement)
            }
        if try self.token.isElse && self.peekToken1().isIf
            {
            try self.nextToken()
            try self.parseElseIfBlock(into: statement)
            }
        if self.token.isElse
            {
            try self.nextToken()
            let elseClause = ElseBlock()
            statement.elseBlock = elseClause
            try self.parseBraces
                {
                try self.parseBlock(into: elseClause)
                }
            }
        self.stopClip(into: statement)
        }
        
    private func parseLetBlock(into block: Block) throws
        {
        self.startClip()
        let location = self.token.location
        try self.nextToken()
        let someVariable = try self.parseName()
        var type: Type?
        if self.token.isGluon
            {
            try self.nextToken()
            type = try self.parseType()
            }
        if !self.token.isAssign
            {
            self.dispatchError("'=' expected after LET clause.")
            }
        try self.nextToken()
        let value = try self.parseExpression()
        value.setParent(block)
        let localSlot = LocalSlot(label: someVariable.last, type: type,value: value)
        block.addLocalSlot(localSlot)
        let statement = LetBlock(name: someVariable,slot:localSlot,location: self.token.location,namingContext: block,value: value)
        statement.addDeclaration(location)
        block.addBlock(statement)
        self.stopClip(into: statement)
        }
        
    private func parseReturnBlock(into block: Block) throws
        {
        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let value = try self.parseParentheses
            {
            try self.parseExpression()
            }
        let returnBlock = ReturnBlock()
        returnBlock.addDeclaration(location)
        returnBlock.value = value
        block.addBlock(returnBlock)
        self.stopClip(into: returnBlock)
        }
        
    private func parseWhileBlock(into block: Block) throws
        {
        self.startClip()
        let location = self.token.location
        try self.nextToken()
        let expression = try self.parseExpression()
        let statement = WhileBlock(condition: expression)
        statement.addDeclaration(location)
        try self.parseBraces
            {
            try self.parseBlock(into: statement)
            }
        block.addBlock(statement)
        self.stopClip(into: block)
        }
        
    private func parseInductionVariable() throws
        {
        }
        
    private func parseForkBlock(into block: Block) throws
        {
        self.startClip()
        let location = self.token.location
        let variableName = try self.parseLabel()
        try self.parseInductionVariable()
        let statement = ForBlock(name: variableName)
        statement.addDeclaration(location)
        try self.parseBlock(into: statement)
        block.addBlock(statement)
        self.stopClip(into: statement)
        }
        
    private var textStart: Int = 0
    
    private func startClip()
        {
        self.textStart = self.token.location.tokenStart
        }
        
    private func stopClip(into block: Block)
        {
        let stop = self.token.location.tokenStop
        block.source = self.source!.substring(with: self.textStart..<stop + 1)
        }
        
    private func stopClip(into symbol: Symbol)
        {
        let stop = self.token.location.tokenStop
        symbol.source = self.source!.substring(with: self.textStart..<stop + 1)
        }
        
    private func parseLoopBlock(into block: Block) throws
        {
        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let (start,end,update) = try self.parseLoopConstraints()
        let statement = LoopBlock(start: start,end: end,update: update)
        statement.addDeclaration(location)
        block.addBlock(statement)
        try self.parseBraces
            {
            try self.parseBlock(into: statement)
            }
        self.stopClip(into: statement)
        }
        
    private func parseLoopConstraints() throws -> ([Expression],Expression,[Expression])
        {
        var start = Array<Expression>()
        var end = Expression()
        var update = Array<Expression>()
        try self.parseParentheses
            {
            repeat
                {
                try self.parseComma()
                start.append(try self.parseExpression())
                }
            while self.token.isComma
            if !self.token.isSemicolon
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "';' was expected between LOOP clauses.")
                }
            try self.nextToken()
            repeat
                {
                try self.parseComma()
                update.append(try self.parseExpression())
                }
            while self.token.isComma
            if !self.token.isSemicolon
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "';' was expected between LOOP clauses.")
                }
            try self.nextToken()
            end = try self.parseExpression()
            }
        return((start,end,update))
        }
        
    private func parseSignalBlock(into block: Block) throws
        {
        try self.nextToken()
        let location = self.token.location
        try self.parseParentheses
            {
            if try self.nextToken().isHashStringLiteral
                {
                let symbol = self.token.hashStringLiteral
                let signal = SignalBlock(symbol: symbol)
                signal.addDeclaration(location)
                block.addBlock(signal)
                try self.nextToken()
                }
            else
                {
                self.dispatchError("Symbol expected but \(self.token) was found instead.")
                }
            }
        }

    private func parseIdentifierBlock(into block: Block) throws
        {
        let start = self.token.location.tokenStart
        var expression = try self.parseExpression()
        if self.token.isPlusPlus || self.token.isMinusMinus
            {
            let symbol = self.token.operator
            try self.nextToken()
            expression = SuffixExpression(expression,symbol)
            }
        else if self.token.isAddEquals || self.token.isSubEquals || self.token.isMulEquals || self.token.isDivEquals || self.token.isBitAndEquals || self.token.isBitOrEquals || self.token.isBitNotEquals || self.token.isBitXorEquals
            {
            let symbol = self.token.operator
            try self.nextToken()
            expression = expression.assign(symbol,try self.parseExpression())
            }
        else if self.token.isAssign
            {
            try self.nextToken()
            expression = expression.assign(Token.Operator.assign,try self.parseExpression())
            }
        let stop = self.token.location.tokenStop
        let newBlock = ExpressionBlock(expression)
        newBlock.source = self.source!.substring(with: start..<stop + 1)
        block.addBlock(newBlock)
        }
        
    private func parseAssignmentBlock(into block: Block) throws
        {
        print("HALT")
        }
        
    private func parseParameter() throws -> Parameter
        {
        let location = self.token.location
        var isHidden = false
        if self.token.isAssign
            {
            isHidden = true
            try self.nextToken()
            }
        let tag = try self.parseLabel()
        try self.parseGluon()
        let type = try self.parseType()
        var isVariadic = false
        if self.token.isFullRange
            {
            try self.nextToken()
            isVariadic = true
            }
        let parameter = Parameter(label: tag, type: type,isVisible: isHidden,isVariadic: isVariadic)
        parameter.addDeclaration(location)
        return(parameter)
        }
        
    @discardableResult
    private func parseFunction() throws -> Function
        {
        try self.nextToken()
        let location = self.token.location
        self.visualToken.kind = .function
        let cName = try self.parseParentheses
            {
            () throws -> String in
            let string = try self.parseLabel()
            return(string)
            }
        let name = try self.parseLabel()
        let parameters = try self.parseParameters()
        let function = Function(label: name)
        function.addDeclaration(location)
        function.cName = cName
        function.parameters = parameters
        if self.token.isRightArrow
            {
            try self.nextToken()
            function.returnType = try self.parseType()
            }
        function.tag = self.currentTag
        self.currentContext.addSymbol(function)
        return(function)
        }
        
    @discardableResult
    private func parseTypeAlias() throws -> TypeAlias
        {
        try self.nextToken()
        let location = self.token.location
        self.visualToken.kind = .type
        let label = try self.parseLabel()
        if !self.token.isIs
            {
            self.dispatchError("IS expeected after new name for type.")
            }
        try self.nextToken()
        let type = try self.parseType()
        let alias = TypeAlias(label: label,type: type)
        alias.addDeclaration(location)
        alias.tag = self.currentTag
        self.currentContext.addSymbol(alias)
        return(alias)
        }
        
    private func parseHandleBlock(into block: Block) throws
        {
        let start = self.token.location.tokenStart
        try self.nextToken()
        let location = self.token.location
        let handler = HandlerBlock()
        handler.addDeclaration(location)
        block.addBlock(handler)
        self.pushContext(handler)
        try self.parseParentheses
            {
            repeat
                {
                try self.parseComma()
                if !self.token.isHashStringLiteral
                    {
                    self.dispatchError("A symbol was expected in the handler clause, but \(self.token) was found.")
                    }
                let symbol = self.token.isHashStringLiteral ? self.token.hashStringLiteral : "#SYMBOL"
                try self.nextToken()
                handler.symbols.append(symbol)
                }
            while self.token.isComma
            }
        try self.parseBraces
            {
            if !self.token.isWith
                {
                self.dispatchError("WITH expected in first line of HANDLE clause, but \(self.token) was found.")
                }
            try self.nextToken()
            var name:String = ""
            try self.parseParentheses
                {
                if !self.token.isIdentifier
                    {
                    self.dispatchError("The name of an induction variable to contain the symbol this handler is receiving was expected but \(self.token) was found.")
                    }
                name = self.token.isIdentifier ? self.token.identifier : "VariableName"
                handler.addParameter(label: name,type: TopModule.shared.argonModule.symbol.type)
                try self.nextToken()
                }
            try self.parseBlock(into: handler)
            }
        self.popContext()
        let stop = self.token.location.tokenStop
        handler.source = self.source!.substring(with: start..<stop + 1)
        }
    }

extension Array where Element == Parameter
    {
    public func parameterIfAvailable(_ index:Int) -> Element?
        {
        if index < self.count
            {
            return(self[index])
            }
        return(nil)
        }
    }
