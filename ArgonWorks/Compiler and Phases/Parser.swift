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
    case none
    case block(Block)
    case node(Node)

    public var label: Label
        {
        switch(self)
            {
            case .none:
                return("NONE")
            case .block:
                return("BLOCK")
            case .node(let node):
                return(node.label)
            }
        }
        
    public var firstInitializer: Initializer?
        {
        switch(self)
            {
            case .none:
                return(nil)
            case .block(let block):
                return(block.firstInitializer)
            case .node(let node):
                return(node.firstInitializer)
            }
        }
        
    public func addSymbol(_ symbol:Symbol)
        {
        switch(self)
            {
            case .none:
                break
            case .node(let node):
                node.addSymbol(symbol)
            case .block(let block):
                block.addSymbol(symbol)
            }
        }
        
    public func setSymbol(_ symbol:Symbol,atName: Name)
        {
        switch(self)
            {
            case .none:
                break
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
            case .none:
                return(nil)
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
            case .none:
                return(nil)
            case .node(let node):
                return(node.lookup(label: label))
            case .block(let block):
                return(block.lookup(label: label))
            }
        }
    }
        
public class Parser: CompilerPass
    {
    internal private(set) var token:Token = .none
    private var lastToken:Token = .none
    public let compiler:Compiler
    private var namingContext: NamingContext
    private var contextStack = Stack<Context>()
    private var currentContext:Context!
    private var node:ParseNode?
    private var source: String?
    public var wasCancelled = false
    public var currentTag = 0
    private var isParsingLValue = false
    private var sourceStack = Stack<TokenSource>()
    private var tokenSource: TokenSource!
    private var lineNumber:LineNumber = EmptyLineNumber()
    private var reportingContext:ReportingContext = NullReportingContext.shared
    private var tokenRenderer: SemanticTokenRenderer!
    private var warningCount = 0
    private var errorCount = 0
    
    init(compiler:Compiler,source: String)
        {
        self.currentContext = .node(compiler.topModule)
        self.tokenRenderer = compiler.tokenRenderer
        self.compiler = compiler
        self.namingContext = compiler.topModule
        self.reportingContext = compiler.reportingContext
        self.initParser(source: source)
        }
        
    init(compiler:Compiler,tokens: Tokens)
        {
        self.currentContext = .node(compiler.topModule)
        self.tokenRenderer = compiler.tokenRenderer
        self.compiler = compiler
        self.namingContext = compiler.topModule
        self.reportingContext = compiler.reportingContext
        self.initParser(tokens: tokens)
        }
    
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
        self.token = self.tokenSource.nextToken()
        self.token = self.token.withLocation(self.token.location.with(self.lineNumber.suffixed(by: token.location.lineNumber)))
        if self.token.isEnd && !self.sourceStack.isEmpty
            {
            self.tokenSource = self.sourceStack.pop()
            self.lineNumber = self.tokenSource.lineNumber
            self.token = self.tokenSource.nextToken()
            }
//        while self.token.isComment || self.token.isInvisible
//            {
//            self.token = self.tokenSource.nextToken()
//            }
        print(self.token)
        return(self.token)
        }
        
    private func peekToken1() throws -> Token
        {
        return(self.tokenSource.peekToken(count: 1))
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
        
    private func addSymbol(_ symbol: Symbol)
        {
        self.currentContext.addSymbol(symbol)
        print("ADDED \(symbol.label) TO \(self.currentContext.label)")
        }
    
    private func initParser(tokens: Tokens)
        {
        self.source = nil
        self.currentContext = .node(self.compiler.topModule)
        self.tokenSource = TokenHolder(tokens: tokens)
        self.reportingContext = self.compiler.reportingContext
        }
    
    private func initParser(source: String)
        {
        self.source = source
        self.currentContext = .node(self.compiler.topModule)
        self.tokenSource = TokenStream(source: source,context: self.reportingContext,withComments: false)
        self.reportingContext = self.compiler.reportingContext
        }
        
    public func parseModifier() throws -> PrivacyScope?
        {
        if self.token.isKeyword,let scope = PrivacyScope(rawValue: self.token.keyword.rawValue)
            {
            try self.nextToken()
            return(scope)
            }
        return(nil)
        }
        
    internal func parse() -> ParseNode?
        {
        do
            {
            self.warningCount = 0
            self.errorCount = 0
            try self.nextToken()
            let modifier = try self.parseModifier()
            if self.token.isEnd
                {
                return(nil)
                }
//            var directive: Token.Directive?
            if self.token.isDirective
                {
//                directive = token.directive
                try self.nextToken()
                }
            if !self.token.isKeyword
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "KEYWORD expected.")
                return(nil)
                }
            if self.token.isKeyword
                {
                var parseNode: ParseNode?
                if self.token.isMain
                    {
                    parseNode = try self.parseMain()
                    }
                else if self.token.isModule
                    {
                    parseNode = try self.parseModule()
                    }
                parseNode?.privacyScope = modifier
                self.reportingContext.status("Parsing complete: \(self.warningCount) warnings, \(self.errorCount) errors.")
                return(parseNode)
                }
            }
        catch
            {
            }
        self.reportingContext.status("Parsing failed.")
        return(nil)
        }
        
    @discardableResult
    public func parseSource(_ source:String) -> ParseNode?
        {
        self.initParser(source: source)
        return(self.parse())
        }
        
    @discardableResult
    public func parseTokens(_ tokens: Tokens) -> ParseNode?
        {
        self.initParser(tokens: tokens)
        return(self.parse())
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
        
    private func parsePrivacyScope() throws -> PrivacyScope?
        {
        let modifier = self.token.isKeyword ? PrivacyScope(rawValue: self.token.keyword.rawValue) : nil
        if self.token.isPrivacyModifier
            {
            try self.chompKeyword()
            }
        return(modifier)
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
        method.isMainMethod = true
        return(method)
        }
        
    private func parseMainModule() throws -> Module
        {
        try self.nextToken()
        let label = try self.parseLabel()
        let module = MainModule(label: label)
        module.tag = self.currentTag
        self.addSymbol(module)
        try self.parseModule(into: module)
        self.node = module
        return(module)
        }
    
    private func parsePath() throws -> Token
        {
        if self.token.isPathLiteral
            {
            self.tokenRenderer.setKind(.path,ofToken: self.token)
            try self.nextToken()
            return(self.lastToken)
            }
        self.dispatchError("Path expected for a library module but \(self.token) was found.")
        return(.path("",Location.zero))
        }
    ///
    ///
    /// PARSE A MODULE
    ///
    /// All modules are identified by a Name which may
    /// or may not be a segmented name. Modules can be opened and closed
    /// repeatedly and each time a module is opened conformances can be
    /// added to it, such as contracts or similar. When a named module
    /// represents an existing module, that module ( such as it exists
    /// in the image of the ArgonWorks instance parsing the code ) will be
    /// fetched from main memory and all constructs in the Argon source file
    /// being parsed will take place in that module. If constructs overwrite
    /// what is currently stored in the module then it is the users
    /// responsibility. If you want to preserve a module from being modified
    /// then save it out to an Argon Symbols file where its state will
    /// be preserved until as such time as it is loaded into memory
    /// again.
    ///
    ///
    @discardableResult
    private func parseModule() throws -> Module
        {
        let location = self.token.location
        try self.nextToken()
        self.tokenRenderer.setKind(.module,ofToken: self.token)
        let name = try self.parseName()
        var module = self.currentContext.lookup(name: name) as? Module
        var isNew = false
        var path: String? = nil
        if self.token.isLeftPar
            {
            try self.parseParentheses
                {
                path = try self.parsePath().pathLiteral
                }
            }
        if module.isNil
            {
            isNew = true
            if path.isNotNil
                {
                module = LibraryModule(label: name.last,path: path!)
                }
            else
                {
                module = Module(label: name.last)
                }
            }
        else
            {
            if path.isNotNil
                {
                if let libraryModule = module as? LibraryModule
                    {
                    libraryModule.path = path!
                    }
                else
                    {
                    self.dispatchWarning(at: location,"A module named '\(name.string)' was found, but it was used as a library module and it is a module")
                    }
                }
            self.dispatchWarning(at: location,"A module named '\(name.string)' already exists, its contents may be overwritten.")
            }
        if isNew
            {
            if name.count == 1
                {
                self.addSymbol(module!)
                }
            else
                {
                self.currentContext.lookup(name: name.withoutLast)?.addSymbol(module!)
                }
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
                _ = try self.parsePrivacyScope()
                var directive: Token.Directive?
                if self.token.isDirective
                    {
                    directive = self.token.directive
                    try self.nextToken()
                    }
                try self.parseMacroInvocation()
                if !self.token.isKeyword
                    {
                    self.reportingContext.dispatchError(at: self.token.location, message: "Keyword expected but \(self.token) found.")
                    try self.nextToken()
                    }
                else
                    {
                    if !self.token.isKeyword
                        {
                        return
                        }
                    switch(self.token.keyword)
                        {
                        case .PREFIX:
                            try self.parseOperator(.prefix)
                        case .INFIX:
                            try self.parseOperator(.infix)
                        case .POSTFIX:
                            try self.parseOperator(.postfix)
                        case .MACRO:
                            try self.parseMacroDeclaration()
                        case .IMPORT:
                            try self.parseImport()
                        case .INIT:
                            try self.parseInitializer()
                        case .FUNCTION:
                            try self.parseFunction()
                        case .MAIN:
                            try self.parseMain()
                        case .MODULE:
                            try self.parseModule()
                        case .CLASS:
                            try self.parseClass()
                        case .TYPE:
                            try self.parseTypeAlias()
                        case .PRIMITIVE:
                            try self.parsePrimitiveMethod()
                        case .METHOD:
                            try self.parseMethod(directive: directive)
                        case .CONSTANT:
                            try self.parseConstant()
                        case .SCOPED:
                            let scoped = try self.parseScopedSlot()
                            scoped.tag = self.currentTag
                            module.addSymbol(scoped)
                        case .ENUMERATION:
                            try self.parseEnumeration()
                        case .SLOT:
                            let slot = try self.parseSlot()
                            slot.tag = self.currentTag
                            module.addSymbol(slot)
                        case .INTERCEPTOR:
                            let interceptor = try self.parseInterceptor()
                            interceptor.tag = self.currentTag
                            module.addSymbol(interceptor)
                        default:
                            self.reportingContext.dispatchError(at: self.token.location, message: "A declaration for a module element was expected but \(self.token) was found.")
                            if !self.token.isRightBrace
                                {
                                try self.nextToken()
                                }
                            }
                        
                        }
                    }
                }
        
        self.popContext()
        }
        
    private enum OperatorKind
        {
        case prefix
        case postfix
        case infix
        }
        
    private func parseOperator(_ kind: OperatorKind) throws
        {
        var isPrimitive = false
        let location = self.token.location
        try self.nextToken()
        if self.token.isPrimitive
            {
            isPrimitive = true
            try self.nextToken()
            }
        var operation: Token.Operator
        if !(self.token.isOperator || self.token.isSymbol)
            {
            self.cancelCompletion()
            self.dispatchError("Operator expected after PREFIX, POSTFIX,INFIX or PRIMITIVE, but '\(self.token)' found.")
            operation = Token.Operator("%%")
            }
        else
            {
            if self.token.isSymbol
                {
                operation = Token.Operator(self.token.symbol)
                }
            else
                {
                operation = self.token.operator
                }
            }
        let localScope = TemporaryLocalScope(label:  "")
        var isGenericMethod = false
        self.pushContext(localScope)
        try self.nextToken()
        var types = GenericClassParameters()
        if self.token.isLeftBrocket
            {
            types = try self.parseMethodGenericParameters()
            localScope.addTemporaries(types)
            isGenericMethod = true
            }
        let parameters = try self.parseParameters([])
        if kind == .prefix || kind == .postfix
            {
            if parameters.count != 1
                {
                self.cancelCompletion()
                self.dispatchError("A PREFIX or POSTFIX operator must only have a single parameter.")
                }
            }
        else if kind == .infix
            {
            if parameters.count != 2
                {
                self.cancelCompletion()
                self.dispatchError("An INFIX operator must have 2 parameters.")
                }
            }
        if !self.token.isRightArrow
            {
            self.cancelCompletion()
            self.dispatchError("An operator must return a value.")
            }
        try self.nextToken()
        let returnType = try self.parseType()
        var instance: MethodInstance
        if isPrimitive
            {
            instance = PrimitiveMethodInstance(label: operation.name,parameters: parameters,returnType: returnType)
            }
        else
            {
            instance = StandardMethodInstance(label: operation.name,parameters: parameters,returnType: returnType)
            (instance as! StandardMethodInstance).block.addParameters(parameters)
            (instance as! StandardMethodInstance).mergeTemporaryScope(localScope)
            (instance as! StandardMethodInstance).isGenericMethod = isGenericMethod
            }
        var method: Operator
        if let existingOperator = self.currentContext.lookup(label: operation.name) as? Operator
            {
            existingOperator.addInstance(instance)
            method = existingOperator
            }
        else
            {
            if kind == .prefix
                {
                method = PrefixOperator(operation)
                }
            else if kind == .postfix
                {
                method = PostfixOperator(operation)
                }
            else
                {
                method = InfixOperator(operation)
                }
            method.addDeclaration(location)
            method.addInstance(instance)
            if self.currentContext.lookup(label: operation.name).isNotNil
                {
                self.cancelCompletion()
                self.dispatchError(at: location,message: "Duplicate symbol \(operation.name) in this module.")
                }
            else
                {
                self.currentContext.addSymbol(method)
                }
            }
        if !isPrimitive
            {
            try self.parseBraces
                {
                self.pushContext(instance)
                try self.parseBlock(into: (instance as! StandardMethodInstance).block)
                self.popContext()
                }
            }
        if method.hasInstanceWithSameSignature(as: instance)
            {
            self.dispatchWarning(at: location,"There is already an operator with this signature defined.")
            }
        }
    ///
    ///
    /// PRIMITIVES DON'T HANDLE GENERICS YET, FIX IT
    /// 
    private func parsePrimitiveMethod() throws
        {
        try self.nextToken()
        let location = self.token.location
        self.tokenRenderer.setKind(.method,ofToken: self.token)
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
            }
        self.popContext()
        let instance = PrimitiveMethodInstance(label: name,parameters: list,returnType: returnType)
        instance.isGenericMethod = isGenericMethod
        instance.addDeclaration(location)
        var method: Method?
        if existingMethod.isNotNil
            {
            if existingMethod!.hasInstanceWithSameSignature(as: instance)
                {
                self.dispatchWarning(at: location,"There is already a method instance with this signature defined.")
                }
            existingMethod?.addInstance(instance)
            method = existingMethod
            }
        else
            {
            method = Method(label: name)
            method!.isGenericMethod = isGenericMethod
            method!.addDeclaration(location)
            method?.tag = self.currentTag
            self.addSymbol(method!)
            method!.addInstance(instance)
            }
        }
        
    private func parseImport() throws
        {
        let location = self.token.location
        try self.nextToken()
        var path: String = ""
        var moduleLabel: String?
        try self.parseParentheses
            {
            if !self.token.isPathLiteral
                {
                self.dispatchError("Path expected in parentheses after import name.")
                }
            else if self.token.isPathLiteral
                {
                path = Importer.processPath(self.token.pathLiteral)
                moduleLabel = Importer.tryLoadingPath(path,topModule: self.compiler.topModule,reportingContext: self.reportingContext,location: location)
                }
            try self.nextToken()
            }
        var label:Label?
        if self.token.isAs
            {
            try self.nextToken()
            if !self.token.isIdentifier
                {
                self.dispatchWarning(at: location,"An identifier naming the imported module is expected after 'AS'.")
                }
            else
                {
                label = self.token.identifier
                }
            try self.nextToken()
            }
        if moduleLabel.isNil && label.isNil
            {
            self.cancelCompletion()
            self.dispatchError(at: location,"The loading name of the import and the module name in the import can not be ascertained, this import can not be fulfilled.")
            }
        else
            {
            let importLabel = label.isNotNil ? label! : moduleLabel!
            let anImport = Importer(label: importLabel,path: path)
            anImport.loadImportPath(topModule: self.compiler.topModule)
            self.currentContext.addSymbol(anImport)
            }
        }
        
    private func parseInitializer() throws
        {
        let location = self.token.location
        try self.nextToken()
        let label = try self.parseLabel()
        if let theClass = self.currentContext.lookup(label: label) as? Class
            {
            let parameters = try self.parseParameters()
            let initializer = Initializer(label: label)
            initializer.declaringClass = theClass
            initializer.addDeclaration(location)
            initializer.parameters = parameters
            self.pushContext(initializer)
            try parseBraces
                {
                try self.parseBlock(into: initializer.block)
                }
            self.popContext()
            }
        else
            {
            self.dispatchError("Initializer \(label) declaration but the class which should be defined for the initializer is not.")
            }
        }
        
    private func parseInterceptor() throws -> Interceptor
        {
        return(Interceptor(label:"Interceptor",parameters: []))
        }
        
    private func parseScopedSlot() throws -> ScopedSlot
        {
        return(ScopedSlot(label:"Slot",type: self.compiler.argonModule.integer.type))
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
        
    private func parseEnumeration() throws
        {
        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let label = try self.parseLabel()
        let enumeration = Enumeration(label: label)
        enumeration.rawType = self.compiler.argonModule.integer.type
        enumeration.tag = self.currentTag
        self.addSymbol(enumeration)
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
        let methodInstance = StandardMethodInstance(label: "_\(label)",parameters: [Parameter(label: "symbol", type: self.compiler.argonModule.symbol.type, isVisible: false, isVariadic: false)],returnType: .enumeration(enumeration))
        methodInstance.addDeclaration(location)
        let method = Method(label: "_\(label)")
        method.addDeclaration(location)
        method.tag = self.currentTag
        self.addSymbol(method)
        method.addInstance(methodInstance)
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
        
    private func parseCocoonSlot() throws -> Slot
        {
        try self.nextToken()
        self.tokenRenderer.setKind(.classSlot,ofToken: self.token)
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
            else
                {
                self.dispatchError("READ keyword expected.")
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
        var slot: Slot?
        let rawLabel = "_\(label)"
        let aSlot = CocoonSlot(rawLabel: rawLabel,label: label,type: type ?? .class(VoidClass.voidClass))
        aSlot.addDeclaration(location)
        aSlot.writeBlock = writeBlock
        aSlot.readBlock = readBlock
        slot = aSlot
        slot!.initialValue = initialValue
        return(slot!)
        }
        
    private func parseSlot() throws -> Slot
        {
        try self.nextToken()
        self.tokenRenderer.setKind(.classSlot,ofToken: self.token)
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
        
    private func parseClassParameters() throws -> GenericClassParameters
        {
        let typeParameters = try self.parseBrockets
            {
            () throws -> GenericClassParameters in
            var types = GenericClassParameters()
            repeat
                {
                try self.parseComma()
                let name = try self.parseName()
                if let value = self.currentContext.lookup(name: name)
                    {
                    if value.isGenericClassParameter
                        {
                        types.append(value as! GenericClassParameter)
                        }
                    else
                        {
                        self.dispatchError(at: self.token.location,"A concrete type '\(name.displayString) is not valid here.")
                        }
                    }
                else
                    {
                    let type = GenericClassParameter(label: name.last)
                    types.append(type)
                    self.addSymbol(type)
                    }
                }
            while self.token.isComma
            return(types)
            }
        return(typeParameters)
        }
        
    private func parseClassTypes(with parameters: GenericClassParameters) throws -> Types
        {
        let location = self.token.location
        let typeParameters = try self.parseBrockets
            {
            () throws -> Types in
            var types = Types()
            repeat
                {
                try self.parseComma()
                let name = try self.parseName()
                let typeToken = self.token
                if let parm = self.parameter(in: parameters, atName: name)
                    {
                    self.tokenRenderer.setKind(.class, ofToken: typeToken)
                    types.append(.genericClassParameter(parm))
                    }
                else if self.currentContext.lookup(name: name).isNil
                    {
                    self.dispatchError(at: location,"'\(name)' can not be used as a type here unless it is used in the subclass as well.")
                    }
                else if let type = self.currentContext.lookup(name: name)
                    {
                    if let enumeration = type as? Enumeration
                        {
                        self.tokenRenderer.setKind(.enumeration, ofToken: typeToken)
                        types.append(.enumeration(enumeration))
                        }
                    else if let aClass = type as? Class,!aClass.isGenericClassParameter
                        {
                        self.tokenRenderer.setKind(.class, ofToken: typeToken)
                        types.append(.class(aClass))
                        }
                    else if let alias = type as? TypeAlias
                        {
                        self.tokenRenderer.setKind(.type, ofToken: typeToken)
                        types.append(.typeAlias(alias))
                        }
                    else if let method = type as? Method
                        {
                        self.tokenRenderer.setKind(.method, ofToken: typeToken)
                        types.append(.method(method))
                        }
                    else
                        {
                        self.dispatchError(at: location,message: "The type '\(name.displayString)' is not a valid type in this context.")
                        }
                    }
                else
                    {
                    self.dispatchError(at: location,message: "The type '\(name.displayString)' can not be resolved.")
                    }
                }
            while self.token.isComma
            return(types)
            }
        return(typeParameters)
        }
        
    private func parameter(in parms: GenericClassParameters,atName name: Name) -> GenericClassParameter?
        {
        let last = name.last
        for parameter in parms
            {
            if last == parameter.label
                {
                return(parameter)
                }
            }
        return(nil)
        }
        
    @discardableResult
    private func parseClass() throws -> Class
        {
        try self.nextToken()
        let location = self.token.location
        self.tokenRenderer.setKind(.classSlot,ofToken: self.token)
        let label = try self.parseLabel()
        var parameters = GenericClassParameters()
        let existingClass = self.currentContext.lookup(label: label) as? Class
        if self.token.isLeftBrocket
            {
            parameters = try self.parseClassParameters()
            }
        var aClass:Class
        if existingClass.isNotNil
            {
            aClass = existingClass!
            }
        else if parameters.isEmpty
            {
            aClass = Class(label: label)
            }
        else
            {
            aClass = GenericClass(label: label,genericClassParameters: parameters)
            }
        aClass.tag = self.currentTag
        aClass.addDeclaration(location)
        self.addSymbol(aClass)
        self.pushContext(aClass)
        for parameter in parameters
            {
            self.addSymbol(parameter)
            }
        if self.token.isGluon
            {
            aClass.isForwardReferenced = false
            let supers = try self.parseSuperclassReferences(for: aClass, at: location,with: parameters)
            for superclass in supers
                {
                aClass.addSuperclass(superclass)
                }
            }
        if aClass.isSuperclassListEmpty
            {
            aClass.addSuperclass(self.compiler.argonModule.object)
            }
        try self.parseBraces
            {
            while self.token.isSlot || self.token.isClass || self.token.isCocoon
                {
                if self.token.isCocoon
                    {
                    let slot = try self.parseCocoonSlot()
                    aClass.addSymbol(slot)
                    }
                else if self.token.isSlot
                    {
                    let slot = try self.parseSlot()
                    slot.tag = self.currentTag
                    aClass.addSymbol(slot)
                    }
                else if self.token.isClass
                    {
                    if try self.peekToken1().isSlot
                        {
                        let slot = try self.parseClassSlot()
                        aClass.metaclass?.addSymbol(slot)
                        }
                    else
                        {
                        let innerClass = try self.parseClass()
                        }
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
        
    private func parseSuperclassReferences(for aClass:Class,at location: Location,with parameters: GenericClassParameters) throws -> Array<Class>
        {
        var supers = Array<Class>()
        try self.nextToken()
        repeat
            {
            try self.parseComma()
            self.tokenRenderer.setKind(.class,ofToken: self.token)
            let superclassName = try self.parseName()
            let symbol = self.currentContext.lookup(name: superclassName)
            if symbol.isNil
                {
                self.dispatchError(at: location,"'\(superclassName.displayString)' can not be used as a superclass of '\(aClass.label)' because it is not defined in this context.")
                }
            else
                {
                if symbol!.canBecomeAClass
                    {
                    let superclass = symbol!.classValue
                    if superclass.isGenericClass
                        {
                        if let instance = try self.parseGenericClassReference(superclass as! GenericClass,at: location,with: parameters)
                            {
                            supers.append(instance)
                            }
                        }
                    else
                        {
                        supers.append(superclass)
                        }
                    }
                else
                    {
                    self.dispatchError(at: location,"'\(superclassName.displayString)' is not a valid superclass reference in this context.")
                    }
                }
            }
        while self.token.isComma
        return(supers)
        }
        
    private func parseGenericClassReference(_ aClass: GenericClass,at location:Location,with parameters: GenericClassParameters) throws -> GenericClassInstance?
        {
        guard self.token.isLeftBrocket else
            {
            self.dispatchError(at: location,"'<' expected after reference to generic class '\(aClass.label)'.")
            return(nil)
            }
        let types = try self.parseClassTypes(with: parameters)
        let superclass = aClass.instanciate(withTypes: types, reportingContext: self.reportingContext).classValue
        return(superclass as! GenericClassInstance)
        }
        
    @discardableResult
    private func parseConstant() throws -> Constant
        {
        let location = self.token.location
        try self.nextToken()
        self.tokenRenderer.setKind(.constant,ofToken: self.token)
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
        self.addSymbol(constant)
        return(constant)
        }
        
    private func dispatchWarning(at location: Location,_ message:String)
        {
        self.warningCount += 1
        self.reportingContext.dispatchWarning(at: location,message: message)
        }
        
    private func dispatchError(_ message:String)
        {
        self.errorCount += 1
        self.reportingContext.dispatchError(at: self.token.location,message: message)
        }
        
    private func dispatchWarning(_ message:String)
        {
        self.warningCount += 1
        self.reportingContext.dispatchWarning(at: self.token.location,message: message)
        }
        
    private func dispatchError(at location: Location,_ message:String)
        {
        self.errorCount += 1
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
        self.tokenRenderer.setKind(.type,ofToken: self.token)
        let identifierToken = self.token
        if self.token.isIdentifier && self.token.identifier == "String"
            {
            print()
            }
        if self.token.isIdentifier && self.token.isSystemClassName
            {
            self.tokenRenderer.setKind(.type,ofToken: self.token)
            let lastPart = self.token.identifier
            name = Name("\\\\Argon\\" + lastPart)
//            name.topModule = self.compiler.topModule
            }
        else if self.token.isIdentifier
            {
            self.tokenRenderer.setKind(.type,ofToken: self.token)
            name = Name(self.token.identifier)
//            name.topModule = self.compiler.topModule
            }
        else if self.token.isName
            {
            self.tokenRenderer.setKind(.type,ofToken: self.token)
            name = self.token.nameLiteral
//            name.topModule = self.compiler.topModule
            }
        else if self.token.isLeftPar
            {
            return(try self.parseMethodType())
            }
        else
            {
            self.dispatchError(at: location, "A type name was expected but \(self.token) was found.")
            name = Name()
//            name.topModule = self.compiler.topModule
            }
        try self.nextToken()
        if name == Name("\\\\Argon\\Array")
            {
//            name.topModule = self.compiler.topModule
            ///
            ///
            /// At this stage do nothing but at a later stage we need to add
            /// in the parsing of the more exotic array dimensions
            ///
            ///
            }
        let resolvedSymbol = self.currentContext.lookup(name: name)
        if resolvedSymbol.isNil
            {
            self.dispatchError(at: location,"The identifier \(name) could not be resolved, a symbol with that label could not be found.")
            return(Type.class(self.compiler.argonModule.object))
            }
        else
            {
            resolvedSymbol!.addReference(location)
            }
        if resolvedSymbol!.isEnumeration
            {
            self.tokenRenderer.setKind(.enumeration,ofToken: identifierToken)
            return(resolvedSymbol!.asType)
            }
        else if resolvedSymbol!.isTypeAlias
            {
            self.tokenRenderer.setKind(.typeAlias,ofToken: identifierToken)
            return(resolvedSymbol!.asType)
            }
        else if resolvedSymbol!.isClassParameter
            {
            self.tokenRenderer.setKind(.classParameter,ofToken: identifierToken)
            return(resolvedSymbol!.asType)
            }
        let parameters = try self.parseTypeParameters()
        if resolvedSymbol!.isClass
            {
            self.tokenRenderer.setKind(.class,ofToken: identifierToken)
            if resolvedSymbol!.isSystemClass
                {
                self.tokenRenderer.setKind(.systemClass,ofToken: identifierToken)
                }
            var clazz = Type.class(resolvedSymbol as! Class)
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
            self.dispatchError(at: location,"A type was expected but was not found, the identifier '\(name)' was found.")
            try self.nextToken()
            return(.class(self.compiler.argonModule.object))
            }
        }
        
    private func parseMacroDeclaration() throws
        {
        let location = self.token.location
        try self.nextToken()
        let label = try self.parseLabel()
        var parameters = MacroParameters()
        try self.parseParentheses
            {
            repeat
                {
                try self.parseComma()
                let label = try self.parseLabel()
                parameters.append(MacroParameter(label: label))
                }
            while self.token.isComma
            }
        if !self.token.isMacroStart
            {
            self.cancelCompletion()
            self.dispatchError(at: location,message:"Expected macro text start marker '${' but found '\(self.token)'.")
            }
        else
            {
            try self.nextToken()
            }
        if !self.token.isStringLiteral
            {
            self.dispatchWarning(at: location,"Expected macro value but found '\(self.token)'.")
            }
        let text = self.token.stringLiteral
        try self.nextToken()
        if !self.token.isMacroStop
            {
            self.dispatchError(at: location,"Expected macro stop marker '}$' but found '\(self.token)'.")
            }
        try self.nextToken()
        let macro = Macro(label: label, parameters: parameters, text: text)
        self.currentContext.addSymbol(macro)
        }
        
    private func parseMacroInvocation() throws
        {
        guard self.token.isIdentifier else
            {
            return
            }
        let location = self.token.location
        let label = self.token.identifier
        try self.nextToken()
        if let macro = self.currentContext.lookup(label: label) as? Macro
            {
            var elements = Array<Token>()
            try self.parseParentheses
                {
                repeat
                    {
                    try self.parseComma()
                    elements.append(self.token)
                    try self.nextToken()
                    }
                while self.token.isComma
                }
            if elements.count != macro.parameterCount
                {
                self.dispatchWarning(at: location,"Macro '\(label)' expected \(macro.parameterCount) parameters but found '\(elements.count)'.")
                }
            let newText = macro.applyParameters(elements)
            let newStream = TokenStream(source: newText, context: self.reportingContext)
            newStream.lineNumber = self.lineNumber
            self.lineNumber = LineNumber(line: self.token.location.line)
            self.sourceStack.push(self.tokenSource)
            self.tokenSource = newStream
            try self.nextToken()
            }
        else
            {
            self.cancelCompletion()
            self.dispatchError(at: location,"The label '\(label)' is not valid in the current context, it can not be resolved.")
            }
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
        let reference = Type.methodApplication("",types,returnType)
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
                self.tokenRenderer.setKind(.type,ofToken: self.token)
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
        self.tokenRenderer.setKind(.method,ofToken: self.token)
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
                self.dispatchError(at: location, "The multimethod '\(existingMethod!.label)' is defined,but this parameter set is different from the existing one.")
                }
            if returnType != existingMethod!.returnType
                {
                self.cancelCompletion()
                self.dispatchError(at: location,"The multimethod '\(existingMethod!.label)' declared in line \(String(describing: existingMethod!.declaration?.line)) is defined with a return type of '\(existingMethod!.returnType.label)' different from this return type.")
                }
            for (yours,mine) in zip(list,existingMethod!.proxyParameters)
                {
                if yours.tag != mine.tag
                    {
                    self.dispatchError(at: location,"The multimethod '\(existingMethod!.label)' has tag '\(mine.tag)' in the position of '\(yours.tag)', tags must match on multimethod instances.")
                    }
                if yours.isHidden != mine.isHidden
                    {
                    self.dispatchError(at: location,"The multimethod '\(existingMethod!.label)' has tag '\(mine.tag)' which differs in visibility from the tag '\(yours.tag)'.")
                    }
                }
            }
        self.popContext()
        var instance: StandardMethodInstance?
        if directive != .intrinsic
            {
            instance = StandardMethodInstance(label: name,parameters: list,returnType: returnType)
            instance!.isGenericMethod = isGenericMethod
            if isGenericMethod
                {
                instance?.genericParameters = types
                }
            instance!.mergeTemporaryScope(localScope)
            instance!.addDeclaration(location)
            }
        var method: Method?
        if existingMethod.isNotNil
            {
            existingMethod?.addInstance(instance!)
            method = existingMethod
            }
        else
            {
            method = Method(label: name)
            method!.isIntrinsic = directive == .intrinsic
            method!.isGenericMethod = isGenericMethod
            method!.addDeclaration(location)
            method?.tag = self.currentTag
            self.addSymbol(method!)
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
            if returnType != .class(VoidClass.voidClass) && !instance!.block.hasInlineReturnBlock
                {
                self.cancelCompletion()
                self.dispatchError(at: location,"This method has a return value but there is no RETURN statement in the body of the method.")
                }
            }
        if method!.hasInstanceWithSameSignature(as: instance!)
            {
            self.dispatchWarning(at: location,"There is already a method instance with this signature defined.")
            }
        return(method ?? existingMethod!)
        }
        
    private func parseStatements() throws -> Expressions
        {
        return(Expressions())
        }
        
    private func parseExpression() throws -> Expression
        {
        let expression = try self.parseAssignExpression()
        expression.setContext(self.currentContext)
        return(expression)
        }
        
    private func parseAssignExpression() throws -> Expression
        {
        let lhs = try self.parseOperatorExpression()
        if self.token.isAssign
            {
            try self.nextToken()
            let rhs = try self.parseOperatorExpression()
            let expression = AssignmentExpression(lhs,rhs)
            expression.compiler = self.compiler
            return(expression)
            }
        return(lhs)
        }
        
    private func parseOperatorExpression() throws -> Expression
        {
        let location = self.token.location
        var prefixOperator: Operator?
        if self.token.isOperator
            {
            if let operation = self.currentContext.lookup(label: self.token.operator.name) as? PrefixOperator
                {
                prefixOperator = operation
                }
            else
                {
                self.cancelCompletion()
                self.dispatchError("Prefix operator '\(self.token.operator.name)' found but that operator can not be resolved.")
                }
            try self.nextToken()
            }
        var expression = try self.parseParenthesisExpression()
        expression = prefixOperator.isNil ? expression : PrefixExpression(operation: prefixOperator!,rhs: expression)
        var postfixOperator: Operator?
        if self.token.isOperator
            {
            if let operation = self.currentContext.lookup(label: self.token.operator.name) as? PostfixOperator
                {
                postfixOperator = operation
                }
            else
                {
                self.cancelCompletion()
                self.dispatchError("Postfix operator '\(self.token.operator.name)' found but that operator can not be resolved.")
                }
            try self.nextToken()
            }
        expression = postfixOperator.isNil ? expression : PostfixExpression(operation: postfixOperator!,lhs: expression)
        expression.compiler = self.compiler
        expression.addDeclaration(location)
        return(expression)
        }
        
        
    private func parseParenthesisExpression() throws -> Expression
        {
        let expression = try self.parseSlotExpression()
        if self.token.isLeftPar && expression.isLiteralExpression
            {
            let literal = expression as! LiteralExpression
            if literal.isMethodLiteral || literal.isClassLiteral
                {
                let arguments = try self.parseParentheses
                    {
                    try self.parseArguments()
                    }
                if literal.isMethodLiteral
                    {
                    let method = literal.methodLiteral
                    return(MethodInvocationExpression(method: method, arguments: arguments))
                    }
                else
                    {
                    let aClass = literal.classLiteral
                    return(ClassInstanciationTerm(type: aClass, arguments: arguments))
                    }
                }
            }
        return(expression)
        }
        
//    private func parseAssociatedValues(with lhs: Expression) throws -> Expression
//        {
//        let theCase = lhs.enumerationCase
//        try self.nextToken()
//        if theCase.associatedTypes.isEmpty
//            {
//            self.reportingContext.dispatchError(at: self.token.location, message: "The case '\(theCase.label)' does not have any associated values.")
//            }
//        var values = Array<Expression>()
//        var index = 0
//        while index < theCase.associatedTypes.count && !self.token.isRightPar
//            {
//            values.append(try self.parseExpression())
//            try self.parseComma()
//            index += 1
//            }
//        if !self.token.isRightPar
//            {
//            self.reportingContext.dispatchError(at: self.token.location, message: "A ')' was expected after the associated values for '\(theCase.label)' but it was not found.")
//            }
//        try self.nextToken()
//        return(EnumerationInstanceExpression(caseLabel: theCase.label,enumeration: theCase.enumeration, enumerationCase: theCase, associatedValues: values))
//        }
        
    private func parseSlotExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseIncDecExpression()
        lhs.addDeclaration(location)
        while self.token.isRightArrow
            {
            try self.nextToken()
            if !(self.token.isIdentifier || self.token.isHashStringLiteral)
                {
                self.cancelCompletion()
                self.dispatchError("Slot selector expected but '\(self.token)' was found.")
                }
            else
                {
                let selector = self.token.isIdentifier ? self.token.identifier : self.token.hashStringLiteral
                lhs.compiler = self.compiler
                if let symbol = lhs.lookup(label: selector)
                    {
                    if symbol.isLiteral
                        {
                        lhs = symbol.asLiteralExpression!
                        }
                    else
                        {
                        lhs = SlotAccessExpression(lhs,slot: symbol)
                        }
                    }
                else
                    {
                    lhs = SlotAccessExpression(lhs,selector: selector)
                    self.dispatchWarning("The slot at selector '\(selector)' can not be resolved, so the type of this expression can not be resolved.")
                    }
                }
            try self.nextToken()
            if lhs.isEnumerationCaseExpression && lhs.enumerationCase.hasAssociatedTypes && self.token.isLeftPar
                {
                lhs = try self.parseAssociatedTypes(in: lhs)
                }
            }
        lhs.compiler = self.compiler
        return(lhs)
        }
        
    private func parseAssociatedTypes(in expression: Expression) throws -> Expression
        {
        let aCase = expression.enumerationCase
        let types = aCase.associatedTypes
        var values = Expressions()
        var isInducing = false
        var variableNames = Array<String>()
        try self.parseParentheses
            {
            repeat
                {
                try self.parseComma()
                if self.token.isIdentifier && isInducing
                    {
                    variableNames.append(self.token.identifier)
                    try self.nextToken()
                    }
                else if self.token.isIdentifier && self.currentContext.lookup(label: self.token.identifier).isNil
                    {
                    isInducing = true
                    variableNames.append(self.token.identifier)
                    try self.nextToken()
                    }
                else
                    {
                    values.append(try self.parseExpression())
                    }
                }
            while self.token.isComma
            }
        if isInducing
            {
            let newLeft = AssociatedValueInductionExpression(expression,variableNames)
            for slot in newLeft.slots
                {
                self.addSymbol(slot)
                }
            if newLeft.enumerationCase.associatedTypes.count != newLeft.slots.count
                {
                fatalError()
                }
            return(newLeft)
            }
        if values.count != types.count
            {
            self.cancelCompletion()
            self.dispatchError("The enumeration case \(aCase.label) expected \(types.count) associated values be found \(values.count).")
            }
        return(EnumerationInstanceExpression(lhs: expression,enumerationCase: aCase,associatedValues: values))
        }
        
    private func parseIncDecExpression() throws -> Expression
        {
        let location = self.token.location
        let expression = try self.parseIndexedExpression()
        expression.addDeclaration(location)
        if self.token.isPlusPlus || self.token.isMinusMinus
            {
            let symbol = self.token.operator
            try self.nextToken()
            return(SuffixExpression(expression,symbol))
            }
        expression.compiler = self.compiler
        return(expression)
        }

    private func parseIndexedExpression() throws -> Expression
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
        lhs.compiler = self.compiler
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
        lhs.compiler = self.compiler
        return(lhs)
        }
        
    private func parseComparisonExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseInfixExpression()
        lhs.addDeclaration(location)
        if self.token.isLeftBrocket || self.token.isLeftBrocketEquals || self.token.isEquals || self.token.isRightBrocket || self.token.isRightBrocketEquals || self.token.isNotEquals
            {
            let symbol = self.token.symbol
            try self.nextToken()
            let rhs = try self.parseInfixExpression()
            rhs.compiler = self.compiler
            lhs = lhs.operation(symbol,rhs)
            lhs.compiler = self.compiler
            return(lhs)
            }
        lhs.compiler = self.compiler
        return(lhs)
        }
        
    private func parseInfixExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseArithmeticExpression()
        lhs.addDeclaration(location)
        while self.token.isOperator && (self.currentContext.lookup(label: self.token.operator.name) as? InfixOperator).isNotNil
            {
            let operation = self.currentContext.lookup(label: self.token.operator.name) as! InfixOperator
            try self.nextToken()
            let rhs = try self.parseArithmeticExpression()
            rhs.compiler = self.compiler
            lhs = InfixExpression(operation: operation,lhs: lhs,rhs: rhs)
            }
        lhs.compiler = self.compiler
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
            let rhs = try self.parseMultiplicativeExpression()
            rhs.compiler = self.compiler
            lhs = lhs.operation(symbol,rhs)
            }
        lhs.compiler = self.compiler
        return(lhs)
        }
        
    private func parseMultiplicativeExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parsePowerExpression()
        lhs.addDeclaration(location)
        while self.token.isMul || self.token.isDiv || self.token.isModulus
            {
            let symbol = token.symbol
            try self.nextToken()
            let rhs = try self.parsePowerExpression()
            rhs.compiler = self.compiler
            lhs = lhs.operation(symbol,rhs)
            }
        lhs.compiler = self.compiler
        return(lhs)
        }
        
    private func parsePowerExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseBitExpression()
        lhs.addDeclaration(location)
        while self.token.isPower
            {
            let symbol = token.symbol
            try self.nextToken()
            let rhs = try self.parseBitExpression()
            rhs.compiler = self.compiler
            lhs = lhs.operation(symbol,rhs)
            }
        lhs.compiler = self.compiler
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
            let rhs = try self.parseUnaryExpression()
            rhs.compiler = self.compiler
            lhs = lhs.operation(symbol,rhs)
            }
        lhs.compiler = self.compiler
        return(lhs)
        }
        
    private func parseUnaryExpression() throws -> Expression
        {
        if self.token.isSub || self.token.isBitNot || self.token.isNot || self.token.isBitAnd || self.token.isMul
            {
            let symbol = self.token.symbol
            try self.nextToken()
            return(try self.parsePrimary().unary(symbol))
            }
        else
            {
            let location = self.token.location
            let term = try self.parsePrimary()
            term.addDeclaration(location)
            term.compiler = self.compiler
            return(term)
            }
        }
        
    private func parseGeneratorSet() throws -> Expression
        {
        fatalError()
        ///
        ///
        ///
        /// Define variables | define constraints
        /// Commas separate variables and constraints
        /// One loop through set, then freeze variables for iteration one
        /// then another loop through etc until terminates
        }
        
    private func parseGenerativeVariables() -> Array<Label>
        {
        return([])
        }
        
    private func parsePrimary() throws -> Expression
        {
        if self.token.isRole
            {
            try self.nextToken()
            let result = try self.parseParentheses
                {
                () -> RoleExpression in
                let expression = try self.parseExpression()
                try self.parseComma()
                let type = try self.parseType()
                return(RoleExpression(expression: expression,type: type))
                }
            return(result)
            }
        else if self.token.isLeftBracket
            {
            return(try self.parseGeneratorSet())
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
        else if self.token.isScope
            {
            return(try self.parseEnumerationCaseExpression())
            }
        else if self.token.isLeftBracket
            {
            try self.nextToken()
            let expression = try self.parseExpression()
            if expression.isUnresolved
                {
                let tuple = DestructuringExpression()
                tuple.isArrayDestructure = true
                if self.token.isComma
                    {
                    while self.token.isComma
                        {
                        try self.parseComma()
                        tuple.append(try self.parseExpression())
                        }
                    }
                if self.token.isRightBracket
                    {
                    try self.nextToken()
                    }
                else
                    {
                    self.dispatchWarning("']' expected after destructing tuple.")
                    }
                return(tuple)
                }
            else if self.token.isComma && expression.isLiteralExpression
                {
                var array = Array<Literal>()
                expression.compiler = self.compiler
                array.append((expression as! LiteralExpression).literal)
                while self.token.isComma
                    {
                    try self.parseComma()
                    let expr = try self.parseExpression()
                    expr.compiler = self.compiler
                    if expr.isLiteralExpression
                        {
                        array.append((expr as! LiteralExpression).literal)
                        }
                    else
                        {
                        self.dispatchError("A literal value was expected as part of the literal array.")
                        return(LiteralExpression(.array(array)))
                        }
                    }
                if self.token.isRightBracket
                    {
                    try self.nextToken()
                    }
                else
                    {
                    self.dispatchWarning("']' expected after array literal.")
                    }
                return(LiteralExpression(.array(array)))
                }
            return(expression)
            }
        else if self.token.isLeftPar
            {
            return(try self.parseParentheses
                {
                let expression = try self.parseExpression()
                if self.token.isComma
                    {
                    let tuple = DestructuringExpression()
                    tuple.append(expression)
                    while self.token.isComma
                        {
                        try self.parseComma()
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
        else if self.token.isSelf
            {
            try self.nextToken()
            return(PseudoVariableExpression(.vSelf))
            }
        else if self.token.isSELF
            {
            try self.nextToken()
            return(PseudoVariableExpression(.vSELF))
            }
        else if self.token.isSuper
            {
            try self.nextToken()
            return(PseudoVariableExpression(.vSuper))
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
//        try self.nextToken()
//        if !self.token.isIdentifier
//            {
//            self.reportingContext.dispatchError(at: self.token.location, message: "When a gluon is used to begin an enumeration case, it must be followed by an identifier.")
//            try self.nextToken()
//            return(Expression())
//            }
//        self.tokenRenderer.setKind(.enumeration,ofToken: self.token)
//        let theCaseKey = self.token.identifier
//        try self.nextToken()
//        return(EnumerationInstanceExpression(caseLabel: theCaseKey,enumeration: nil, enumerationCase: nil, associatedValues: nil))
        fatalError()
        }
        
    private func parseSlotSelectorExpression() throws -> Expression
        {
        self.tokenRenderer.setKind(.classSlot,ofToken: self.token)
        let location = self.token.location
        let first = try self.parseLabel()
        let lhs = SlotSelectorExpression(selector: first)
        lhs.addDeclaration(location)
        return(lhs)
        }
        
    private func parseIdentifierTerm() throws -> Expression
        {
        let location = self.token.location
        let nameToken = self.token
        let name = try self.parseName()
        let aSymbol = self.currentContext.lookup(name: name)
//        print(aSymbol?.label)
        if let symbol = aSymbol as? Enumeration
            {
            self.tokenRenderer.setKind(.enumeration,ofToken: nameToken)
            return(LiteralExpression(.enumeration(symbol)))
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
                self.tokenRenderer.setKind(.class,ofToken: nameToken)
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
        else if aSymbol is LocalSlot || aSymbol is Parameter
            {
            let read = SlotExpression(slot: aSymbol as! Slot)
            read.addReference(location)
            return(read)
            }
        else if let symbol = aSymbol as? Importer
            {
            let expression = ImportExpression(import:symbol)
            expression.addDeclaration(location)
            return(expression)
            }
        else if let symbol = aSymbol as? Method
            {
            if self.token.isLeftPar
                {
                self.tokenRenderer.setKind(.methodInvocation,ofToken: nameToken)
                return(try self.parseMethodInvocationTerm(symbol))
                }
            return(LiteralExpression(.method(symbol)))
            }
        else if let symbol = aSymbol as? Function
            {
            if self.token.isLeftPar
                {
                self.tokenRenderer.setKind(.methodInvocation,ofToken: nameToken)
                return(try self.parseFunctionInvocationTerm(symbol))
                }
            return(LiteralExpression(.function(symbol)))
            }
        else if self.token.isLeftPar
            {
            let arguments = try parseParentheses
                {
                try self.parseArguments()
                }
            return(InvocationExpression(name: name,arguments: arguments,location: location))
            }
        else
            {
            let localSlot = LocalSlot(label: name.last,type: .unknown,value: nil)
            let term = SlotExpression(slot: localSlot)
            localSlot.addDeclaration(location)
            term.addDeclaration(location)
            return(term)
            }
        }
        
    private func parseClosureTerm() throws -> Expression
        {
        let closure = Closure(label: Argon.nextName("1_CLOSURE"))
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
                try self.parseBlock(into: closure.block)
                }
            }
        closure.addDeclaration(location)
        return(ClosureExpression(closure))
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
        
    private func parseMethodInvocationTerm(_ method: Method) throws -> Expression
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
        
    private func parseFunctionInvocationTerm(_ function: Function) throws -> Expression
        {
        let location = self.token.location
        let args = try self.parseParentheses
            {
            try self.parseArguments()
            }
        let expression = FunctionInvocationExpression(function: function,arguments: args)
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
            else if self.token.isPrimitive
                {
                try self.parsePrimitiveBlock(into: block)
                }
            else if self.token.isLet
                {
                try self.parseLetBlock(into: block)
                }
            else if self.token.isSelf || self.token.isSELF || self.token.isSuper
                {
                block.addBlock(ExpressionBlock(try self.parseExpression()))
                }
            else
                {
                self.dispatchError("A statement was expected but \(self.token) was found.")
                try self.nextToken()
                }
            }
        }
        
    private func parsePrimitiveBlock(into block: Block) throws
        {
        try self.nextToken()
        var name = ""
        try self.parseParentheses
            {
            name = try self.parseLabel()
            }
        block.addBlock(PrimitiveBlock(primitiveName: name))
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
        if self.token.isElseIf
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
        let expression = try self.parseExpression()
        let statement = LetBlock(location: location,expression: expression)
        for slot in expression.assignedSlots
            {
            self.addSymbol(slot)
            }
        expression.setParent(statement)
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
//        var variableName: Label?
//        var closure: Expression?
        try self.parseParentheses
            {
            if self.token.isIdentifier
                {
//                variableName = self.token.identifier
                }
            else if self.token.isLeftBrace
                {
                _ = try self.parseExpression()
                }
            else
                {
                self.cancelCompletion()
                self.dispatchError(at: location,"A closure or a variable containing a closure was expected in a fork block.")
                }
            }
//        try self.parseInductionVariable()
//        let statement = ForBlock(name: variableName)
//        statement.addDeclaration(location)
//        try self.parseBlock(into: statement)
//        block.addBlock(statement)
//        self.stopClip(into: statement)
        }
        
    private var textStart: Int = 0
    
    private func startClip()
        {
        self.textStart = self.token.location.tokenStart
        }
        
    private func stopClip(into block: Block)
        {
        let stop = self.token.location.tokenStop
        if self.source.isNotNil
            {
            block.source = self.source!.substring(with: self.textStart..<stop + 1)
            }
        }
        
    private func stopClip(into symbol: Symbol)
        {
        let stop = self.token.location.tokenStop
        if self.source.isNotNil
            {
            symbol.source = self.source!.substring(with: self.textStart..<stop + 1)
            }
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
            end = try self.parseExpression()
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
        let location = self.token.location
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
        expression.addDeclaration(location)
        let stop = self.token.location.tokenStop
        let newBlock = ExpressionBlock(expression)
        newBlock.source = self.source?.substring(with: start..<stop + 1) ?? ""
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
        var relabel:Label? = nil
        if !self.token.isGluon
            {
            relabel = try self.parseLabel()
            }
        try self.parseGluon()
        let type = try self.parseType()
        var isVariadic = false
        if self.token.isFullRange
            {
            try self.nextToken()
            isVariadic = true
            }
        let parameter = Parameter(label: tag, relabel: relabel,type: type,isVisible: isHidden,isVariadic: isVariadic)
        parameter.addDeclaration(location)
        return(parameter)
        }
        
    @discardableResult
    private func parseFunction() throws -> Function
        {
        try self.nextToken()
        let location = self.token.location
        self.tokenRenderer.setKind(.function,ofToken: self.token)
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
        self.addSymbol(function)
        return(function)
        }
        
    @discardableResult
    private func parseTypeAlias() throws -> TypeAlias
        {
        try self.nextToken()
        let location = self.token.location
        self.tokenRenderer.setKind(.type,ofToken: self.token)
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
        self.addSymbol(alias)
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
                handler.addParameter(label: name,type: self.compiler.argonModule.symbol.type)
                try self.nextToken()
                }
            try self.parseBlock(into: handler)
            }
        self.popContext()
        let stop = self.token.location.tokenStop
        handler.source = self.source?.substring(with: start..<stop + 1) ?? ""
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
