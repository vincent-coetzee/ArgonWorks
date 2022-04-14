//
//  Parser.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/9/21.
//

import Foundation

public class IncrementalParser: CompilerPass
    {
    private var enclosingModule: Module
        {
        self.topSymbol.enclosingModule
        }
        
    private var enclosingMethodInstance: MethodInstance
        {
        self.currentScope.enclosingMethodInstance
        }
        
    private var errors = CompilerError()
    internal var token:Token = Token(location: .zero)
    internal var lastToken:Token = Token(location: .zero)
    private var source: String?
    public var wasCancelled = false
//    private var isParsingLValue = false
    internal var tokenSource: TokenSource!
    internal var currentScope: Scope!
    internal var scopeStack = Stack<Scope>()
    private var statics = Array<StaticObject>()
    internal var tokenHandler: TokenHandler?
    private var symbolStack = Stack<Symbol>()
    private var itemKey: Int = -1
    internal var argonModule: ArgonModule!
    internal var topModule: TopModule!
        {
        didSet
            {
            self.currentScope = self.topModule
            }
        }
    
    private var topSymbol: Symbol
        {
        self.symbolStack.top!
        }
    internal var tokenKind: TokenKind = .none
        {
        didSet
            {
            self.tokenHandler?.kindChanged(token: self.token)
            }
        }

    private func pushSymbol(_ symbol: Symbol)
        {
        self.symbolStack.push(symbol)
        }
        
    private func popSymbol()
        {
        self.symbolStack.pop()
        }
        
    private func setToken(_ aToken: Token,kind: TokenKind)
        {
        aToken.kind = kind
        self.tokenHandler?.kindChanged(token: aToken)
        }
        
    init(_ compiler:Compiler)
        {
//        self.tokenRenderer = compiler.tokenRenderer
//        self.compiler = compiler
        self.initParser(source: compiler.source)
        }
        
    init(tokens: Tokens)
        {
//        self.tokenRenderer = compiler.tokenRenderer
//        self.compiler = compiler
        self.initParser(tokens: tokens)
        }
        
    init()
        {
        self.initParser(tokens: [])
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
        self.tokenHandler?.kindChanged(token: self.lastToken)
        self.token = self.tokenSource.nextToken()
        self.tokenHandler?.kindChanged(token: self.token)
        print(self.token.displayString)
        return(self.token)
        }
        
    private func commonInit()
        {
        }
        
    public func registerStaticString(_ string: Argon.String) -> StaticString
        {
        let staticString = StaticString(string: string)
        self.statics.append(staticString)
        return(staticString)
        }
        
    public func registerStaticSymbol(_ string: Argon.Symbol) -> StaticSymbol
        {
        fatalError()
        }
        
    private func lookup(label: Label) -> Symbol?
        {
        self.currentScope.lookup(label: label)
        }
        
//    private func lookup(name: Name) -> Symbol?
//        {
//        self.currentScope.lookup(name: name)
//        }
        
    private func appendIssue(at: Location,message: String)
        {
        self.topSymbol.appendIssue(at: at,message: message)
        }
        
    internal func pushContext(_ scope: Scope)
        {
        self.scopeStack.push(self.currentScope)
        self.currentScope = scope
        }
        
    internal func popContext()
        {
        self.currentScope = self.scopeStack.pop()
        }
        
    internal func addSymbol(_ symbol: Symbol)
        {
        self.currentScope.addSymbol(symbol)
        }
        
    private func peekToken1() throws -> Token
        {
        return(self.tokenSource.peekToken(count: 1))
        }

    private func peekToken0() throws -> Token
        {
        return(self.tokenSource.peekToken(count: 0))
        }
    
    private func initParser(tokens: Tokens)
        {
        self.source = nil
        self.tokenSource = TokenHolder(tokens: tokens)
        self.commonInit()
//        self.reportingContext = self.compiler.reportingContext
        }
    
    private func initParser(source: String)
        {
        self.source = source
        self.tokenSource = TokenStream(source: source,withComments: false)
        self.commonInit()
//        self.reportingContext = self.compiler.reportingContext
        }
        
    public func processModule(_ module: Module?) -> Module?
        {
        do
            {
//            self.warningCount = 0
//            self.errorCount = 0
            let first = self.token
            try self.nextToken()
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
                first.appendIssue(at: self.token.location, message: "KEYWORD expected.")
                return(nil)
                }
            if self.token.isKeyword
                {
                let module = try self.parseModule()
                return(module)
                }
            }
        catch
            {
            }
        return(nil)
        }
        
    @discardableResult
    public func parseSource(_ source:String) -> Module?
        {
        self.initParser(source: source)
        return(self.processModule(nil))
        }
        
    @discardableResult
    public func parseTokens(_ tokens: Tokens) -> Module?
        {
        self.initParser(tokens: tokens)
        return(self.processModule(nil))
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
            self.topSymbol.appendIssue(at: self.token.location,message: "An identifier was expected here but \(self.token) was found.")
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
            self.token.appendIssue(at: self.token.location,message: "A name was expected here but \(self.token) was found.")
        return(Name("error"))
        }
        
    internal func parseBraces<T>(_ closure: () throws -> T) throws -> T
        {
        if !self.token.isLeftBrace
            {
            self.topSymbol.appendIssue(at: self.token.location, message: "'{' expected but a '\(self.token)' was found.")
            }
        else
            {
            try self.nextToken()
            }
        let result = try closure()
        if !self.token.isRightBrace
            {
            self.topSymbol.appendIssue(at: self.token.location, message: "'}' expected but a '\(self.token)' was found.")
            }
        else
            {
            try self.nextToken()
            }
        return(result)
        }

    private func parseMainMethod() throws
        {
        try self.nextToken()
        let value = self.parseMethodInstance()
        if case let SymbolValue.methodInstance(instance) = value
            {
            instance.isMainMethod = true
            }
        }
        
    private func parseMainModule() throws -> Module
        {
        try self.nextToken()
        let label = try self.parseLabel()
        let module = MainModule(label: label)
        self.addSymbol(module)
        try self.parseModule(into: module)
        return(module)
        }
    
    private func parsePath() throws -> Token
        {
//        if self.token.isPathLiteral
//            {
//            self.tokenRenderer.setKind(.path,ofToken: self.token)
//            try self.nextToken()
//            return(self.lastToken)
//            }
//        self.appendIssue(at: self.token.location,message: "Path expected for a library module but \(self.token) was found.")
//        return(.path("",Location.zero))
        fatalError()
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
    internal func parseModule() throws -> Module
        {
        let location = self.token.location
        try self.nextToken()
        let first = self.token
        self.tokenKind = .module
        let name = try self.parseLabel()
        var module = self.lookup(label: name) as? Module
        var isNew = false
        let path: String? = nil
//        if self.token.isLeftPar
//            {
//            try self.parseParentheses
//                {
//                path = try self.parsePath().pathLiteral
//                }
//            }
        if module.isNil
            {
            isNew = true
            if path.isNotNil
                {
                module = LibraryModule(label: name,path: path!)
                }
            else
                {
                module = Module(label: name)
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
                    first.appendIssue(at: location,message: "A module named '\(name)' was found, but it was used as a library module and it is a module")
                    }
                }
//            module?.appendIssue(at: location,message:"A module named '\(name.string)' already exists, its contents may be overwritten.",isWarning: true)
            }
        if isNew
            {
//            if name.count == 1
//                {
                self.addSymbol(module!)
//                }
//            else
//                {
//                (self.currentScope.lookup(name: name) as? Scope)?.addSymbol(module!)
//                }
            module?.addDeclaration(itemKey: self.itemKey,location: location)
            }
        else
            {
            module?.addReference(location)
            }
        try self.parseModule(into: module!)
        return(module!)
        }
        
//    public func parseSymbol(from source: String,in module: Module) throws -> Symbol?
//        {
//        self.scopeStack = Stack<Scope>()
//        self.pushSymbol(CompilationContext(module: module))
//        self.tokenSource = TokenHolder(tokens:TokenStream(source: source, withComments: true).allTokens(withComments: true))
//        self.commonInit()
//        self.token = Token(location: .one)
//        try self.nextToken()
//        do
//            {
//            if !self.token.isKeyword
//                {
//                throw(CompilerError("Keyword expected."))
//                }
//            else
//                {
//                switch(self.token.keyword)
//                    {
//                    case .MODULE:
//                        try self.parseModule(into: module)
//                    case .CLASS:
//                        self.parseClass()
//                    case .METHOD:
//                        try self.parseMethodInstance()
//                    case .PRIMITIVE:
//                        try self.parsePrimitiveMethod()
//                    case .TYPE:
//                        try self.parseTypeAlias()
//                    case .MAIN:
//                        try self.parseMainMethod()
//                    case .SLOT:
//                        let slot = try self.parseSlot()
//                        module.addSymbol(slot)
//                    default:
//                        self.token.appendIssue(at: self.token.location,message: "\(self.token.keyword) is not a valid keyword in this position.")
//                    }
//                }
//            }
//        catch let error as CompilerError
//            {
//            self.popSymbol()
//            throw(error)
//            }
//        catch
//            {
//            self.popSymbol()
//            throw(CompilerError("Unknown error"))
//            }
//        self.popSymbol()
//        return(nil)
//        }
        
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
//                _ = try self.parsePrivacyScope()
//                try self.parseMacroInvocation()
                if !self.token.isKeyword
                    {
                    self.token.appendIssue(at: self.token.location, message: "Keyword expected but \(self.token) found.")
                    try self.nextToken()
                    }
                else
                    {
//                    if self.token.isMainDirective
//                        {
//                        try self.nextToken()
//                        }
                    if !self.token.isKeyword
                        {
                        return
                        }
                    switch(self.token.keyword)
                        {
//                        case .PREFIX:
//                            try self.parseOperator(.prefix)
//                        case .INFIX:
//                            try self.parseOperator(.infix)
//                        case .POSTFIX:
//                            try self.parseOperator(.postfix)
//                        case .MACRO:
//                            try self.parseMacroDeclaration()
                        case .IMPORT:
                            try self.parseImport()
                        case .FUNCTION:
                            try self.parseFunction()
                        case .MAIN:
                            try self.parseMainMethod()
                        case .MODULE:
                            try self.parseModule()
                        case .CLASS:
                            self.parseClass()
                        case .TYPE:
                            self.parseTypeAlias()
                        case .PRIMITIVE:
                            try self.parsePrimitiveMethod()
                        case .METHOD:
                            self.parseMethodInstance()
                        case .CONSTANT:
                            try self.parseConstant()
                        case .SCOPED:
                            let scoped = try self.parseScopedSlot()
                            module.addSymbol(scoped)
                        case .ENUMERATION:
                            self.parseEnumeration()
                        case .SLOT:
                            let slot = try self.parseSlot(.moduleSlot)
                            module.addSymbol(slot)
                        case .INTERCEPTOR:
                            let interceptor = try self.parseInterceptor()
                            module.addSymbol(interceptor)
                        default:token.appendIssue(at: self.token.location, message: "A declaration for a module element was expected but \(self.token) was found.")
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
        
    private func parseForBlock(into block:Block) throws
        {
        let location = self.token.location
        try self.nextToken()
        var slot:LocalSlot = LocalSlot(label: "", type: TypeContext.freshTypeVariable(), value: nil)
        var elements:Expression = Expression()
        try self.parseParentheses
            {
            var label:Label = ""
            if !self.token.isIdentifier
                {
                self.cancelCompletion()
                self.topSymbol.appendIssue(at: location,message: "Identifier expected in first part of FOR statement.")
                }
            else
                {
                label = try self.parseLabel()
                }
            if self.token.isGluon
                {
                try self.nextToken()
                let type = try self.parseType()
                slot = LocalSlot(label: label, type: type,value: nil)
                }
            else
                {
                slot = LocalSlot(label: label, type: TypeContext.freshTypeVariable(), value: nil)
                }
            try self.parseComma()
            elements = try self.parseExpression()
            }
        let forBlock = ForBlock(inductionSlot: slot,elements: elements)
        forBlock.addLocalSlot(slot)
        forBlock.addDeclaration(itemKey: self.itemKey,location: location)
        block.addBlock(forBlock)
        self.pushContext(forBlock)
        try self.parseBraces
            {
            try self.parseBlock(into: forBlock)
            }
        self.popContext()
        }
        
    ///
    ///
    /// PRIMITIVES DON'T HANDLE GENERICS YET, FIX IT
    ///
    @discardableResult
    internal func parsePrimitiveMethod() throws -> MethodInstance
        {
        try self.nextToken()
        let location = self.token.location
        var index: Argon.Integer = 0
        try self.parseParentheses
            {
            if !self.token.isIntegerLiteral
                {
                self.cancelCompletion()
                self.token.appendIssue(at: location,message:  "A PRIMITIVE index was expected after the PRIMITIVE keyword.")
                }
            else
                {
                index = self.token.integerLiteral
                }
            try self.nextToken()
            }
        let nameToken = self.token
        let name = try self.parseLabel()
        let instance = PrimitiveMethodInstance(label: name)
        instance.setModule(self.enclosingModule)
        self.pushContext(instance)
        if let method = self.currentScope.lookupMethod(label: name)
            {
            method.addMethodInstance(instance)
            }
        else
            {
            let method = Method(label: name)
            self.enclosingModule.addSymbol(method)
            method.addMethodInstance(instance)
            }
//        let existingMethod = self.currentScope.lookup(label: name) as? Method
        var isGenericMethod = false
        var types: Types = []
        if self.token.isLeftBrocket
            {
            types = try self.parseMethodGenericParameters()
            instance.addTemporaries(types)
            isGenericMethod = true
            }
        instance.parameters = try self.parseParameters()
        instance.returnType = self.argonModule.void
        if self.token.isRightArrow
            {
            try self.nextToken()
            instance.returnType = try self.parseType()
            }
        instance.primitiveIndex = index
        instance.isGenericMethod = isGenericMethod
        instance.addDeclaration(itemKey: self.itemKey,location: location)
        if let instances = self.currentScope.lookupMethodInstances(label: instance.label)
            {
            for methodInstance in instances
                {
                if methodInstance.methodSignature == instance.methodSignature
                    {
                    self.token.appendIssue(at: location,message: "There is already a primitive instance with this signature defined.",isWarning: true)
                    }
                }
            }
        self.setToken(nameToken,kind: .method)
        self.popContext()
        return(instance)
        }
        
    private func parseImport() throws
        {
        let location = self.token.location
        try self.nextToken()
        let firstToken = self.token
        var path: String = ""
        var moduleLabel: String?
        var issues = CompilerIssues()
        try self.parseParentheses
            {
            if !self.token.isPathLiteral
                {
                issues.appendIssue(at: location,message: "Path expected in parentheses after import name.")
                }
            else if self.token.isPathLiteral
                {
                path = Importer.processPath(self.token.pathLiteral)
                moduleLabel = Importer.tryLoadingPath(path,topModule: self.topModule,location: location)
                }
            try self.nextToken()
            }
        var label:Label?
        if self.token.isAs
            {
            try self.nextToken()
            if !self.token.isIdentifier
                {
                issues.appendIssue(at: location,message: "An identifier naming the imported module is expected after 'AS'.")
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
            issues.appendIssue(at: location,message: "The loading name of the import and the module name in the import can not be ascertained, this import can not be fulfilled.")
            }
        else
            {
            let importLabel = label.isNotNil ? label! : moduleLabel!
            let anImport = Importer(label: importLabel,path: path)
            anImport.loadImportPath(topModule: self.topModule)
            firstToken.appendIssues(issues)
            self.currentScope.addSymbol(anImport)
            }
        }
        
//    private func parseInitializer(in type:Type) throws
//        {
//        let location = self.token.location
//        try self.nextToken()
//        let parameters = try self.parseParameters()
//        let initializer = Initializer(label: type.label)
//        initializer.type = type
//        initializer.parameters = parameters
//        let aClass = (type as! TypeClass).theClass
//        aClass.addInitializer(initializer)
//        initializer.declaringType = type
//        initializer.addDeclaration(itemKey: self.itemKey,location: location)
//        self.pushContext(initializer)
//        try parseBraces
//            {
//            self.pushContext(initializer.block)
//            try self.parseBlock(into: initializer.block)
//            self.popContext()
//            }
//        self.popContext()
//        }
        
    private func parseInterceptor() throws -> Interceptor
        {
        return(Interceptor(label:"Interceptor",parameters: []))
        }
        
    private func parseScopedSlot() throws -> ScopedSlot
        {
        return(ScopedSlot(label:"Slot",type: self.argonModule.integer.type))
        }
        
    private func parseHashString() throws -> String
        {
        if self.token.isSymbolLiteral
            {
            let string = self.token.symbolLiteral.string
            try self.nextToken()
            return(string)
            }
        try self.nextToken()
        self.topSymbol.appendIssue(at: self.token.location, message: "A symbol was expected but \(self.token) was found.")
        try self.nextToken()
        return("#HashString")
        }
        
    @discardableResult
    internal func parseEnumeration() -> SymbolValue
        {
        do
            {
            try self.nextToken()
            let location = self.token.location
            let type = TypeEnumeration(label: "",generics: [])
            type.setModule(self.topSymbol as! Module)
            self.pushSymbol(type)
            defer
                {
                self.popSymbol()
                }
            type.setLabel(try self.parseLabel())
            if self.topSymbol.lookup(label: type.label).isNotNil
                {
                type.appendIssue(at: self.token.location,message: "There is already a symbol with label '\(type.label)' defined.")
                }
            var rawType = self.argonModule.integer
            type.addDeclaration(itemKey: self.itemKey,location: location)
            if self.token.isGluon
                {
                try self.nextToken()
                let type = try self.parseType()
                rawType = type
                }
            try self.parseBraces
                {
                () throws -> Void in
                var caseIndex = 0
                while self.token.isSymbolLiteral
                    {
                    let aCase = self.parseCase(into: type)
                    aCase.caseIndex = caseIndex
                    aCase.enumeration = type
                    caseIndex += 1
                    }
                }
            type.rawType = rawType
            type.itemKey = self.itemKey
            return(.enumeration(type))
            }
        catch
            {
            return(.error([CompilerIssue(location: self.token.location,message: "Unexpected end of source.")]))
            }
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
            literal = LiteralExpression(.string(Argon.addStatic(StaticString(string: self.token.stringLiteral.string))))
            }
        else if self.token.isSymbolLiteral
            {
            literal = LiteralExpression(.symbol(Argon.addStatic(StaticSymbol(string: self.token.symbolLiteral.string))))
            }
        else
            {
            literal = LiteralExpression(.integer(0))
            self.token.appendIssue(at: self.token.location, message: "Integer, String or Symbol literal expected for rawValue of ENUMERATIONCASE")
            }
        try self.nextToken()
        return(literal)
        }
        
    private func parseCase(into enumeration: TypeEnumeration) -> EnumerationCase
        {
        if !self.token.isSymbolLiteral
            {
            self.topSymbol.appendIssue(at: self.token.location,message: "Symbol expected in enumeration case.")
            return(EnumerationCase(label: ""))
            }
        do
            {
            let location = self.token.location
            let name = try self.parseHashString()
            if enumeration.case(forSymbol: name).isNotNil
                {
                enumeration.appendIssue(at: location, message: "There is already a case with label '\(name)'.")
                }
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
            enumeration.addCase(aCase)
            aCase.addDeclaration(itemKey: self.itemKey,location: location)
            if self.token.isAssign
                {
                try self.nextToken()
                aCase.rawValue = try self.parseLiteral()
                }
            return(aCase)
            }
        catch
            {
            self.topSymbol.appendIssue(at: self.token.location,message: "Unexpected end of source.")
            return(EnumerationCase(label: ""))
            }
        }
        
//    private func parseCocoonSlot() throws -> Slot
//        {
//        try self.nextToken()
//        self.tokenRenderer.setKind(.classSlot,ofToken: self.token)
//        let location = self.token.location
//        let label = try self.parseLabel()
//        var type: Type?
//        var issues = CompilerIssues()
//        if self.token.isGluon
//            {
//            try self.nextToken()
//            type = try self.parseType(&issues)
//            }
//        var initialValue:Expression?
//        if self.token.isAssign
//            {
//            try self.nextToken()
//            initialValue = try self.parseExpression()
//            }
//        var readBlock:VirtualReadBlock?
//        var writeBlock:VirtualWriteBlock?
//        try self.parseBraces
//            {
//            if self.token.isRead
//                {
//                try self.nextToken()
//                readBlock = VirtualReadBlock()
//                try self.parseBraces
//                    {
//                    try self.parseBlock(into: readBlock!)
//                    }
//                }
//            else
//                {
//                issues.appendIssue(at: location,message: "READ keyword expected.")
//                }
//            if self.token.isWrite
//                {
//                var variableLabel: String = "newValue"
//                try self.nextToken()
//                if self.token.isLeftPar
//                    {
//                    try self.parseParentheses
//                        {
//                        variableLabel = try self.parseLabel()
//                        }
//                    }
//                writeBlock = VirtualWriteBlock()
//                writeBlock!.newValueSlot = LocalSlot(label: variableLabel)
//                try self.parseBraces
//                    {
//                    writeBlock!.addLocalSlot(writeBlock!.newValueSlot as! LocalSlot)
//                    try self.parseBlock(into: writeBlock!)
//                    }
//                }
//            }
//        var slot: Slot?
//        let rawLabel = "_\(label)"
//        let aSlot = CocoonSlot(rawLabel: rawLabel,label: label,type: type ?? self.argonModule.void)
//        aSlot.addDeclaration(itemKey: self.itemKey,location: location)
//        aSlot.writeBlock = writeBlock
//        aSlot.readBlock = readBlock
//        slot = aSlot
//        slot!.initialValue = initialValue
//        slot?.appendIssues(issues)
//        return(slot!)
//        }
        
    internal enum SlotType
        {
        case instanceSlot
//        case cocoonSlot
        case classSlot
        case moduleSlot
        
        public func newSlot(label:Label) -> Slot
            {
            switch(self)
                {
                case .instanceSlot:
                    return(InstanceSlot(label: label))
//                case .cocoonSlot:
//                    return(CocoonSlot(label: label))
                case .classSlot:
                    return(ClassSlot(label: label))
                case .moduleSlot:
                    return(ModuleSlot(label: label))
                }
            }
        }
        
    internal func parseSlot(_ slotType: SlotType = .instanceSlot) throws -> Slot
        {
        try self.nextToken()
        self.tokenKind = .instanceSlot
        let location = self.token.location
        let labelToken = self.token
        let label = try self.parseLabel()
        var type: Type?
        var typeWasDeclared = false
        if self.token.isGluon
            {
            try self.nextToken()
            type = try self.parseType()
            typeWasDeclared = true
            }
        let slot = slotType.newSlot(label: label)
        slot.type = type.isNil ? self.argonModule.integer : type!
        slot.addDeclaration(itemKey: self.itemKey,location: location)
        while self.token.isComma
            {
            try self.parseComma()
            let theToken = self.token
            try self.nextToken()
            if !self.token.isGluon
                {
                self.topSymbol.appendIssue(at: location,message: "'::' was expected after SLOT specializer.")
                }
            try self.nextToken()
            if !self.token.isSymbolLiteral
                {
                self.topSymbol.appendIssue(at: location,message: "A symbol selector was expected.")
                }
            if slotType == .instanceSlot
                {
                if theToken.isInitializer
                    {
                    (slot as! InstanceSlot).slotInitializerSelector = self.token.symbolLiteral
                    }
                else if theToken.isMandatory
                    {
                    (slot as! InstanceSlot).slotMandatorySelector = self.token.symbolLiteral
                    }
                else
                    {
                    self.topSymbol.appendIssue(at: location,message: "'\(theToken.displayString)' is not a valid SLOT specializer.")
                    }
                }
            try self.nextToken()
            }
        var wasInitialValue = false
        if self.token.isAssign
            {
            try self.nextToken()
            slot.initialValue = try self.parseExpression()
            wasInitialValue = true
            }
        if !typeWasDeclared && !wasInitialValue
            {
            self.topSymbol.appendIssue(at: location,message: "Either the slot type must be declared or the slot must be given an initial value.")
            }
        if slotType == .instanceSlot
            {
            self.setToken(labelToken,kind: .instanceSlot)
            }
        else if slotType == .classSlot
            {
            self.setToken(labelToken,kind: .classSlot)
            }
        else if slotType == .moduleSlot
            {
            self.setToken(labelToken,kind: .moduleSlot)
            }
        return(slot)
        }
        
    internal func parseModuleSlot() throws -> Slot
        {
        try self.nextToken()
        let slot = try self.parseSlot(.moduleSlot)
        return(slot)
        }
        
    private func parseClassSlot() throws -> Slot
        {
        try self.nextToken()
        let slot = try self.parseSlot(.classSlot)
        return(slot)
        }
        
    private func parseGenericTypes() throws -> Types
        {
        let typeParameters = try self.parseBrockets
            {
            () throws -> Types in
            var types = Types()
            repeat
                {
                try self.parseComma()
                let name = try self.parseLabel()
                if let value = self.currentScope.lookupType(label: name)
                    {
                    types.append(value)
                    }
                else
                    {
                    let type = TypeContext.freshTypeVariable(named: name)
                    types.append(type)
                    self.addSymbol(type)
                    }
                }
            while self.token.isComma
            return(types)
            }
        return(typeParameters)
        }
        
//    private func parseClassTypes(with parameters: Types,issues:inout CompilerIssues) throws -> Types
//        {
//        let location = self.token.location
//        let typeParameters = try self.parseBrockets
//            {
//            () throws -> Types in
//            var types = Types()
//            repeat
//                {
//                try self.parseComma()
//                let name = try self.parseName()
//                let typeToken = self.token
//                if let parm = self.parameter(in: parameters, atName: name)
//                    {
//                    self.tokenRenderer.setKind(.class, ofToken: typeToken)
//                    types.append(parm)
//                    }
//                else if self.currentScope.lookup(name: name).isNil
//                    {
//                    issues.appendIssue(at: location,message: "'\(name)' can not be used as a type here unless it is used in the subclass as well.")
//                    }
//                else if let type = self.currentScope.lookup(name: name)
//                    {
//                    if let enumeration = type as? Enumeration
//                        {
//                        self.tokenRenderer.setKind(.enumeration, ofToken: typeToken)
//                        types.append(enumeration.type!)
//                        }
//                    else if let aClass = type as? Class,!aClass.isGenericType
//                        {
//                        self.tokenRenderer.setKind(.class, ofToken: typeToken)
//                        types.append(aClass.type!)
//                        }
//                    else if let alias = type as? TypeAlias
//                        {
//                        self.tokenRenderer.setKind(.type, ofToken: typeToken)
//                        types.append(alias.type!)
//                        }
//                    else if let method = type as? Method
//                        {
//                        fatalError("\(method)")
//                        }
//                    else
//                        {
//                        self.dispatchError(at: location,message: "The type '\(name.displayString)' is not a valid type in this context.")
//                        }
//                    }
//                else
//                    {
//                    self.dispatchError(at: location,message: "The type '\(name.displayString)' can not be resolved.")
//                    }
//                }
//            while self.token.isComma
//            return(types)
//            }
//        return(typeParameters)
//        }
        
    private func parameter(in parms: Types,atName name: Name) -> Type?
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
    internal func parseClass() -> SymbolValue
        {
        do
            {
            try self.nextToken()
            let location = self.token.location
            self.tokenKind = .classSlot
            let label = try self.parseLabel()
            var typeParameters = Types()
            var classExists = false
            var aClass = TypeClass(label: "")
            classExists = (self.topSymbol.lookup(label: label) as? TypeClass).isNotNil
            if self.token.isLeftBrocket
                {
                typeParameters = try self.parseGenericTypes()
                }
            aClass = TypeClass(label: label,generics: typeParameters)
            if classExists
                {
                aClass.appendIssue(at: location,message: "A class with label '\(label)' is already defined.")
                }
            aClass.setModule(self.topSymbol as! Module)
            self.pushSymbol(aClass)
            defer
                {
                self.popSymbol()
                }
            aClass.addDeclaration(itemKey: self.itemKey,location: location)
            if !classExists
                {
                self.enclosingModule.addSymbol(aClass)
                aClass.makeMetaclass()
                aClass.configureMetaclass(argonModule: self.argonModule)
                }
            if self.token.isGluon
                {
                try self.nextToken()
                repeat
                    {
                    try self.parseComma()
                    let aSuper = try self.parseType()
                    if let superClass = aSuper as? TypeClass
                        {
                        if superClass.superclassHierarchy.contains(aClass)
                            {
                            aClass.appendIssue(at: self.token.location,message: "'\(superClass.label)' is an ancestor of '\(label)' therefore it can not be added as a superclass of '\(label)'.")
                            }
                        else
                            {
                            aClass.addSuperclassWithoutUpdatingSuperclass(superClass)
                            }
                        }
                    else
                        {
                        self.appendIssue(at: self.token.location,message: "'\(aSuper.label)' is not a class and can therefore not be a superclass of '\(label)'.")
                        }
                    }
                while self.token.isComma
                }
            if aClass.superclasses.isEmpty
                {
                aClass.addSuperclassWithoutUpdatingSuperclass(self.argonModule.object)
                }
            try self.parseBraces
                {
                if !self.token.isClass && !self.token.isSlot && !self.token.isRightBrace
                    {
                    aClass.appendIssue(at: self.token.location,message: "'CLASS' or 'SLOT' or '}' expected but \(token) was found.")
                    }
                while self.token.isSlot || self.token.isClass
                    {
                    if self.token.isSlot
                        {
                        let slot = try self.parseSlot()
                        if aClass.allInstanceSlotsContainsSlotWithLabel(slot.label)
                            {
                            aClass.appendIssue(at: self.lastToken.location,message: "'\(label)' can not have a slot labeled '\(slot.label)' because it inherits one with that label.")
                            }
                        else
                            {
                            aClass.addInstanceSlot(slot as! InstanceSlot)
                            }
                        }
                    else if self.token.isClass
                        {
                        if try self.peekToken1().isSlot
                            {
                            let slot = try self.parseClassSlot()
                            let someType = aClass.type as! TypeClass
                            if someType.allInstanceSlotsContainsSlotWithLabel(slot.label)
                                {
                                aClass.appendIssue(at: self.lastToken.location,message: "'\(someType.label)' can not have a slot labeled '\(slot.label)' because it inherits one with that label.")
                                }
                            else
                                {
                                // these are class slots but class slots are actually instance slots on
                                // the metaclass ( i.e. the class of this class ).
                                someType.addInstanceSlot(slot as! InstanceSlot)
                                }
                            }
                        else
                            {
    //                        let innerClass = try self.parseClass()
    //                        innerClass.isInnerClass = true
                            fatalError("Need to handle type parameters for inner classes")
    //                        let innerType = Argon.addType(TypeClass(class: innerClass,generics: []))
    //                        aClass.addSymbol(innerType)
                            }
                        }
                    }
                if !self.token.isRightBrace
                    {
                    aClass.appendIssue(at: self.token.location,message: "'}' expected but '\(self.token)' was found.")
                    }
                }
            aClass.layoutObjectSlots()
//            aClass.metaclass.layoutObjectSlots()
            aClass.itemKey = self.itemKey
            return(.class(aClass))
            }
        catch
            {
            return(.error([CompilerIssue(location: self.token.location,message: "Unexpected end of source.")]))
            }
        }
        
    private func parseSuperclassReferences() throws -> Array<Type>
        {
        var supers = Array<Type>()
        try self.nextToken()
        repeat
            {
            try self.parseComma()
            self.tokenKind = .class
            let type = try self.parseType()
            supers.append(type)
            }
        while self.token.isComma
        return(supers)
        }
        
//    private func parseGenericClassReference(_ aClass: GenericClass,at location:Location,with parameters: Types) throws -> GenericClass?
//        {
//        guard self.token.isLeftBrocket else
//            {
//            self.dispatchError(at: location,"'<' expected after reference to generic class '\(aClass.label)'.")
//            return(nil)
//            }
//        let types = try self.parseClassTypes(with: parameters)
//        let superclass = aClass.instanciate(withTypes: types, reportingContext: self.reportingContext).classValue
//        return(superclass as! GenericClass)
//        }
        
    @discardableResult
    private func parseConstant() throws -> Constant
        {
        let location = self.token.location
        try self.nextToken()
        self.tokenKind = .constant
        let label = try self.parseLabel()
        var type:Type = self.currentScope.lookup(label: "Void") as! Type
        if self.token.isGluon
            {
            try self.parseGluon()
            type = try self.parseType()
            }
        if !self.token.isAssign
            {
            self.token.appendIssue(at: self.token.location, message: "'=' expected to follow the declaration of a CONSTANT.")
            }
        try self.nextToken()
        let value = try self.parseExpression()
        let constant = Constant(label: label,type: type,value: value)
        constant.addDeclaration(itemKey: self.itemKey,location: location)
        self.addSymbol(constant)
        return(constant)
        }
        
//    private func dispatchWarning(at location: Location,_ message:String)
//        {
//        self.warningCount += 1
//        self.reportingContext.dispatchWarning(at: location,message: message)
//        }
//
//    private func dispatchError(_ message:String)
//        {
//        self.errorCount += 1
//        self.reportingContext.dispatchError(at: self.token.location,message: message)
//        }
//
//    private func dispatchWarning(_ message:String)
//        {
//        self.warningCount += 1
//        self.reportingContext.dispatchWarning(at: self.token.location,message: message)
//        }
//
//    private func dispatchError(at location: Location,_ message:String)
//        {
//        self.errorCount += 1
//        self.reportingContext.dispatchError(at: location,message: message)
//        }
        
    internal func parseParentheses<T>(_ closure: () throws -> T)  throws -> T
        {
        if !self.token.isLeftPar
            {
            self.token.appendIssue(at: self.token.location,message: "'(' was expected but \(self.token) was found.")
            }
        else
            {
            try self.nextToken()
            }
        let value = try closure()
        if !self.token.isRightPar
            {
            self.token.appendIssue(at: self.token.location,message: "')' was expected but \(self.token) was found.")
            }
        else
            {
            try self.nextToken()
            }
        return(value)
        }
        
    internal func parseBrackets<T>(_ closure: () throws -> T)  throws -> T
        {
        if !self.token.isLeftBracket
            {
            self.token.appendIssue(at: self.token.location,message: "'[' was expected but \(self.token) was found.")
            }
        else
            {
            try self.nextToken()
            }
        let value = try closure()
        if !self.token.isRightBracket
            {
            self.token.appendIssue(at: self.token.location,message: "']' was expected but \(self.token) was found.")
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
            self.token.appendIssue(at: self.token.location,message: "'::' was expected but '\(self.token)' was found.")
            }
        else
            {
            try self.nextToken()
            }
        }
        
    private func parseType() throws -> Type
        {
        let location = self.token.location
        let nameToken = self.token
        if self.token.isLeftPar
            {
            return(try self.parseFunctionType())
            }
        self.tokenKind = .type
        var name = ""
        if self.token.isIdentifier
            {
            name = self.token.identifier
            }
        if self.token.isIdentifier && self.token.isSystemClassName
            {
            self.tokenKind = .systemClass
            }
        else if self.token.isIdentifier
            {
            self.tokenKind = .type
            }
        else
            {
            let type = self.argonModule.void
            self.topSymbol.appendIssue(at: location, message: "A type name was expected but \(self.token) was found.")
            return(type)
            }
        try self.nextToken()
        guard var type = self.topSymbol.lookupType(label: name) else
            {
            let typeVariable = TypeContext.freshTypeVariable()
            typeVariable.setLabel(name)
            self.topSymbol.appendIssue(at: location,message: "The identifier \(name) could not be resolved, a type with that label could not be found.")
            return(typeVariable)
            }
        type.addReference(itemKey: self.itemKey,location:  location)
        if type.isTypeAlias
            {
            self.tokenKind = .typeAlias
            return(self.enclosingModule.matchingTypeOrType(type).type)
            }
        else if type.isTypeVariable
            {
            self.tokenKind = .genericClassParameter
            return(type)
            }
        let parameters = try self.parseTypeArguments()
        ///
        ///
        /// Need to modify this code to handle generic enumerations as well. In it's
        /// current form it only handles generic classes.
        ///
        ///
        if type.isEnumeration
            {
            self.tokenKind = .enumeration
            return(self.enclosingModule.matchingTypeOrType(type))
            }
        if type.isClass
            {
            self.tokenKind = .class
            self.setToken(nameToken,kind: .class)
            }
        if type.isSystemClass
            {
            self.tokenKind = .systemClass
            self.setToken(nameToken,kind: .systemClass)
            }
        if type.isClass
            {
            if !parameters.isEmpty
                {
                let newType = type.withGenerics(parameters)
                newType.setModule(self.enclosingModule)
                type = newType
                }
            if type.isSetClass
                {
                self.validateSetRequirements(forElementType: parameters[0],atToken: nameToken)
                }
            type = self.enclosingModule.matchingTypeOrType(type)
            type.addReference(itemKey: self.itemKey,location: location)
            return(type)
            }
        else
            {
            self.topSymbol.appendIssue(at: location,message: "A type was expected but the identifier '\(name)' was found instead.")
            try self.nextToken()
            return(self.argonModule.object)
            }
        }
        
    private func validateSetRequirements(forElementType aType: Type,atToken: Token)
        {
        guard let method = self.currentScope.lookupMethod(label: "hash") else
            {
            let lowerName = aType.label.lowercased()
            let methodName = "hash(=\(lowerName)::\(aType.label)) -> Integer"
            atToken.appendIssue(at: atToken.location,message: "This specialization of Set requires a method '\(methodName)' to function correctly.")
            self.cancelCompletion()
            return
            }
        guard method.instanceWithTypes([aType],returnType: self.argonModule.integer).isNotNil else
            {
            let lowerName = aType.label.lowercased()
            let methodName = "hash(=\(lowerName)::\(aType.label)) -> Integer"
            atToken.appendIssue(at: atToken.location,message: "This specialization of Set requires a method '\(methodName)' to function correctly.")
            self.cancelCompletion()
            return
            }
        }
//    private func parseMacroDeclaration() throws
//        {
//        let location = self.token.location
//        try self.nextToken()
//        let label = try self.parseLabel()
//        var parameters = MacroParameters()
//        var issues = CompilerIssues()
//        try self.parseParentheses
//            {
//            repeat
//                {
//                try self.parseComma()
//                let label = try self.parseLabel()
//                parameters.append(MacroParameter(label: label))
//                }
//            while self.token.isComma
//            }
//        if !self.token.isMacroStart
//            {
//            self.cancelCompletion()
//            issues.appendIssue(at: location,message:"Expected macro text start marker '${' but found '\(self.token)'.")
//            }
//        else
//            {
//            try self.nextToken()
//            }
//        if !self.token.isStringLiteral
//            {
//            issues.appendIssue(at: location,message: "Expected macro value but found '\(self.token)'.")
//            }
//        let text = self.token.stringLiteral
//        try self.nextToken()
//        if !self.token.isMacroStop
//            {
//            issues.appendIssue(at: location,message: "Expected macro stop marker '}$' but found '\(self.token)'.")
//            }
//        try self.nextToken()
//        let macro = Macro(label: label, parameters: parameters, text: text)
//        macro.appendIssues(issues)
//        self.currentScope.addSymbol(macro)
//        }
        
    private func parseMacroInvocation() throws
        {
//        guard self.token.isIdentifier else
//            {
//            return
//            }
//        let location = self.token.location
//        let label = self.token.identifier
//        try self.nextToken()
//        if let macro = self.currentScope.lookup(label: label) as? Macro
//            {
//            var elements = Array<Token>()
//            try self.parseParentheses
//                {
//                repeat
//                    {
//                    try self.parseComma()
//                    elements.append(self.token)
//                    try self.nextToken()
//                    }
//                while self.token.isComma
//                }
//            if elements.count != macro.parameterCount
//                {
//                macro.appendIssue(at: location,message: "Macro '\(label)' expected \(macro.parameterCount) parameters but found '\(elements.count)'.",isWarning: true)
//                }
//            let newText = macro.applyParameters(elements)
//            let newStream = TokenStream(source: newText, context: self.reportingContext)
//            newStream.lineNumber = self.lineNumber
//            self.lineNumber = LineNumber(line: self.token.location.line)
//            self.sourceStack.push(self.tokenSource)
//            self.tokenSource = newStream
//            try self.nextToken()
//            }
//        else
//            {
//            self.cancelCompletion()
//            self.currentScope.appendIssue(at: location,message:"The label '\(label)' is not valid in the current context, it can not be resolved.")
//            }
        }
        
    private func parseFunctionType() throws -> Type
        {
        let location = self.token.location
        let types = try self.parseParentheses
            {
            () throws -> Types in
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
            self.cancelCompletion()
            self.token.appendIssue(at: location, message: "'->' was expected in a method reference type but '\(self.token)' was found.")
            }
        try self.nextToken()
        let type = TypeFunction(label: "FunctionType",types: types, returnType: try self.parseType())
        return(type)
        }
        
    private func parseTypeArguments() throws -> Types
        {
        if self.token.isLeftBrocket
            {
            let list = try self.parseBrockets
                {
                () throws -> Types in
                var list = Types()
                repeat
                    {
                    try self.parseComma()
                    list.append(try self.parseType())
                    }
                while self.token.isComma
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
            self.token.appendIssue(at: self.token.location,message: "'<' was expected but \(self.token) was found.")
            }
        let value = try closure()
        if self.token.isRightBrocket
            {
            try self.nextToken()
            }
        else
            {
            self.token.appendIssue(at: self.token.location,message:"'>' was expected but \(self.token) was found.")
            }
        return(value)
        }
        
    private func parseParameters(_ localTypes: Types? = nil) throws -> Parameters
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
        
    private func parseMethodGenericParameters() throws -> Types
        {
        var parameters = Types()
        try self.parseBrockets
            {
            repeat
                {
                try self.parseComma()
                self.tokenKind = .genericClassParameter
                let label = try self.parseLabel()
                let typeVariable = TypeContext.freshTypeVariable()
                typeVariable.setLabel(label)
                parameters.append(typeVariable)
                }
            while self.token.isComma
            }
        return(parameters)
        }
        
    @discardableResult
    internal func parseMethodInstance() -> SymbolValue
        {
        do
            {
            try self.nextToken()
            let location = self.token.location
            let nameToken = self.token
            let label = try self.parseLabel()
            let instance = StandardMethodInstance(label: label,argonModule: self.argonModule)
            var isGenericMethod = false
            instance.setModule(self.enclosingModule)
            self.pushSymbol(instance)
            defer
                {
                self.popSymbol()
                }
            var types: Types = []
            if self.token.isLeftBrocket
                {
                types = try self.parseMethodGenericParameters()
                instance.addTemporaries(types)
                isGenericMethod = true
                }
            instance.parameters = try self.parseParameters()
            for parameter in instance.parameters
                {
                instance.block.addParameterSlot(parameter)
                }
            instance.returnType = self.argonModule.void
            if self.token.isRightArrow
                {
                try self.nextToken()
                instance.returnType = try self.parseType()
                }
            if isGenericMethod
                {
                instance.isGenericMethod = true
                }
            instance.addDeclaration(itemKey: self.itemKey,location: location)
            if let method = self.topSymbol.lookupMethod(label: instance.label)
                {
                for anInstance in method.methodInstances.without(instance)
                    {
                    if anInstance.methodSignature == instance.methodSignature
                        {
                        if !anInstance.isAutoGenerated
                            {
                            instance.appendIssue(at: location,message: "There is already a method instance with this signature defined.",isWarning: true)
                            }
                        }
                    }
                }
            try self.parseBraces
                {
                self.pushContext(instance.block)
                try self.parseBlock(into: instance.block)
                self.popContext()
                }
            if instance.returnType != self.argonModule.void && !instance.block.hasInlineReturnBlock
                {
                self.cancelCompletion()
                instance.appendIssue(at: location,message: "This method has a return value but there is no RETURN statement in the body of the method.")
                }
            self.setToken(nameToken,kind: .method)
            instance.itemKey = self.itemKey
            return(.methodInstance(instance))
            }
        catch
            {
            return(.error([CompilerIssue(location: self.token.location,message: "Unexpected end of source.")]))
            }
        }
        
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                                                                                                                               ///
    ///                                                                                                                                               ///
    /// PARSE EXPRESSIONS INTO EXPRESSION OBJECTS                                                                                                     ///
    ///                                                                                                                                               ///
    ///                                                                                                                                               ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///
    
    private func parseAssignmentExpression() throws -> Expression
        {
        var lhs = try self.parseExpression()
        if self.token.isAssignmentOperator
            {
            let operation = self.token.operatorString
            try self.nextToken()
            let rhs = try self.parseExpression()
            if operation == "="
                {
                lhs = AssignmentExpression(lhs, rhs)
                }
            else
                {
                lhs = AssignmentOperatorExpression(lhs, operation, rhs)
                }
            }
        return(lhs)
        }
        
    private func parseExpression() throws -> Expression
        {
        return(try self.parseTypingExpression())
        }
        
    public func parseTypingExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseTernaryExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        if self.token.isTester
            {
            try self.nextToken()
            let aType = try self.parseType()
            lhs = TypeTestingExpression(lhs: lhs,rhs: aType)
            }
        else if self.token.isCast
            {
            try self.nextToken()
            let aType = try self.parseType()
            lhs = CastExpression(lhs: lhs,rhs: aType)
            }
        return(lhs)
        }
        
    private func parseTernaryExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseBooleanExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        if self.token.isTernary
            {
            try self.nextToken()
            let mhs = try self.parseBooleanExpression()
            if self.token.isColon
                {
                try self.nextToken()
                let rhs = try self.parseBooleanExpression()
                lhs = TernaryExpression(lhs: lhs,mhs: mhs,rhs: rhs)
                }
            }
        return(lhs)
        }
        
    private func parseBooleanExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseComparisonExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        while self.token.isAnd || self.token.isOr
            {
            let symbol = token.operatorString
            try self.nextToken()
            lhs = BooleanExpression(lhs,symbol,try self.parseComparisonExpression())
            lhs.addDeclaration(itemKey: self.itemKey,location: location)
            }
        return(lhs)
        }
        
    private func parseComparisonExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseArithmeticExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        if self.token.isLeftBrocket || self.token.isLeftBrocketEquals || self.token.isEquals || self.token.isRightBrocket || self.token.isRightBrocketEquals || self.token.isNotEquals
            {
            let symbol = self.token.operatorString
            try self.nextToken()
            let rhs = try self.parseArithmeticExpression()
            lhs = ComparisonExpression(lhs, symbol, rhs)
            lhs.addDeclaration(itemKey: self.itemKey,location: location)
            return(lhs)
            }
        return(lhs)
        }
        
    private func parseArithmeticExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseMultiplicativeExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        while self.token.isAdd || self.token.isSub
            {
            let symbol = token.operatorString
            try self.nextToken()
            let rhs = try self.parseMultiplicativeExpression()
            let binary = BinaryExpression(lhs, symbol, rhs)
            if let instances = self.currentScope.lookupN(label: symbol) as? MethodInstances
                {
                binary.methodInstances = instances
                }
            lhs = binary
            lhs.addDeclaration(itemKey: self.itemKey,location: location)
            }
        return(lhs)
        }
        
    private func parseMultiplicativeExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parsePowerExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        while self.token.isMul || self.token.isDiv || self.token.isModulus
            {
            let symbol = token.operatorString
            try self.nextToken()
            let rhs = try self.parsePowerExpression()
            let binary = BinaryExpression(lhs, symbol, rhs)
            if let instances = self.currentScope.lookupN(label: symbol) as? MethodInstances
                {
                binary.methodInstances = instances
                }
            lhs = binary
            lhs.addDeclaration(itemKey: self.itemKey,location: location)
            }
        return(lhs)
        }
        
    private func parsePowerExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseBitExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        while self.token.isPower
            {
            let symbol = token.operatorString
            try self.nextToken()
            let rhs = try self.parseBitExpression()
            let binary = BinaryExpression(lhs, symbol, rhs)
            if let instances = self.currentScope.lookupN(label: symbol) as? MethodInstances
                {
                binary.methodInstances = instances
                }
            lhs = binary
            lhs.addDeclaration(itemKey: self.itemKey,location: location)
            }
        return(lhs)
        }
        
    private func parseBitExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseSlotExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        while self.token.isBitAnd || self.token.isBitOr || self.token.isBitXor
            {
            let symbol = token.operatorString
            try self.nextToken()
            let rhs = try self.parseSlotExpression()
            let binary = BinaryExpression(lhs, symbol, rhs)
            if let instances = self.currentScope.lookupN(label: symbol) as? MethodInstances
                {
                binary.methodInstances = instances
                }
            lhs = binary
            lhs.addDeclaration(itemKey: self.itemKey,location: location)
            }
        return(lhs)
        }
        
    private func parseSlotExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseUnaryExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        while self.token.isSymbolLiteral
            {
            let selector = self.token.symbolLiteral.string
            try self.nextToken()
            let accessor = SlotAccessExpression(lhs,slotLabel: selector)
            lhs = accessor
            }
        return(lhs)
        }
        
    private func parseUnaryExpression() throws -> Expression
        {
        if self.token.isSub || self.token.isBitNot || self.token.isNot || self.token.isBitAnd || self.token.isMul
            {
            let symbol = self.token.operatorString
            try self.nextToken()
            return(UnaryExpression(symbol,try self.parsePostfixExpression()))
            }
        else
            {
            let location = self.token.location
            let term = try self.parsePostfixExpression()
            term.addDeclaration(itemKey: self.itemKey,location: location)
            return(term)
            }
        }
        
    private func parsePostfixExpression() throws -> Expression
        {
        var lhs = try self.parseIndexedExpression()
        if self.token.isPlusPlus || self.token.isMinusMinus
            {
            let operation = self.token.operatorString
            try self.nextToken()
            if let instances = self.currentScope.lookupMethodInstances(label: operation)
                {
                lhs = PostfixExpression(operatorLabel: operation, operators: instances, lhs: lhs)
                }
            else
                {
                self.topSymbol.appendIssue(at: self.token.location,message: "Method '\(operation)' can not be resolved.")
                }
            }
        return(lhs)
        }
        
    private func parseIndexedExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parsePrimaryExpression()
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        while self.token.isLeftBracket
            {
            try self.nextToken()
            let rhs = try self.parsePrimaryExpression()
            if !self.token.isRightBracket
                {
                self.topSymbol.appendIssue(at: location,message: "']' expected but \(self.token) was found.")
                }
            try self.nextToken()
            lhs = ArrayAccessExpression(array: lhs,index: rhs)
            }
        return(lhs)
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
        
    private func parseArrayLiteral() throws -> Expression
        {
        let location = self.token.location
        try self.nextToken()
        var elements = Array<Literal>()
        repeat
            {
            if !self.token.isRightBracket
                {
                try self.parseComma()
                let expression = try self.parseExpression()
                if !expression.isLiteralExpression
                    {
                    self.cancelCompletion()
                    self.topSymbol.appendIssue(CompilerIssue(location: location,message: "A literal expression was expected."))
                    }
                else
                    {
                    elements.append((expression as! LiteralExpression).literal)
                    }
                }
            }
        while self.token.isComma
        if !self.token.isRightBracket
            {
            self.cancelCompletion()
            self.topSymbol.appendIssue(CompilerIssue(location: location,message: "']' expected to terminate array literal."))
            }
        try self.nextToken()
        return(LiteralExpression(.array(Argon.addStatic(StaticArray(elements)))))
        }
        
    private func parsePrimaryExpression() throws -> Expression
        {
        if self.token.isMake
            {
            try self.nextToken()
            let expression = try self.parseParentheses
                {
                () -> MakeTerm in
                let type = try self.parseType()
                var args = Arguments()
                while !self.token.isRightPar
                    {
                    try self.parseComma()
                    args.append(try self.parseArgument())
                    }
                let make = MakeTerm(type: type,arguments: args)
                return(make)
                }
            return(expression)
            }
        else if self.token.isDateLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.date(self.lastToken.dateLiteral)))
            }
        else if self.token.isIntegerLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.integer(self.lastToken.integerLiteral)))
            }
        else if self.token.isFloatLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.float(self.lastToken.floatLiteral)))
            }
        else if self.token.isStringLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.string(self.lastToken.stringLiteral)))
            }
        else if self.token.isSymbolLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.symbol(self.lastToken.symbolLiteral)))
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
        else if self.token.isLeftBracket
            {
//            let location = self.token.location
            try self.nextToken()
            let expression = try self.parseExpression()
//            if expression.isUnresolved
//                {
//                let tuple = TupleExpression()
//                tuple.isArrayDestructure = true
//                if self.token.isComma
//                    {
//                    while self.token.isComma
//                        {
//                        try self.parseComma()
//                        tuple.append(try self.parseExpression())
//                        }
//                    }
//                if self.token.isRightBracket
//                    {
//                    try self.nextToken()
//                    }
//                else
//                    {
//                    self.token.appendIssue(at: location,message: "']' expected after destructing tuple.",isWarning: true)
//                    }
//                return(tuple)
//                }
//            else if self.token.isComma && expression.isLiteralExpression
//                {
//                var array = Array<Literal>()
//                array.append((expression as! LiteralExpression).literal)
//                while self.token.isComma
//                    {
//                    try self.parseComma()
//                    let expr = try self.parseExpression()
//                    if expr.isLiteralExpression
//                        {
//                        array.append((expr as! LiteralExpression).literal)
//                        }
//                    else
//                        {
//                        self.token.appendIssue(at: location,message: "A literal value was expected as part of the literal array.")
//                        return(LiteralExpression(.array(Argon.addStatic(StaticArray(array)))))
//                        }
//                    }
//                if self.token.isRightBracket
//                    {
//                    try self.nextToken()
//                    }
//                else
//                    {
//                    self.token.appendIssue(at: location,message: "']' expected after array literal.",isWarning: true)
//                    }
//                return(LiteralExpression(.array(Argon.addStatic(StaticArray(array)))))
//                }
            return(expression)
            }
        else if self.token.isLeftPar
            {
            return(try self.parseParentheses
                {
                let expression = try self.parseExpression()
//                if self.token.isComma
//                    {
//                    let tuple = TupleExpression()
//                    tuple.append(expression)
//                    while self.token.isComma
//                        {
//                        try self.parseComma()
//                        tuple.append(try self.parseExpression())
//                        }
//                    return(tuple)
//                    }
                return(expression)
                })
            }
        else if self.token.isLeftBrace
            {
            return(try self.parseClosureTerm())
            }
        else
            {
            let expression = Expression()
            self.topSymbol.appendIssue(at: self.token.location,message: "This expression is invalid.")
            try self.nextToken()
            return(expression)
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
        
    private func parseMethodInvocation(method:Method,label:Label,nameToken: Token,location: Location) throws -> Expression
        {
        self.setToken(nameToken,kind: .methodInvocation)
        let arguments = try parseParentheses
            {
            try self.parseArguments()
            }
        let expression = MethodInvocationExpression(method: method, arguments: arguments)
        expression.addDeclaration(itemKey: self.itemKey,location: location)
        let count = arguments.count
        let instancesWithArity = method.instancesWithArity(count)
        if instancesWithArity.isEmpty
            {
            self.topSymbol.appendIssue(at: location, message: "\(count) arguments were found, but there is no instance of method '\(method.label)' that has '\(count)' parameters.")
            return(expression)
            }
        for instance in instancesWithArity
            {
            if instance.parametersMatchArguments(arguments,for: expression,at: location)
                {
                return(expression)
                }
            }
        self.topSymbol.appendIssue(at: location, message: "There are no instances of method '\(method.label)' with parameters that match these arguments.")
        return(expression)
        }
        
    private func parseIdentifierTerm() throws -> Expression
        {
        let location = self.token.location
        let nameToken = self.token
        let name = try self.parseLabel()
        if self.token.isLeftPar
            {
            if let method = self.currentScope.lookupMethod(label: name)
                {
                return(try self.parseMethodInvocation(method: method,label:name,nameToken:nameToken,location: location))
                }
            else if let functions = self.currentScope.lookupFunctions(label: name)
                {
                let arguments = try parseParentheses
                    {
                    try self.parseArguments()
                    }
                let expression = FunctionInvocationExpression(function: functions.first!, arguments: arguments)
                expression.addDeclaration(itemKey: self.itemKey,location: location)
                return(expression)
                }
            else
                {
                let expression = Expression()
                self.topSymbol.appendIssue(at: location, message: "A method labeled '\(name)' could not be resolved.")
                return(expression)
                }
            }
        if let enumeration  = self.currentScope.lookupEnumeration(label: name)
            {
            if self.token.isSymbolLiteral
                {
                let symbol = self.token.symbolLiteral.string
                try self.nextToken()
                if self.token.isLeftBracket
                    {
                    var slotNames = Array<String>()
                    try self.parseBrackets
                        {
                        repeat
                            {
                            try self.parseComma()
                            if self.token.isIdentifier
                                {
                                slotNames.append(self.token.identifier)
                                try self.nextToken()
                                }
                            }
                        while self.token.isComma
                        }
                    if !self.token.isAssign
                        {
                        let expression = Expression()
                        self.topSymbol.appendIssue(at: location, message: "'=' was expected after a destructuring enumeration.")
                        return(expression)
                        }
                    try self.nextToken()
                    let value = try self.parseExpression()
                    return(EnumerationDecompositionExpression(enumeration: enumeration,caseSymbol: symbol,slotNames: slotNames,value: value))
                    }
                else if self.token.isLeftPar
                    {
                    var expressions = Expressions()
                    try self.parseParentheses
                        {
                        repeat
                            {
                            try self.parseComma()
                            expressions.append(try self.parseExpression())
                            }
                        while self.token.isComma
                        }
                    return(EnumerationInstanceExpression(enumeration: enumeration,caseSymbol: symbol,associatedValues: expressions))
                    }
                else
                    {
                    return(EnumerationInstanceExpression(enumeration: enumeration,caseSymbol: symbol,associatedValues: nil))
                    }
                }
            }
        if let types = self.currentScope.lookupTypes(label: name)
            {
            if self.token.isLeftBrocket
                {
                let type = types.first!
                if type.isClass
                    {
                    let someTypes = try self.parseTypeArguments()
                    if !someTypes.isEmpty
                        {
                        let newType = type.withGenerics(someTypes)
                        return(LiteralExpression(.class(newType as! TypeClass)))
                        }
                    return(LiteralExpression(.class(type as! TypeClass)))
                    }
                else if type.isEnumeration
                    {
                    let someTypes = try self.parseTypeArguments()
                    let newType = type.withGenerics(someTypes)
                    return(LiteralExpression(.enumeration(newType as! TypeEnumeration)))
                    }
                else
                    {
                    let expression = Expression()
                    self.topSymbol.appendIssue(at: location, message: "'\(name)' was expected to be a class or an enumeration but was neither.")
                    return(expression)
                    }
                }
            else
                {
                let type = types.first!
                if type.isClass
                    {
                    return(LiteralExpression(.class(type as! TypeClass)))
                    }
                else if type.isEnumeration
                    {
                    return(LiteralExpression(.enumeration(type as! TypeEnumeration)))
                    }
                else
                    {
                    let expression = Expression()
                    self.topSymbol.appendIssue(at: location, message: "This type can not be used as a literal value.")
                    return(expression)
                    }
                }
            }
        if let aSymbol = self.currentScope.lookup(label: name)
            {
            ///
            /// Or a Module ?
            ///
            if let symbol = aSymbol as? Module
                {
                let term = LiteralExpression(.module(symbol))
                term.addDeclaration(itemKey: self.itemKey,location: location)
                return(term)
                }
            ///
            /// Or a Constant ?
            ///
            else if let symbol = aSymbol as? Constant
                {
                return(LiteralExpression(.constant(symbol)))
                }
            ///
            /// Or a slot, Parameter or Closure containing Slot
            ///
            else if aSymbol is LocalSlot || aSymbol is Parameter
                {
                ///
                /// Could be a closure
                ///
                if self.token.isLeftPar
                    {
                    let slot = aSymbol as! Slot
                    let arguments = try self.parseParentheses
                        {
                        try self.parseArguments()
                        }
                    if slot.type.isFunction
                        {
                        let expression = ClosureExpression(slot: slot,arguments: arguments)
                        expression.addDeclaration(itemKey: self.itemKey,location: location)
                        return(expression)
                        }
                    }
                let read = LocalSlotExpression(slot: aSymbol as! Slot)
                read.addReference(location)
                return(read)
                }
            ///
            /// Or an import expression ?
            ///
            else if let symbol = aSymbol as? Importer
                {
                let expression = ImportExpression(import:symbol)
                expression.addDeclaration(itemKey: self.itemKey,location: location)
                return(expression)
                }
            }
        ///
        /// Or a "we don't have a fucking clue so we'll make it a slot"
        ///
        var type: Type = TypeContext.freshTypeVariable()
        if self.token.isGluon
            {
            try self.nextToken()
            type = try self.parseType()
            }
        let localSlot = LocalSlot(label: name,type: type,value: nil)
        self.currentScope.addLocalSlot(localSlot)
        let term = LocalSlotExpression(slot: localSlot)
        localSlot.addDeclaration(itemKey: self.itemKey,location: location)
        term.addDeclaration(itemKey: self.itemKey,location: location)
        return(term)
        }
        
    private func parseClosureTerm() throws -> Expression
        {
        let closure = Closure(label: Argon.nextName("1_CLOSURE"))
        closure.returnType = self.argonModule.void
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
                closure.addParameterSlot(parameter)
                }
            while !self.token.isRightBrace
                {
                try self.parseBlock(into: closure.block)
                }
            }
        closure.addDeclaration(itemKey: self.itemKey,location: location)
        return(ClosureExpression(closure:closure))
        }
        
//    private func parseInvocationTerm(methodInstances: MethodInstances) throws -> Expression
//        {
//        let location = self.token.location
//        let args = try self.parseParentheses
//            {
//            try self.parseArguments()
//            }
//        let expression = MethodInvocationExpression(methodInstances: methodInstances,arguments: args)
//        expression.addDeclaration(itemKey: self.itemKey,location: location)
//        return(expression)
//        }
        
//    private func parseInstanciationTerm(ofType type: Type) throws -> Expression
//        {
//        let location = self.token.location
//        var arguments = Arguments()
//        try self.parseParentheses
//            {
//            () throws -> Void in
//            if !self.token.isRightPar
//                {
//                repeat
//                    {
//                    try self.parseComma()
//                    arguments.append(try self.parseArgument())
//                    }
//                while self.token.isComma
//                }
//            }
//        let invocation = TypeInstanciationTerm(type: type,arguments: arguments)
//        invocation.addDeclaration(itemKey: self.itemKey,location: location)
//        return(invocation)
//        }
        
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
        if try (self.token.isIdentifier || self.token.isSymbolLiteral) && self.peekToken1().isGluon
            {
            let tag = self.token.isIdentifier ? self.token.identifier : self.token.symbolLiteral.string
            try self.nextToken()
            try self.nextToken()
            return(Argument(tag: tag, value: try self.parseExpression()))
            }
        return(Argument(tag: nil,value: try self.parseExpression()))
        }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                                                                                                                               ///
    ///                                                                                                                                               ///
    /// PARSE BLOCKS, STATEMENTS ARE PARSED INTO BLOCKS SO ALL NON-EXPRESSIONS AND NON DECLARATIONS ARE PARSED HERE                                   ///
    ///                                                                                                                                               ///
    ///                                                                                                                                               ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private func parseBlock(into block: Block) throws
        {
        while !self.token.isRightBrace
            {
            if self.token.isEnd
                {
                return
                }
            if self.token.isFor
                {
                try self.parseForBlock(into: block)
                }
            else if self.token.isPrimitive
                {
                try self.parsePrimitiveBlock(into: block)
                }
            else if self.token.isSelect
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
//            else if self.token.isSelf || self.token.isSELF || self.token.isSuper
//                {
//                block.addBlock(ExpressionBlock(try self.parseExpression()))
//                }
            else
                {
                self.topSymbol.appendIssue(at: self.token.location,message: "A statement was expected but \(self.token) was found.")
                try self.nextToken()
                }
            }
        }
//        
//    private func parsePrimitiveBlock(into block: Block) throws
//        {
//        try self.nextToken()
//        var name = ""
//        try self.parseParentheses
//            {
//            name = try self.parseLabel()
//            }
//        block.addBlock(PrimitiveBlock(primitiveName: name))
//        }
        
    private func parsePrimitiveBlock(into block: Block) throws
        {
        let location = self.token.location
        try self.nextToken()
        let index = try self.parseParentheses
            {
            () -> Int in
            var index = -1
            if !self.token.isIntegerLiteral
                {
                self.topSymbol.appendIssue(at: location, message: "Integer literal primitive index expected.")
                }
            else
                {
                index = Int(self.token.integerLiteral)
                }
            try self.nextToken()
            return(index)
            }
        block.addBlock(PrimitiveBlock(primitiveIndex: index))
        }
        
    private func parseSelectBlock(into block: Block) throws
        {
        try self.nextToken()
        let location = self.token.location
        let value = try self.parseParentheses
            {
            return(try self.parseExpression())
            }
        let selectBlock = SelectBlock(value: value)
        selectBlock.addDeclaration(itemKey: self.itemKey,location: location)
        block.addBlock(selectBlock)
        try self.parseBraces
            {
            while !self.token.isRightBrace && !self.token.isOtherwise
                {
                if !self.token.isWhen
                    {
                    self.topSymbol.appendIssue(at: location,message: "WHEN expected after SELECT clause")
                    try self.nextToken()
                    }
                try self.nextToken()
                let location1 = self.token.location
                let inner = try self.parseParentheses
                    {
                    try self.parseExpression()
                    }
                let when = WhenBlock(condition: inner)
                when.addDeclaration(itemKey: self.itemKey,location: location1)
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
        }
        
    private func parseElseIfBlock(into block: IfBlock) throws
        {
        let location = self.token.location
        let expression = try self.parseExpression()
        let statement = ElseIfBlock(condition: expression)
        block.elseBlock = statement
        statement.addDeclaration(itemKey: self.itemKey,location: location)
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
        }
        
    private func parseIfBlock(into block: Block) throws
        {
        try self.nextToken()
        let location = self.token.location
        let expression = try self.parseExpression()
        let statement = IfBlock(condition: expression)
        if expression is EnumerationDecompositionExpression
            {
            (expression as! EnumerationDecompositionExpression).block = statement
            }
        block.addBlock(statement)
        statement.addDeclaration(itemKey: self.itemKey,location: location)
        try self.parseBraces
            {
            self.pushContext(statement)
            try self.parseBlock(into: statement)
            self.popContext()
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
        }
        
    private func parseDestructuringTuple() throws -> CompoundExpression
        {
        let location = self.token.location
        let tuple = try self.parseParentheses
            {
            () -> CompoundExpression in
            let tuple = CompoundExpression()
            repeat
                {
                try self.parseComma()
                if self.token.isIdentifier
                    {
                    let label = try self.parseLabel()
                    if let slot = self.currentScope.lookup(label: label) as? LocalSlot
                        {
                        self.cancelCompletion()
                        self.dispatchError(at: location,message: "Destructuring tuple can not reference initialized local slot '\(label)'.")
                        tuple.append(LocalSlotExpression(slot: slot))
                        }
                    else
                        {
                        let newSlot = LocalSlot(label: label)
                        tuple.append(LocalSlotExpression(slot: newSlot))
                        self.currentScope.addSymbol(newSlot)
                        }
                    }
                else if self.token.isLeftPar
                    {
                    tuple.append(try self.parseDestructuringTuple())
                    }
                else
                    {
                    self.cancelCompletion()
                    self.dispatchError(at: location,message: "Destructuring tuple may not contain '\(self.token)'.")
                    }
                }
            while self.token.isComma
            return(tuple)
            }
        return(tuple)
        }
        
    private func parseExpressionTuple(for tuple: CompoundExpression) throws -> CompoundExpression
        {
        return(try parseParentheses
            {
            let expressions = CompoundExpression()
            for element in tuple.expressions
                {
                if let innerTuple = element as? CompoundExpression
                    {
                    expressions.append(try self.parseExpressionTuple(for: innerTuple))
                    }
                else
                    {
                    expressions.append(try self.parseExpression())
                    }
                }
            return(expressions)
            })
        }
        
    private func parseIdentifierBlock(into block: Block) throws
        {
        let location = self.token.location
        let start = self.token.location.tokenStart
        var lhs = try self.parseExpression()
        if self.token.isAddEquals || self.token.isSubEquals || self.token.isMulEquals || self.token.isDivEquals || self.token.isBitAndEquals || self.token.isBitOrEquals || self.token.isBitNotEquals || self.token.isBitXorEquals
            {
            let symbol = self.token.operatorString
            try self.nextToken()
            lhs = AssignmentOperatorExpression(lhs, symbol, try self.parseExpression())
            }
        else if self.token.isAssign
            {
            if lhs.isReadOnlyExpression
                {
                self.cancelCompletion()
                self.topSymbol.appendIssue(at: location,message: "A read only slot can not be assigned to.")
                }
            try self.nextToken()
            let rhs = try self.parseExpression()
            lhs = AssignmentExpression(lhs, rhs)
            }
        lhs.addDeclaration(itemKey: self.itemKey,location: location)
        let stop = self.token.location.tokenStop
        let newBlock = ExpressionBlock(lhs)
        newBlock.source = self.source?.substring(with: start..<stop + 1) ?? ""
        newBlock.addDeclaration(itemKey: self.itemKey,location: location)
        block.addBlock(newBlock)
        }
        
    private func parseLetBlock(into block: Block) throws
        {
        let location = self.token.location
        try self.nextToken()
        var isDestructuringAssignment = false
        var tuple: CompoundExpression
        if self.token.isLeftPar
            {
            tuple = try self.parseDestructuringTuple()
            isDestructuringAssignment = true
            }
        else if self.token.isIdentifier
            {
            let label = self.token.identifier
            try self.nextToken()
            if let slot = self.currentScope.lookup(label: label) as? LocalSlot
                {
                self.cancelCompletion()
                self.topSymbol.appendIssue(at: location,message: "LET assignment can only be done to an uninitialized slot, '\(label)' is already defined.")
                tuple = CompoundExpression(LocalSlotExpression(slot: slot))
                }
            else
                {
                let newSlot = LocalSlot(label: label, type: TypeContext.freshTypeVariable(), value: nil)
                self.currentScope.addLocalSlot(newSlot)
                tuple = CompoundExpression(LocalSlotExpression(slot: newSlot))
                }
            }
        else
            {
            self.cancelCompletion()
            self.topSymbol.appendIssue(at: location,message: "An identifier or a tuple was expected after LET but \(self.token) was found.")
            tuple = CompoundExpression()
            }
        var rhsExpression: CompoundExpression
        if !self.token.isAssign
            {
            self.cancelCompletion()
            self.dispatchError(at: location,message: "'=' was expected after a LET, but '\(self.token)' was found.")
            }
        try self.nextToken()
        if isDestructuringAssignment
            {
            rhsExpression = try self.parseExpressionTuple(for: tuple)
            }
        else
            {
            rhsExpression = CompoundExpression(try self.parseExpression())
            }
        let statement = LetBlock(location: location,lhs: tuple,rhs: rhsExpression)
        block.addBlock(statement)
        statement.addDeclaration(itemKey: self.itemKey,location: location)
        }
        
    private func parseReturnBlock(into block: Block) throws
        {
        try self.nextToken()
        let location = self.token.location
        var returnBlock: ReturnBlock
        if self.token.isLeftPar
            {
            let value = try self.parseParentheses
                {
                () -> Expression? in
                if self.token.isRightPar
                    {
                    return(nil)
                    }
                return(try self.parseExpression())
                }
            returnBlock = ReturnBlock(expression: value)
            }
        else
            {
            returnBlock = ReturnBlock()
            }
        returnBlock.addDeclaration(itemKey: self.itemKey,location: location)
        block.addBlock(returnBlock)
        }
        
    private func parseWhileBlock(into block: Block) throws
        {
        let location = self.token.location
        try self.nextToken()
        let expression = try self.parseExpression()
        let statement = WhileBlock(condition: expression)
        statement.addDeclaration(itemKey: self.itemKey,location: location)
        try self.parseBraces
            {
            try self.parseBlock(into: statement)
            }
        block.addBlock(statement)
        }
        
    private func parseInductionVariable() throws
        {
        }
        
    private func parseForkBlock(into block: Block) throws
        {
        try self.parseParentheses
            {
            if self.token.isIdentifier
                {
                }
            else if self.token.isLeftBrace
                {
                _ = try self.parseExpression()
                }
            else
                {
                self.cancelCompletion()
                }
            }
        }
        
    private var textStart: Int = 0
    
    ///
    ///
    /// LOOPs have 3 expressions that control them, the first is the start expression
    /// which kicks the loop off, then comes the termination expression which keeps the
    /// loop going until it evaluates to false, then the update expression which can be
    /// used to update induction variables etc.
    ///
    /// 
    private func parseLoopBlock(into block: Block) throws
        {
        try self.nextToken()
        let location = self.token.location
        let statement = LoopBlock()
        block.addBlock(statement)
        self.pushContext(statement)
        let (start,end,update) = try self.parseLoopConstraints()
        statement.startExpressions = start
        statement.endExpression = end
        statement.updateExpressions = update
        statement.addDeclaration(itemKey: self.itemKey,location: location)
        try self.parseBraces
            {
            try self.parseBlock(into: statement)
            }
        self.popContext()
        if statement.isEmpty
            {
            self.topSymbol.appendIssue(at: location, message: "LOOP block does nothing and can be removed.",isWarning: true)
            }
        }
        
    private func parseStartExpression() throws -> Expression
        {
        var lhs = try self.parseExpression()
        if lhs is LocalSlotExpression
            {
            if let slot = (lhs as! LocalSlotExpression).slot as? LocalSlot
                {
                self.currentScope.addLocalSlot(slot)
                }
            }
        if self.token.isAssign
            {
            try self.nextToken()
            let value = try self.parseExpression()
            lhs = AssignmentExpression(lhs,value)
            lhs.addDeclaration(itemKey: self.itemKey,location: self.token.location)
            }
        return(lhs)
        }
        
    private func parseLoopConstraints() throws -> ([Expression],Expression,[Expression])
        {
        var start = Array<Expression>()
        var end = Expression()
        var update = Array<Expression>()
        try self.parseParentheses
            {
            if !self.token.isSemicolon
                {
                repeat
                    {
                    try self.parseComma()
                    start.append(try self.parseStartExpression())
                    }
                while self.token.isComma
                }
            if !self.token.isSemicolon
                {
                self.topSymbol.appendIssue(at: self.token.location, message: "';' was expected between LOOP clauses.")
                }
            try self.nextToken()
            if !self.token.isSemicolon
                {
                end = try self.parseAssignmentExpression()
                if !self.token.isSemicolon
                    {
                    self.topSymbol.appendIssue(at: self.token.location, message: "';' was expected between LOOP clauses.")
                    }
                try self.nextToken()
                }
            if !self.token.isRightPar
                {
                repeat
                    {
                    try self.parseComma()
                    update.append(try self.parseAssignmentExpression())
                    }
                while self.token.isComma
                }
            }
        return((start,end,update))
        }
        
    private func parseSignalBlock(into block: Block) throws
        {
        try self.nextToken()
        let location = self.token.location
        try self.parseParentheses
            {
            if try self.nextToken().isSymbolLiteral
                {
                let symbol = self.token.symbolLiteral.string
                let signal = SignalBlock(symbol: symbol)
                signal.addDeclaration(itemKey: self.itemKey,location: location)
                block.addBlock(signal)
                try self.nextToken()
                }
            else
                {
                self.topSymbol.appendIssue(at: location,message:"Symbol expected but \(self.token) was found instead.")
                }
            }
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
        var isVariadic = false
        var type:Type = self.argonModule.void
        if !self.token.isGluon && self.token.isIdentifier
            {
            relabel = try self.parseLabel()
            }
        if !self.token.isGluon
            {
            self.topSymbol.appendIssue(at: location, message: "Gluon expected after tag/tag label.")
            }
        try self.nextToken()
        if self.token.isFullRange
            {
            try self.nextToken()
            isVariadic = true
            }
        else
            {
            type = try self.parseType()
            }
        let parameter = Parameter(label: tag, relabel: relabel,type: type,isVisible: !isHidden,isVariadic: isVariadic)
        parameter.addDeclaration(itemKey: self.itemKey,location: location)
        return(parameter)
        }
        
    @discardableResult
    private func parseFunction() throws -> Function
        {
        try self.nextToken()
        let location = self.token.location
        self.tokenKind = .function
        let cName = try self.parseParentheses
            {
            () throws -> String in
            let string = try self.parseLabel()
            return(string)
            }
        let name = try self.parseLabel()
        let parameters = try self.parseParameters()
        let function = Function(label: name)
        function.addDeclaration(itemKey: self.itemKey,location: location)
        function.cName = cName
        function.parameters = parameters
        if self.token.isRightArrow
            {
            try self.nextToken()
            function.returnType = try self.parseType()
            }
        self.addSymbol(function)
        return(function)
        }
        
    @discardableResult
    internal func parseTypeAlias() -> SymbolValue
        {
        do
            {
            try self.nextToken()
            let location = self.token.location
            self.tokenKind = .type
            let label = try self.parseLabel()
            let alias = TypeAlias(label: label)
            alias.setModule(self.enclosingModule)
            self.pushSymbol(alias)
            defer
                {
                self.popSymbol()
                }
            if !self.token.isIs
                {
                alias.appendIssue(at: location, message: "'IS' expected after aliased label for type.")
                }
            try self.nextToken()
            alias.type = try self.parseType()
            alias.addDeclaration(itemKey: self.itemKey,location: location)
            alias.itemKey = self.itemKey
            return(.typeAlias(alias))
            }
        catch
            {
            return(.error([CompilerIssue(location: self.token.location,message: "Unexpected end of source.")]))
            }
        }
        
    private func parseHandleBlock(into block: Block) throws
        {
        let start = self.token.location.tokenStart
        try self.nextToken()
        let location = self.token.location
        let handler = HandlerBlock()
        handler.addDeclaration(itemKey: self.itemKey,location: location)
        block.addBlock(handler)
        self.pushContext(handler)
        try self.parseParentheses
            {
            repeat
                {
                try self.parseComma()
                if !self.token.isSymbolLiteral
                    {
                    self.topSymbol.appendIssue(at: location,message: "A symbol was expected in the handler clause, but \(self.token) was found.")
                    }
                let symbol = self.token.isSymbolLiteral ? self.token.symbolLiteral.string : "#SYMBOL"
                try self.nextToken()
                handler.symbols.append(symbol)
                }
            while self.token.isComma
            }
        try self.parseBraces
            {
            if !self.token.isWith
                {
                self.topSymbol.appendIssue(at: location,message: "WITH expected in first line of HANDLE clause, but \(self.token) was found.")
                }
            try self.nextToken()
            var name:String = ""
            try self.parseParentheses
                {
                if !self.token.isIdentifier
                    {
                    self.topSymbol.appendIssue(at: location,message: "The name of an induction variable to contain the symbol this handler is receiving was expected but \(self.token) was found.")
                    }
                name = self.token.isIdentifier ? self.token.identifier : "VariableName"
                handler.addParameter(label: name,type: self.argonModule.symbol)
                try self.nextToken()
                }
            try self.parseBlock(into: handler)
            }
        self.popContext()
        let stop = self.token.location.tokenStop
        handler.source = self.source?.substring(with: start..<stop + 1) ?? ""
        }
        
    public func parse(itemKey: Int,source: String,tokenHandler: TokenHandler,inContext context: CompilationContext) throws -> SymbolValue
        {
        self.itemKey = itemKey
        self.pushSymbol(context)
        defer
            {
            self.popSymbol()
            }
        let tokens = TokenStream(source: source).allTokens(withComments: true)
        self.tokenSource = TokenHolder(tokens: tokens.filter{!$0.isWhitespace})
        for token in tokens
            {
            tokenHandler.kindChanged(token: token)
            }
        self.tokenHandler = tokenHandler
        self.token = self.tokenSource.nextToken()
        self.argonModule = context.argonModule
        self.topModule = context.argonModule.topModule
        var result = SymbolValue.error([])
        do
            {
            if !self.token.isModuleLevelKeyword
                {
                return(.error([CompilerIssue(location: .one,message: "One of 'CLASS','SLOT','TYPE','METHOD','PRIMITIVE','ENUMERATION' keywords were expected but '\(self.token)' was found.")]))
                }
            else
                {
                if self.token.isClass
                    {
                    return(self.parseClass())
                    }
                else if self.token.isSlot
                    {
                    let slot = try self.parseModuleSlot()
                    result = .moduleSlot(slot)
                    }
                else if self.token.isType
                    {
                    return(self.parseTypeAlias())
                    }
                else if self.token.isPrimitive
                    {
                    let primitive = try self.parsePrimitiveMethod()
                    result = .primitive(primitive)
                    }
                else if self.token.isMethod
                    {
                    return(self.parseMethodInstance())
                    }
                else if self.token.isEnumeration
                    {
                    return(self.parseEnumeration())
                    }
                else
                    {
                    return(.error([CompilerIssue(location: .one,message: "Expected a keyword but found \(self.token).")]))
                    }
                }
            }
        catch let error
            {
            print(error)
            }
        return(result)
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
