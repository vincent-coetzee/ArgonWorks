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
    
        
public class Parser: CompilerPass
    {
    private var enclosingModule: Module
        {
        var aScope = self.currentScope
        while aScope.moduleScope.isNil
            {
            aScope = aScope.parentScope!
            }
        return(aScope.moduleScope as! Module)
        }
        
    private var enclosingMethodInstance: MethodInstance
        {
        self.currentScope.enclosingMethodInstance
        }
        
    internal private(set) var token:Token = .none
    private var lastToken:Token = .none
    public let compiler:Compiler
    private var source: String?
    public var wasCancelled = false
    public var currentTag = 0
    private var isParsingLValue = false
    private var sourceStack = Stack<TokenSource>()
    private var tokenSource: TokenSource!
    private var lineNumber:LineNumber = EmptyLineNumber()
    private var reportingContext:Reporter = NullReporter.shared
    private var tokenRenderer: SemanticTokenRenderer!
    private var warningCount = 0
    private var errorCount = 0
    private let typeContext: TypeContext
    private var currentScope: Scope = TopModule.shared
    private var scopeStack = Stack<Scope>()
    
    init(_ compiler:Compiler)
        {
        self.tokenRenderer = compiler.tokenRenderer
        self.compiler = compiler
        self.reportingContext = NullReporter.shared
        self.typeContext = TypeContext()
        self.initParser(source: compiler.source)

        }
        
    init(compiler:Compiler,tokens: Tokens)
        {
        self.tokenRenderer = compiler.tokenRenderer
        self.compiler = compiler
        self.reportingContext = NullReporter.shared
        self.typeContext = TypeContext()
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
        self.token = self.token.withLocation(self.token.location)
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
        
    private func lookup(label: Label) -> Symbol?
        {
        self.currentScope.lookup(label: label)
        }
        
    private func lookup(name: Name) -> Symbol?
        {
        self.currentScope.lookup(name: name)
        }
        
    private func appendIssue(at: Location,message: String)
        {
        self.currentScope.appendIssue(at: at,message: message)
        }
        
    private func pushContext(_ scope: Scope)
        {
        var newScope = scope
        newScope.container = self.currentScope.asContainer
        self.scopeStack.push(self.currentScope)
        self.currentScope = scope
        }
        
    private func popContext()
        {
        self.currentScope = self.scopeStack.pop()
        }
        
    private func addSymbol(_ symbol: Symbol)
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
//        self.reportingContext = self.compiler.reportingContext
        }
    
    private func initParser(source: String)
        {
        self.source = source
        self.tokenSource = TokenStream(source: source,context: self.reportingContext,withComments: false)
//        self.reportingContext = self.compiler.reportingContext
        }
        
//    public func parseModifier() throws -> PrivacyScope?
//        {
//        if self.token.isKeyword,let scope = PrivacyScope(rawValue: self.token.keyword.rawValue)
//            {
//            try self.nextToken()
//            return(scope)
//            }
//        return(nil)
//        }
        
    
    public func processModule(_ module: Module?) -> Module?
        {
        do
            {
            self.warningCount = 0
            self.errorCount = 0
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
                self.reportingContext.dispatchError(at: self.token.location, message: "KEYWORD expected.")
                return(nil)
                }
            if self.token.isKeyword
                {
                let module = try self.parseModule()
                self.reportingContext.status("Parsing complete: \(self.warningCount) warnings, \(self.errorCount) errors.")
                return(module)
                }
            }
        catch
            {
            }
        self.reportingContext.status("Parsing failed.")
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
        
//    @discardableResult
//    private func parsePrivacyModifier(_ closure: (PrivacyScope?) throws -> Symbol?) throws -> Symbol?
//        {
//        let modifier = self.token.isKeyword ? PrivacyScope(rawValue: self.token.keyword.rawValue) : nil
//        if self.token.isPrivacyModifier
//            {
//            try self.chompKeyword()
//            }
//        let value = try closure(modifier)
//        value?.privacyScope = modifier
//        return(value)
//        }
        
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

    private func parseMainMethod() throws
        {
        try self.nextToken()
        let method = try self.parseMethodInstance()
        method.isMainMethod = true
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
        if self.token.isPathLiteral
            {
            self.tokenRenderer.setKind(.path,ofToken: self.token)
            try self.nextToken()
            return(self.lastToken)
            }
        self.appendIssue(at: self.token.location,message: "Path expected for a library module but \(self.token) was found.")
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
        var module = self.lookup(name: name) as? Module
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
                    module?.appendIssue(at: location,message: "A module named '\(name.string)' was found, but it was used as a library module and it is a module")
                    }
                }
            module?.appendIssue(at: location,message:"A module named '\(name.string)' already exists, its contents may be overwritten.",isWarning: true)
            }
        if isNew
            {
            if name.count == 1
                {
                self.addSymbol(module!)
                }
            else
                {
                (self.currentScope.lookup(name: name.withoutLast) as? Scope)?.addSymbol(module!)
                }
            module?.addDeclaration(location)
            }
        else
            {
            module?.addReference(location)
            }
        try self.parseModule(into: module!)
        return(module!)
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
//                try self.parseMacroInvocation()
                if !self.token.isKeyword
                    {
                    self.reportingContext.dispatchError(at: self.token.location, message: "Keyword expected but \(self.token) found.")
                    try self.nextToken()
                    }
                else
                    {
                    if self.token.isMainDirective
                        {
                        try self.nextToken()
                        }
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
                        case .FUNCTION:
                            try self.parseFunction()
                        case .MAIN:
                            try self.parseMainMethod()
                        case .MODULE:
                            try self.parseModule()
                        case .CLASS:
                            try self.parseClass()
                        case .TYPE:
                            try self.parseTypeAlias()
                        case .PRIMITIVE:
                            try self.parsePrimitiveMethod()
                        case .METHOD:
                            try self.parseMethodInstance()
                        case .CONSTANT:
                            try self.parseConstant()
                        case .SCOPED:
                            let scoped = try self.parseScopedSlot()
                            module.addSymbol(scoped)
                        case .ENUMERATION:
                            try self.parseEnumeration()
                        case .SLOT:
                            let slot = try self.parseSlot(.moduleSlot)
                            module.addSymbol(slot)
                        case .INTERCEPTOR:
                            let interceptor = try self.parseInterceptor()
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
        
    private func parseForBlock(into block:Block) throws
        {
        let location = self.token.location
        try self.nextToken()
        var slot:LocalSlot = LocalSlot(label: "", type: TypeContext.freshTypeVariable(), value: nil)
        var elements:Expression = Expression()
        var issues = CompilerIssues()
        try self.parseParentheses
            {
            var label:Label = ""
            if !self.token.isIdentifier
                {
                self.cancelCompletion()
                issues.appendIssue(at: location,"Identifier expected in first part of FOR statement.")
                }
            else
                {
                label = try self.parseLabel()
                }
            if self.token.isGluon
                {
                try self.nextToken()
                let type = try self.parseType(&issues)
                slot = LocalSlot(label: label, type: type,value: nil)
                }
            else
                {
                slot = LocalSlot(label: label, type: TypeContext.freshTypeVariable(), value: nil)
                }
            try self.parseComma()
            elements = try self.parseExpression()
            }
//        if !elements.type.isSubtype(of: TopModule.shared.shared.iterable.type)
//            {
//            self.cancelCompletion()
//            issues.appendIssue(at: location,"To be used in a FOR loop, the source of the iteration must inherit from Iterable.")
//            }
        let forBlock = ForBlock(inductionSlot: slot,elements: elements)
        forBlock.addLocalSlot(slot)
        forBlock.addDeclaration(location)
        block.addBlock(forBlock)
        self.pushContext(forBlock)
        try self.parseBraces
            {
            try self.parseBlock(into: forBlock)
            }
        self.popContext()
        forBlock.appendIssues(issues)
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
        let operatorKindToken = self.token
        try self.nextToken()
        var primitiveIndex:Argon.Integer = 0
        var issues = CompilerIssues()
        if self.token.isPrimitive
            {
            isPrimitive = true
            try self.nextToken()
            try self.parseParentheses
                {
                if !self.token.isIntegerLiteral
                    {
                    self.cancelCompletion()
                    issues.appendIssue(at: location, "A PRIMITIVE index was expected after the PRIMITIVE keyword.")
                    }
                else
                    {
                    primitiveIndex = self.token.integerLiteral
                    }
                try self.nextToken()
                }
            }
        var operation: Token.Operator
        if !(self.token.isOperator || self.token.isSymbol)
            {
            self.cancelCompletion()
            issues.appendIssue(at: location,"Operator expected after PREFIX, POSTFIX,INFIX or PRIMITIVE, but '\(self.token)' found.")
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
        try self.nextToken()
        var types = Types()
        if self.token.isLeftBrocket
            {
            types = try self.parseMethodGenericParameters()
            }
        let parameters = try self.parseParameters([])
        if kind == .prefix || kind == .postfix
            {
            if parameters.count != 1
                {
                self.cancelCompletion()
                issues.appendIssue(at: location,"A PREFIX or POSTFIX operator must only have a single parameter.")
                }
            }
        else if kind == .infix
            {
            if parameters.count != 2
                {
                self.cancelCompletion()
                issues.appendIssue(at: location,"An INFIX operator must have 2 parameters.")
                }
            }
        if !self.token.isRightArrow
            {
            self.cancelCompletion()
            issues.appendIssue(at: location,"An operator must return a value.")
            }
        try self.nextToken()
        let returnType = try self.parseType(&issues)
        var instance = MethodInstance(label: operation.name)
        if operatorKindToken.isPrefix
            {
            if isPrimitive
                {
                instance = PrimitivePrefixOperatorInstance(label: operation.name,parameters: parameters,returnType: returnType)
                }
            else
                {
                instance = PrefixOperatorInstance(label: operation.name,parameters: parameters,returnType: returnType)
                }
            }
        else if operatorKindToken.isPostfix
            {
            if isPrimitive
                {
                instance = PrimitivePostfixOperatorInstance(label: operation.name,parameters: parameters,returnType: returnType)
                }
            else
                {
                instance = PostfixOperatorInstance(label: operation.name,parameters: parameters,returnType: returnType)
                }
            }
        else if operatorKindToken.isInfix
            {
            if isPrimitive
                {
                instance = PrimitiveInfixOperatorInstance(label: operation.name,parameters: parameters,returnType: returnType)
                }
            else
                {
                instance = InfixOperatorInstance(label: operation.name,parameters: parameters,returnType: returnType)
                }
            }
        instance.addDeclaration(location)
        self.addSymbol(instance)
        instance.addTemporaries(types)
        if isPrimitive
            {
            (instance as! PrimitiveInstance).primitiveIndex = primitiveIndex
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
        if let instances = self.currentScope.lookupMethodInstances(name: Name(instance.label))
            {
            for methodInstance in instances
                {
                if methodInstance.typeSignature == instance.typeSignature
                    {
                    instance.appendIssue(at: location,message: "There is already a operator instance with this signature defined.",isWarning: true)
                    }
                }
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
        var index: Argon.Integer = 0
        var issues = CompilerIssues()
        try self.parseParentheses
            {
            if !self.token.isIntegerLiteral
                {
                self.cancelCompletion()
                issues.appendIssue(at: location, "A PRIMITIVE index was expected after the PRIMITIVE keyword.")
                }
            else
                {
                index = self.token.integerLiteral
                }
            try self.nextToken()
            }
        self.tokenRenderer.setKind(.method,ofToken: self.token)
        let name = try self.parseLabel()
//        let existingMethod = self.currentScope.lookup(label: name) as? Method
        var isGenericMethod = false
        var types: Types = []
        if self.token.isLeftBrocket
            {
            types = try self.parseMethodGenericParameters()
            isGenericMethod = true
            }
        let list = try self.parseParameters()
        var returnType: Type = ArgonModule.shared.void
        if self.token.isRightArrow
            {
            try self.nextToken()
            returnType = try self.parseType(&issues)
            }
        let instance = PrimitiveMethodInstance(label: name,parameters: list,returnType: returnType)
        instance.primitiveIndex = index
        instance.isGenericMethod = isGenericMethod
        instance.addDeclaration(location)
        if let instances = self.currentScope.lookupMethodInstances(name: Name(instance.label))
            {
            for methodInstance in instances
                {
                if methodInstance.typeSignature == instance.typeSignature
                    {
                    instance.appendIssue(at: location,message: "There is already a primitive instance with this signature defined.",isWarning: true)
                    }
                }
            }
        self.currentScope.addSymbol(instance)
        instance.appendIssues(issues)
        }
        
    private func parseImport() throws
        {
        let location = self.token.location
        try self.nextToken()
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
                moduleLabel = Importer.tryLoadingPath(path,topModule: TopModule.shared,reportingContext: self.reportingContext,location: location)
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
            anImport.loadImportPath(topModule: TopModule.shared)
            anImport.appendIssues(issues)
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
//        initializer.addDeclaration(location)
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
        return(ScopedSlot(label:"Slot",type: ArgonModule.shared.integer.type))
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
//        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let label = try self.parseLabel()
//        let enumeration = Enumeration(label: label)
        var rawType = ArgonModule.shared.integer
        let type = TypeEnumeration(label: label, generics: [])
        type.container = .module(self.currentScope as! Module)
        type.setModule(self.currentScope as! Module)
        self.addSymbol(type)
        type.addDeclaration(location)
        var issues = CompilerIssues()
        if self.token.isGluon
            {
            try self.nextToken()
            let type = try self.parseType(&issues)
            rawType = type
            }
        try self.parseBraces
            {
            () throws -> Void in
            var caseIndex = 0
            while !self.token.isRightBrace
                {
                let aCase = try self.parseCase(into: type)
                aCase.caseIndex = caseIndex
                caseIndex += 1
                }
            }
        type.rawType = rawType
        type.appendIssues(issues)
//        self.stopClip(into:enumeration)
        let parms = [Parameter(label: "symbol", type: ArgonModule.shared.symbol, isVisible: false, isVariadic: false)]
        let methodInstance = EnumerationCaseMethodInstance(label: "_\(label)",parameters: parms,returnType: type)
        methodInstance.addDeclaration(location)
        let rawValueInstance = PrimitiveMethodInstance(label: "rawValue")
        rawValueInstance.primitiveIndex = 200
        rawValueInstance.addParameterSlot(Parameter(label: "enumeration",type: type))
        rawValueInstance.returnType = ArgonModule.shared.symbol
        self.addSymbol(rawValueInstance)
//        let method = Method(label: "_\(label)")
//        method.addDeclaration(location)
        self.addSymbol(methodInstance)
//        method.addInstance(methodInstance)
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
            literal = LiteralExpression(.string(Argon.addStatic(StaticString(string: self.token.stringLiteral))))
            }
        else if self.token.isHashStringLiteral
            {
            literal = LiteralExpression(.symbol(Argon.addStatic(StaticSymbol(string: self.token.hashStringLiteral))))
            }
        else
            {
            literal = LiteralExpression(.integer(0))
            self.reportingContext.dispatchError(at: self.token.location, message: "Integer, String or Symbol literal expected for rawValue of ENUMERATIONCASE")
            }
        try self.nextToken()
        return(literal)
        }
        
    private func parseCase(into enumeration: TypeEnumeration) throws -> EnumerationCase
        {
//        self.startClip()
        let location = self.token.location
        let name = try self.parseHashString()
        var types = Array<Type>()
        var issues = CompilerIssues()
        if self.token.isLeftPar
            {
            try self.parseParentheses
                {
                repeat
                    {
                    try self.parseComma()
                    let type = try self.parseType(&issues)
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
        aCase.addDeclaration(location)
        if self.token.isAssign
            {
            try self.nextToken()
            aCase.rawValue = try self.parseLiteral()
            }
        aCase.appendIssues(issues)
//        self.stopClip(into: aCase)
        return(aCase)
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
//        let aSlot = CocoonSlot(rawLabel: rawLabel,label: label,type: type ?? ArgonModule.shared.void)
//        aSlot.addDeclaration(location)
//        aSlot.writeBlock = writeBlock
//        aSlot.readBlock = readBlock
//        slot = aSlot
//        slot!.initialValue = initialValue
//        slot?.appendIssues(issues)
//        return(slot!)
//        }
        
    private enum SlotType
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
        
    private func parseSlot(_ slotType: SlotType = .instanceSlot) throws -> Slot
        {
        try self.nextToken()
        self.tokenRenderer.setKind(.classSlot,ofToken: self.token)
        let location = self.token.location
        let label = try self.parseLabel()
        var type: Type?
        var issues = CompilerIssues()
        if self.token.isGluon
            {
            try self.nextToken()
            type = try self.parseType(&issues)
            }
        var initialValue:Expression?
        if self.token.isAssign
            {
            try self.nextToken()
            initialValue = try self.parseExpression()
            }
//        var readBlock:VirtualReadBlock?
//        var writeBlock:VirtualWriteBlock?
//        if self.token.isLeftBrace
//            {
//            try self.parseBraces
//                {
//                if self.token.isRead
//                    {
//                    try self.nextToken()
//                    readBlock = VirtualReadBlock()
//                    try self.parseBraces
//                        {
//                        try self.parseBlock(into: readBlock!)
//                        }
//                    }
//                if self.token.isWrite
//                    {
//                    var variableLabel: String = "newValue"
//                    try self.nextToken()
//                    if self.token.isLeftPar
//                        {
//                        try self.parseParentheses
//                            {
//                            variableLabel = try self.parseLabel()
//                            }
//                        }
//                    writeBlock = VirtualWriteBlock()
//                    writeBlock!.newValueSlot = LocalSlot(label: variableLabel)
//                    try self.parseBraces
//                        {
//                        writeBlock?.addLocalSlot(writeBlock!.newValueSlot as! LocalSlot)
//                        try self.parseBlock(into: writeBlock!)
//                        }
//                    }
//                }
//            }
        var slot: Slot?
//        if readBlock.isNotNil
//            {
//            let aSlot = VirtualSlot(label: label,type: type ?? ArgonModule.shared.void)
//            aSlot.addDeclaration(location)
//            aSlot.writeBlock = writeBlock
//            aSlot.readBlock = readBlock
//            slot = aSlot
//            readBlock?.slot = slot
//            writeBlock?.slot = slot
//            }
//        else
//            {
            slot = slotType.newSlot(label: label)
            slot!.type = type!
            slot?.addDeclaration(location)
//            }
        slot!.initialValue = initialValue
        slot?.appendIssues(issues)
        return(slot!)
        }
        
    private func parseClassSlot() throws -> Slot
        {
        try self.nextToken()
        let slot = try self.parseSlot(.classSlot)
        return(slot)
        }
        
    private func parseGenericTypes(_ issues:inout CompilerIssues) throws -> Types
        {
        let typeParameters = try self.parseBrockets
            {
            () throws -> Types in
            var types = Types()
            repeat
                {
                try self.parseComma()
                let name = try self.parseName()
                if let value = self.currentScope.lookup(name: name) as? Type
                    {
                    types.append(value)
                    }
                else
                    {
                    let type = TypeContext.freshTypeVariable(named: name.last)
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
    private func parseClass() throws -> TypeClass
        {
        try self.nextToken()
        let location = self.token.location
        self.tokenRenderer.setKind(.classSlot,ofToken: self.token)
        let label = try self.parseLabel()
        var typeParameters = Types()
        var aClass = self.currentScope.lookup(label: label) as? TypeClass
        let classExists = aClass.isNotNil
        var issues = CompilerIssues()
        if self.token.isLeftBrocket
            {
            typeParameters = try self.parseGenericTypes(&issues)
            }
        if aClass.isNil
            {
            if typeParameters.isEmpty
                {
                aClass = TypeClass(label: label,generics: [])
                }
            else
                {
                aClass = TypeClass(label: label,generics: typeParameters)
                }
            }
        aClass!.addDeclaration(location)
        aClass!.setModule(self.currentScope as! Module)
        if !classExists
            {
            self.addSymbol(aClass!)
            }
        for parameter in typeParameters
            {
            self.addSymbol(parameter)
            }
        if self.token.isGluon
            {
            try self.nextToken()
            var issues = CompilerIssues()
            repeat
                {
                try self.parseComma()
                let aSuper = try self.parseType(&issues)
                if let superClass = aSuper as? TypeClass
                    {
                    if superClass.superclassHierarchy.contains(aClass!)
                        {
                        issues.append(CompilerIssue(location: location, message: "'\(superClass.label)' is an ancestor of '\(label)' therefore it can not be added as a superclass of '\(label)'."))
                        }
                    else
                        {
                        aClass!.addSupertype(aSuper)
                        }
                    }
                else
                    {
                    issues.append(CompilerIssue(location: location, message: "'\(aSuper.label)' is not a class and can therefore not be a superclass of '\(label)'."))
                    }
                aClass!.appendIssues(issues)
                }
            while self.token.isComma
            }
        if aClass!.superclasses.isEmpty
            {
            aClass!.addSupertype(ArgonModule.shared.object)
            }
        try self.parseBraces
            {
            while self.token.isSlot || self.token.isClass || self.token.isCocoon || self.token.isInit
                {
                if self.token.isSlot
                    {
                    let slot = try self.parseSlot()
                    if aClass!.allInstanceSlotsContainsSlotWithLabel(slot.label)
                        {
                        issues.append(CompilerIssue(location: location, message: "'\(aClass!.label)' can not have a slot labeled '\(slot.label)' because it inherits one with that label."))
                        }
                    else
                        {
                        aClass!.addInstanceSlot(slot)
                        }
                    let reader = aClass!.slotReader(forSlot: slot)
                    reader.isAutoGenerated = true
                    self.addSymbol(reader)
                    }
                else if self.token.isClass
                    {
                    if try self.peekToken1().isSlot
                        {
                        let slot = try self.parseClassSlot()
                        let someType = aClass!.type as! TypeClass
                        if someType.allInstanceSlotsContainsSlotWithLabel(slot.label)
                            {
                            issues.append(CompilerIssue(location: location, message: "'\(someType.label)' can not have a slot labeled '\(slot.label)' because it inherits one with that label."))
                            }
                        else
                            {
                            someType.addInstanceSlot(slot)
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
            }
        aClass!.initMetatype(inModule: aClass!.module)
        aClass!.layoutObjectSlots()
        return(aClass!)
        }
        
    private func parseSuperclassReferences(_ compilerIssues:inout CompilerIssues) throws -> Array<Type>
        {
        var supers = Array<Type>()
        try self.nextToken()
        repeat
            {
            try self.parseComma()
            self.tokenRenderer.setKind(.class,ofToken: self.token)
            let type = try self.parseType(&compilerIssues)
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
        self.tokenRenderer.setKind(.constant,ofToken: self.token)
        let label = try self.parseLabel()
        var type:Type = self.currentScope.lookup(label: "Void") as! Type
        var issues = CompilerIssues()
        if self.token.isGluon
            {
            try self.parseGluon()
            type = try self.parseType(&issues)
            }
        if !self.token.isAssign
            {
            issues.appendIssue(at: self.token.location, message: "'=' expected to follow the declaration of a CONSTANT.")
            }
        try self.nextToken()
        let value = try self.parseExpression()
        let constant = Constant(label: label,type: type,value: value)
        constant.addDeclaration(location)
        constant.appendIssues(issues)
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
            self.currentScope.appendIssue(at: self.token.location,message: "'(' was expected but \(self.token) was found.")
            }
        else
            {
            try self.nextToken()
            }
        let value = try closure()
        if !self.token.isRightPar
            {
            self.currentScope.appendIssue(at: self.token.location,message: "')' was expected but \(self.token) was found.")
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
            self.currentScope.appendIssue(at: self.token.location,message: "'[' was expected but \(self.token) was found.")
            }
        else
            {
            try self.nextToken()
            }
        let value = try closure()
        if !self.token.isRightBracket
            {
            self.currentScope.appendIssue(at: self.token.location,message: "']' was expected but \(self.token) was found.")
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
            self.currentScope.appendIssue(at: self.token.location,message: "'::' was expected but '\(self.token)' was found.")
            }
        else
            {
            try self.nextToken()
            }
        }
        
    private func parseType(_ compilerIssues:inout CompilerIssues) throws -> Type
        {
        let location = self.token.location
        if self.token.isLeftPar
            {
            return(try self.parseFunctionType())
            }
        var name:Name
        self.tokenRenderer.setKind(.type,ofToken: self.token)
        let identifierToken = self.token
        if self.token.isIdentifier && self.token.isSystemClassName
            {
            self.tokenRenderer.setKind(.systemClass,ofToken: self.token)
            let lastPart = self.token.identifier
            name = Name("\\\\Argon\\" + lastPart)
            }
        else if self.token.isIdentifier
            {
            self.tokenRenderer.setKind(.type,ofToken: self.token)
            name = Name(self.token.identifier)
            }
        else if self.token.isName
            {
            self.tokenRenderer.setKind(.type,ofToken: self.token)
            name = self.token.nameLiteral
            }
        else
            {
            let type = ArgonModule.shared.void
            compilerIssues.appendIssue(at: location, message: "A type name was expected but \(self.token) was found.")
            return(type)
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
        guard var type = self.currentScope.lookup(name: name) as? Type else
            {
            let typeVariable = TypeContext.freshTypeVariable()
            typeVariable.setLabel(name.displayString)
            compilerIssues.appendIssue(at: location,message: "The identifier \(name) could not be resolved, a type with that label could not be found.")
            return(typeVariable)
            }
        type.addReference(location)
        if type.isTypeAlias
            {
            self.tokenRenderer.setKind(.typeAlias,ofToken: identifierToken)
            return(type)
            }
        else if type.isTypeVariable
            {
            self.tokenRenderer.setKind(.genericClassParameter,ofToken: identifierToken)
            return(type)
            }
        let parameters = try self.parseTypeArguments(&compilerIssues)
        ///
        ///
        /// Need to modify this code to handle generic enumerations as well. In it's
        /// current form it only handles generic classes.
        ///
        ///
        if type.isEnumeration
            {
            self.tokenRenderer.setKind(.enumeration,ofToken: identifierToken)
            return(type)
            }
        if type.isClass
            {
            self.tokenRenderer.setKind(.class,ofToken: identifierToken)
            }
        if type.isSystemClass
            {
            self.tokenRenderer.setKind(.systemClass,ofToken: identifierToken)
            }
        if type.isClass
            {
            if !parameters.isEmpty
                {
                let newType = type.withGenerics(parameters)
                newType.setModule(self.enclosingModule)
                type = newType
                }
            type.addReference(location)
            return(type)
            }
        else
            {
            compilerIssues.appendIssue(at: location,"A type was expected but the identifier '\(name)' was found instead.")
            try self.nextToken()
            return(ArgonModule.shared.object)
            }
        }
        
    private func parseMacroDeclaration() throws
        {
        let location = self.token.location
        try self.nextToken()
        let label = try self.parseLabel()
        var parameters = MacroParameters()
        var issues = CompilerIssues()
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
            issues.appendIssue(at: location,message:"Expected macro text start marker '${' but found '\(self.token)'.")
            }
        else
            {
            try self.nextToken()
            }
        if !self.token.isStringLiteral
            {
            issues.appendIssue(at: location,message: "Expected macro value but found '\(self.token)'.")
            }
        let text = self.token.stringLiteral
        try self.nextToken()
        if !self.token.isMacroStop
            {
            issues.appendIssue(at: location,message: "Expected macro stop marker '}$' but found '\(self.token)'.")
            }
        try self.nextToken()
        let macro = Macro(label: label, parameters: parameters, text: text)
        macro.appendIssues(issues)
        self.currentScope.addSymbol(macro)
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
        if let macro = self.currentScope.lookup(label: label) as? Macro
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
                macro.appendIssue(at: location,message: "Macro '\(label)' expected \(macro.parameterCount) parameters but found '\(elements.count)'.",isWarning: true)
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
            self.currentScope.appendIssue(at: location,message:"The label '\(label)' is not valid in the current context, it can not be resolved.")
            }
        }
        
    private func parseFunctionType() throws -> Type
        {
        let location = self.token.location
        var issues = CompilerIssues()
        let types = try self.parseParentheses
            {
            () throws -> Types in
            var types = Types()
            repeat
                {
                try self.parseComma()
                let type = try self.parseType(&issues)
                types.append(type)
                }
            while self.token.isComma
            return(types)
            }
        if !self.token.isRightArrow
            {
            self.cancelCompletion()
            issues.appendIssue(at: location, message: "'->' was expected in a method reference type but '\(self.token)' was found.")
            }
        try self.nextToken()
        let type = TypeFunction(label: "FunctionType",types: types, returnType: try self.parseType(&issues))
        type.appendIssues(issues)
        return(type)
        }
        
    private func parseTypeArguments(_ compilerIssues:inout CompilerIssues) throws -> Types
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
                    list.append(try self.parseType(&compilerIssues))
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
            self.currentScope.appendIssue(at: self.token.location,message: "'<' was expected but \(self.token) was found.")
            }
        let value = try closure()
        if self.token.isRightBrocket
            {
            try self.nextToken()
            }
        else
            {
            self.currentScope.appendIssue(at: self.token.location,message:"'>' was expected but \(self.token) was found.")
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
                self.tokenRenderer.setKind(.genericClassParameter,ofToken: self.token)
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
    private func parseMethodInstance() throws -> MethodInstance
        {
        try self.nextToken()
        let location = self.token.location
        self.tokenRenderer.setKind(.method,ofToken: self.token)
        let name = try self.parseLabel()
        let instance = StandardMethodInstance(label: name)
        var isGenericMethod = false
        self.enclosingModule.addSymbol(instance)
        self.pushContext(instance)
        instance.setModule(self.enclosingModule)
        var types: Types = []
        var issues = CompilerIssues()
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
        instance.returnType = ArgonModule.shared.void
        if self.token.isRightArrow
            {
            try self.nextToken()
            instance.returnType = try self.parseType(&issues)
            }
        if isGenericMethod
            {
            instance.isGenericMethod = true
            }
        instance.addDeclaration(location)
        instance.appendIssues(issues)
        if var instances = self.currentScope.lookupMethodInstances(name: Name(instance.label))
            {
            instances.removeAll(where: {$0 === instance})
            for methodInstance in instances
                {
                if methodInstance.typeSignature == instance.typeSignature
                    {
                    if methodInstance.isAutoGenerated
                        {
                        self.enclosingModule.removeSymbol(methodInstance)
                        }
                    else
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
        self.popContext()
        if instance.returnType != ArgonModule.shared.void && !instance.block.hasInlineReturnBlock
            {
            self.cancelCompletion()
            instance.appendIssue(at: location,message: "This method has a return value but there is no RETURN statement in the body of the method.")
            }
        return(instance)
        }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                                                                                                                               ///
    ///                                                                                                                                               ///
    /// PARSE EXPRESSIONS INTO EXPRESSION OBJECTS                                                                                                     ///
    ///                                                                                                                                               ///
    ///                                                                                                                                               ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private func parseExpression() throws -> Expression
        {
        let expression = try self.parseParenthesisExpression()
        return(expression)
        }
        
    private func parseParenthesisExpression() throws -> Expression
        {
        let expression = try self.parseSlotExpression()
//        if self.token.isLeftPar && expression.isLiteralExpression
//            {
//            let literal = expression as! LiteralExpression
//            if literal.isClassLiteral
//                {
//                let arguments = try self.parseParentheses
//                    {
//                    try self.parseArguments()
//                    }
//                let aClass = literal.classLiteral.type!
//                return(TypeInstanciationTerm(type: aClass, arguments: arguments))
//                }
//            }
        return(expression)
        }

    private func parseSlotExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseInfixExpression()
        lhs.addDeclaration(location)
        while self.token.isHashStringLiteral
            {
            let methodInstance = self.enclosingMethodInstance
//            if !methodInstance.isPotentialSlotReader
//                {
//                self.cancelCompletion()
//                lhs.appendIssue(at: location,message:"Raw slot access using '->' is only allowed in slot readers and slot writers.")
//                }
            let selector = self.token.hashStringLiteral
            try self.nextToken()
//            if let slot = lhs.lookup(label: selector.withoutHash)
//                {
//                }
//            else
//                {
//                }
            let accessor = SlotAccessExpression(lhs,slotLabel: selector)
//            if methodInstance.isPotentialSlotReader
//                {
//                accessor.isSlotReader = true
//                }
//            else if methodInstance.isPotentialSlotWriter
//                {
//                accessor.isSlotWriter = true
//                }
            lhs = accessor
//            try self.nextToken()
//            if lhs.isEnumerationCaseExpression && lhs.enumerationCase.hasAssociatedValues && self.token.isLeftPar
//                {
//                lhs = try self.parseAssociatedTypes(in: lhs)
//                }
            }
        return(lhs)
        }
        
//    private func parseAssociatedTypes(in expression: Expression) throws -> Expression
//        {
//        let location = self.token.location
//        let aCase = expression.enumerationCase
//        let types = aCase.associatedTypes
//        var values = Expressions()
//        var isInducing = false
//        var variableNames = Array<String>()
//        try self.parseParentheses
//            {
//            repeat
//                {
//                try self.parseComma()
//                if self.token.isIdentifier && isInducing
//                    {
//                    variableNames.append(self.token.identifier)
//                    try self.nextToken()
//                    }
//                else if self.token.isIdentifier && self.currentScope.lookup(label: self.token.identifier).isNil
//                    {
//                    isInducing = true
//                    variableNames.append(self.token.identifier)
//                    try self.nextToken()
//                    }
//                else
//                    {
//                    values.append(try self.parseExpression())
//                    }
//                }
//            while self.token.isComma
//            }
//        if isInducing
//            {
//            let newLeft = AssociatedValueInductionExpression(expression,variableNames)
//            for slot in newLeft.slots
//                {
//                self.addSymbol(slot)
//                }
//            if newLeft.enumerationCase.associatedTypes.count != newLeft.slots.count
//                {
//                fatalError()
//                }
//            return(newLeft)
//            }
//        if values.count != types.count
//            {
//            self.cancelCompletion()
//            expression.appendIssue(at: location,message: "The enumeration case \(aCase.label) expected \(types.count) associated values be found \(values.count).")
//            }
//        return(EnumerationInstanceExpression(lhs: expression,enumerationCase: aCase,associatedValues: values))
//        }
        
//    private func parseIncDecExpression() throws -> Expression
//        {
//        let location = self.token.location
//        let expression = try self.parseInfixExpression()
//        expression.addDeclaration(location)
//        if self.token.isPlusPlus || self.token.isMinusMinus
//            {
//            let operatorLabel = self.token.operator.name
//            if let operations = self.currentScope.lookupPostfixOperatorInstances(label: operatorLabel)
//                {
//                try self.nextToken()
//                if !(expression is SlotExpression)
//                    {
//                    self.cancelCompletion()
//                    expression.appendIssue(at: location, message: "Postfix increment or decrement operators can only be performed on slots.")
//                    return(expression)
//                    }
//                else
//                    {
//                    let slotExpression = expression as! SlotExpression
//                    return(PostfixExpression(operatorLabel: operatorLabel,operators: operations,lhs: slotExpression))
//                    }
//                }
//            else
//                {
//                expression.appendIssue(at: location, message: "Operator '\(operatorLabel)' could not be resolved.")
//                }
//            }
//        return(expression)
//        }
        
    private func parseInfixExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseBooleanExpression()
        lhs.addDeclaration(location)
        while self.token.isOperator,let operators = self.currentScope.lookupInfixOperatorInstances(label: self.token.operator.name)
            {
            let infixLabel = self.token.operator.name
            try self.nextToken()
            let rhs = try self.parseBooleanExpression()
            lhs = InfixExpression(operatorLabel: infixLabel,operators: operators,lhs: lhs,rhs: rhs)
            lhs.addDeclaration(location)
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
            lhs = BooleanExpression(lhs,symbol,try self.parseComparisonExpression())
            lhs.addDeclaration(location)
            }
        return(lhs)
        }
        
    private func parseComparisonExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parseArithmeticExpression()
        lhs.addDeclaration(location)
        if self.token.isLeftBrocket || self.token.isLeftBrocketEquals || self.token.isEquals || self.token.isRightBrocket || self.token.isRightBrocketEquals || self.token.isNotEquals
            {
            let symbol = self.token.symbol
            try self.nextToken()
            let rhs = try self.parseArithmeticExpression()
            lhs = ComparisonExpression(lhs, symbol, rhs)
            lhs.addDeclaration(location)
            return(lhs)
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
            let rhs = try self.parseMultiplicativeExpression()
            let binary = BinaryExpression(lhs, symbol, rhs)
            if let instances = self.currentScope.lookupN(label: symbol.rawValue) as? MethodInstances
                {
                binary.methodInstances = instances
                }
            lhs = binary
            lhs.addDeclaration(location)
            }
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
            let binary = BinaryExpression(lhs, symbol, rhs)
            if let instances = self.currentScope.lookupN(label: symbol.rawValue) as? MethodInstances
                {
                binary.methodInstances = instances
                }
            lhs = binary
            lhs.addDeclaration(location)
            }
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
            let binary = BinaryExpression(lhs, symbol, rhs)
            if let instances = self.currentScope.lookupN(label: symbol.rawValue) as? MethodInstances
                {
                binary.methodInstances = instances
                }
            lhs = binary
            lhs.addDeclaration(location)
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
            let rhs = try self.parseUnaryExpression()
            let binary = BinaryExpression(lhs, symbol, rhs)
            if let instances = self.currentScope.lookupN(label: symbol.rawValue) as? MethodInstances
                {
                binary.methodInstances = instances
                }
            lhs = binary
            lhs.addDeclaration(location)
            }
        return(lhs)
        }
        
    private func parseUnaryExpression() throws -> Expression
        {
        if self.token.isSub || self.token.isBitNot || self.token.isNot || self.token.isBitAnd || self.token.isMul
            {
            let symbol = self.token.symbol
            try self.nextToken()
            return(UnaryExpression(symbol,try self.parseOperatorExpression()))
            }
        else
            {
            let location = self.token.location
            let term = try self.parseOperatorExpression()
            term.addDeclaration(location)
            return(term)
            }
        }
        
    private func parseOperatorExpression() throws -> Expression
        {
        let location = self.token.location
        var prefixOperators = PrefixOperatorInstances()
        var issues = CompilerIssues()
        var prefixLabel:Label = ""
        if self.token.isOperator
            {
            prefixLabel = self.token.operator.name
            if let operations = self.currentScope.lookupPrefixOperatorInstances(label: prefixLabel)
                {
                prefixOperators = operations
                }
            else
                {
                self.cancelCompletion()
                issues.append(CompilerIssue(location: location,message: "Prefix operator '\(prefixLabel)' found but that operator can not be resolved."))
                }
            try self.nextToken()
            }
        var expression = try self.parseIndexedExpression()
        expression.appendIssues(issues)
        expression = prefixOperators.isEmpty ? expression : PrefixExpression(operatorLabel: prefixLabel,operators: prefixOperators,rhs: expression)
        var postfixOperators = PostfixOperatorInstances()
        var postfixLabel:Label = ""
        if self.token.isOperator,let operations = self.currentScope.lookupPostfixOperatorInstances(label: self.token.operator.name)
            {
            postfixLabel = self.token.operator.name
            postfixOperators = operations
            try self.nextToken()
            }
        expression = postfixOperators.isEmpty ? expression : PostfixExpression(operatorLabel: postfixLabel,operators: postfixOperators,lhs: expression)
        expression.addDeclaration(location)
        return(expression)
        }
        
    private func parseIndexedExpression() throws -> Expression
        {
        let location = self.token.location
        var lhs = try self.parsePrimary()
        lhs.addDeclaration(location)
        while self.token.isLeftBracket
            {
            try self.nextToken()
            let rhs = try self.parseExpression()
            if !self.token.isRightBracket
                {
                lhs.appendIssue(at: location,message: "']' expected but \(self.token) was found.")
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
        var issues = CompilerIssues()
        repeat
            {
            if !self.token.isRightBracket
                {
                try self.parseComma()
                let expression = try self.parseExpression()
                if !expression.isLiteralExpression
                    {
                    self.cancelCompletion()
                    issues.append(CompilerIssue(location: location,message: "A literal expression was expected."))
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
            issues.append(CompilerIssue(location: location,message: "']' expected to terminate array literal."))
            }
        try self.nextToken()
        return(LiteralExpression(.array(Argon.addStatic(StaticArray(elements)))).appendIssues(issues))
        }
        
    private func parsePrimary() throws -> Expression
        {
        if self.token.isMake
            {
            try self.nextToken()
            let expression = try self.parseParentheses
                {
                () -> MakeTerm in
                var issues = CompilerIssues()
                let type = try self.parseType(&issues)
                var args = Arguments()
                while !self.token.isRightPar
                    {
                    try self.parseComma()
                    args.append(try self.parseArgument())
                    }
                let make = MakeTerm(type: type,arguments: args)
                make.appendIssues(issues)
                return(make)
                }
            return(expression)
            }
        else if self.token.isCast
            {
            try self.nextToken()
            let result = try self.parseParentheses
                {
                () -> CastExpression in
                let expression = try self.parseExpression()
                try self.parseComma()
                var issues = CompilerIssues()
                let type = try self.parseType(&issues)
                return(CastExpression(expression: expression,type: type).appendIssues(issues)) as! CastExpression
                }
            return(result)
            }
        else if self.token.isLeftBracket
            {
//            return(try self.parseGeneratorSet())
            return(try self.parseArrayLiteral())
            }
        else if self.token.isCast
            {
            let location = self.token.location
            try self.nextToken()
            var expression = Expression()
            var targetType:Type = ArgonModule.shared.void
            var issues = CompilerIssues()
            try self.parseParentheses
                {
                expression = try self.parseExpression()
                try self.parseComma()
                targetType = try self.parseType(&issues)
                }
            let cast = CastExpression(expression: expression,type: targetType)
            cast.addDeclaration(location)
            cast.appendIssues(issues)
            return(cast)
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
        else if self.token.isFloatingPointLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.float(self.lastToken.floatingPointLiteral)))
            }
        else if self.token.isStringLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.string(Argon.addStatic(StaticString(string: self.lastToken.stringLiteral)))))
            }
        else if self.token.isHashStringLiteral
            {
            try self.nextToken()
            return(LiteralExpression(.symbol(Argon.addStatic(StaticSymbol(string: self.lastToken.hashStringLiteral)))))
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
            let location = self.token.location
            try self.nextToken()
            let expression = try self.parseExpression()
            if expression.isUnresolved
                {
                let tuple = TupleExpression()
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
                    expression.appendIssue(at: location,message: "']' expected after destructing tuple.",isWarning: true)
                    }
                return(tuple)
                }
            else if self.token.isComma && expression.isLiteralExpression
                {
                var array = Array<Literal>()
                array.append((expression as! LiteralExpression).literal)
                while self.token.isComma
                    {
                    try self.parseComma()
                    let expr = try self.parseExpression()
                    if expr.isLiteralExpression
                        {
                        array.append((expr as! LiteralExpression).literal)
                        }
                    else
                        {
                        expression.appendIssue(at: location,message: "A literal value was expected as part of the literal array.")
                        return(LiteralExpression(.array(Argon.addStatic(StaticArray(array)))))
                        }
                    }
                if self.token.isRightBracket
                    {
                    try self.nextToken()
                    }
                else
                    {
                    expression.appendIssue(at: location,message: "']' expected after array literal.",isWarning: true)
                    }
                return(LiteralExpression(.array(Argon.addStatic(StaticArray(array)))))
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
                    let tuple = TupleExpression()
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
//        else if self.token.isSelf
//            {
//            try self.nextToken()
//            return(PseudoVariableExpression(.vSelf,self.currentContext.enclosingClass))
//            }
//        else if self.token.isSELF
//            {
//            try self.nextToken()
//            return(PseudoVariableExpression(.vSELF))
//            }
//        else if self.token.isSuper
//            {
//            try self.nextToken()
//            return(PseudoVariableExpression(.vSuper))
//            }
        else
            {
            let expression = Expression()
            expression.appendIssue(at: self.token.location,message: "This expression is invalid.")
            try self.nextToken()
            return(expression)
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
        
//    private func parseSlotSelectorExpression() throws -> Expression
//        {
//        self.tokenRenderer.setKind(.classSlot,ofToken: self.token)
//        let location = self.token.location
//        let first = try self.parseLabel()
//        let lhs = SlotSelectorExpression(selector: first)
//        lhs.addDeclaration(location)
//        return(lhs)
//        }
        
//    private func parseTypeInvocation(type: Type,name:Name,nameToken: Token,location: Location) throws -> Expression
//        {
//        if type.isClass
//            {
//            self.tokenRenderer.setKind(.class,ofToken: nameToken)
//            if type.isSystemClass
//                {
//                self.tokenRenderer.setKind(.systemClass,ofToken: nameToken)
//                }
//            var issues = CompilerIssues()
//            let someTypes = try self.parseTypeArguments(&issues)
//            if self.token.isLeftPar
//                {
//                var newType:Type
//                if type.isGenericClass
//                    {
//                    newType = Argon.addType(TypeClass(class: (type as! TypeClass).theClass,generics: someTypes))
//                    }
//                else
//                    {
//                    if !someTypes.isEmpty
//                        {
//                        self.currentScope.appendIssue(at: location, message: "Found generic types but none were expected.")
//                        }
//                    newType = type
//                    }
//                return(try self.parseInstanciationTerm(ofType: newType))
//                }
//            return(LiteralExpression(Literal.class((type as! TypeClass).theClass)))
//            }
//        else if type.isEnumeration
//            {
//            self.tokenRenderer.setKind(.enumeration,ofToken: nameToken)
//            var issues = CompilerIssues()
//            let someTypes = try self.parseTypeArguments(&issues)
//            let newType = Argon.addType(TypeEnumeration(enumeration: (type as! TypeEnumeration).enumeration,generics: someTypes))
//            if self.token.isLeftPar
//                {
//                return(try self.parseInstanciationTerm(ofType: newType))
//                }
//            return(LiteralExpression(Literal.enumeration((type as! TypeEnumeration).enumeration)))
//            }
//        else
//            {
//            let expression = Expression()
//            expression.appendIssue(at: location, message: "'\(name.displayString)' was expected to be a class or an enumeration but was neither.")
//            return(expression)
//            }
//        }
        
    private func parseMethodInvocation(methods:MethodInstances,name:Name,nameToken: Token,location: Location) throws -> Expression
        {
        if name.last == "name"
            {
            print("HALT")
            }
        self.tokenRenderer.setKind(.methodInvocation,ofToken: nameToken)
        let arguments = try parseParentheses
            {
            try self.parseArguments()
            }
        let argumentTags = arguments.map{$0.tag.isNotNil ? $0.tag! + "::" : "_::"}
        let argumentNames = argumentTags.joined(separator: ",")
        let methodName = "\(name.last)(\(argumentNames))"
        let selectedMethods = methods.filter{$0.methodName == methodName}
        let expression = MethodInvocationExpression(methodInstances: methods, arguments: arguments)
        if selectedMethods.isEmpty
            {
            expression.appendIssue(at: location, message: "There are no methods that match the signature of this invocation.")
            }
        expression.addDeclaration(location)
        let count = arguments.count
        let instancesWithArity = methods.filter{$0.parameters.count == count}
        if instancesWithArity.isEmpty
            {
            expression.appendIssue(at: location, message: "\(count) arguments were found, but there is no instance of method '\(methods.first!.label)' that has '\(count)' parameters.")
            return(expression)
            }
        for instance in instancesWithArity
            {
            if instance.parametersMatchArguments(arguments,for: expression,at: location)
                {
                return(expression)
                }
            }
        expression.appendIssue(at: location, message: "There are no instances of method '\(methods.first!.label)' with parameters that match these arguments.")
        return(expression)
        }
        
    private func parseIdentifierTerm() throws -> Expression
        {
        let location = self.token.location
        let nameToken = self.token
        let name = try self.parseName()
        if self.token.isLeftPar
            {
            if let methods = self.currentScope.lookupMethodInstances(name: name)
                {
                return(try self.parseMethodInvocation(methods: methods,name:name,nameToken:nameToken,location: location))
                }
//            else if let types = self.currentScope.lookupTypes(name: name)
//                {
//                self.tokenRenderer.setKind(.type,ofToken: nameToken)
//                let type = types.first!
//                return(try self.parseTypeInvocation(type: type,name: name,nameToken: nameToken,location: location))
//                }
            else if let functions = self.currentScope.lookupFunctions(name: name)
                {
                let arguments = try parseParentheses
                    {
                    try self.parseArguments()
                    }
                let expression = FunctionInvocationExpression(function: functions.first!, arguments: arguments)
                expression.addDeclaration(location)
                return(expression)
                }
            else if let slot = self.currentScope.lookup(name: name) as? Slot
                {
                let arguments = try parseParentheses
                    {
                    try self.parseArguments()
                    }
                let expression = SlotInvocationExpression(slot: slot,arguments: arguments)
                expression.addDeclaration(location)
                return(expression)
                }
            else
                {
                let expression = Expression()
                expression.appendIssue(at: location, message: "A method labeled '\(name.displayString)' can not be resolved.")
                return(expression)
                }
            }
        if let enumeration  = self.currentScope.lookupEnumeration(name: name)
            {
            if self.token.isHashStringLiteral
                {
                let symbol = self.token.hashStringLiteral
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
                        expression.appendIssue(at: location, message: "'=' was expected after a destructuring enumeration.")
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
        if let types = self.currentScope.lookupTypes(name: name)
            {
            if self.token.isLeftBrocket
                {
                let type = types.first!
                if type.isClass
                    {
                    var issues = CompilerIssues()
                    let someTypes = try self.parseTypeArguments(&issues)
//                    let newType = Argon.addType(TypeClass(label: type.label,isSystem: type.isSystemClass,generics: someTypes))
//                    if self.token.isLeftPar
//                        {
//                        return(try self.parseInstanciationTerm(ofType: newType))
//                        }
                    if !someTypes.isEmpty
                        {
                        let newType = type.withGenerics(someTypes)
                        return(SymbolTerm(type: newType))
                        }
                    return(SymbolTerm(type: type))
                    }
                else if type.isEnumeration
                    {
                    var issues = CompilerIssues()
                    let someTypes = try self.parseTypeArguments(&issues)
                    let newType = type.withGenerics(someTypes)
                    return(SymbolTerm(type: newType))
                    }
                else
                    {
                    let expression = Expression()
                    expression.appendIssue(at: location, message: "'\(name.displayString)' was expected to be a class or an enumeration but was neither.")
                    return(expression)
                    }
                }
            else
                {
                let type = types.first!
                if type.isClass
                    {
                    return(SymbolTerm(type: type))
                    }
                else if type.isEnumeration
                    {
                    return(SymbolTerm(type: type))
                    }
                else
                    {
                    let expression = Expression()
                    expression.appendIssue(at: location, message: "This type can not be used as a literal value.")
                    return(expression)
                    }
                }
            }
        if let aSymbol = self.currentScope.lookup(name: name)
            {
            ///
            /// Or a Module ?
            ///
            if let symbol = aSymbol as? Module
                {
                let term = SymbolTerm(module: symbol)
                term.addDeclaration(location)
                return(term)
                }
            ///
            /// Or a Constant ?
            ///
            else if let symbol = aSymbol as? Constant
                {
                return(SymbolTerm(constant: symbol))
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
                        expression.addDeclaration(location)
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
                expression.addDeclaration(location)
                return(expression)
                }
            ///
            /// Or a Function ?
            ///
            else if let symbol = aSymbol as? Function
                {
//                return(SymbolTerm(symbol: symbol))
                fatalError()
                }
            }
        ///
        /// Or a "we don't have a fucking clue so we'll make it a slot"
        ///
        var type: Type = TypeContext.freshTypeVariable()
        var issues = CompilerIssues()
        if self.token.isGluon
            {
            try self.nextToken()
            type = try self.parseType(&issues)
            }
        let localSlot = LocalSlot(label: name.last,type: type,value: nil)
        self.currentScope.addLocalSlot(localSlot)
        let term = LocalSlotExpression(slot: localSlot)
        term.appendIssues(issues)
        localSlot.addDeclaration(location)
        term.addDeclaration(location)
        return(term)
        }
        
    private func parseClosureTerm() throws -> Expression
        {
        let closure = Closure(label: Argon.nextName("1_CLOSURE"))
        closure.returnType = ArgonModule.shared.void
        let location = self.token.location
        var issues = CompilerIssues()
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
                closure.returnType = try self.parseType(&issues)
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
        closure.addDeclaration(location)
        return(ClosureExpression(closure:closure).appendIssues(issues))
        }
        
    private func parseInvocationTerm(methodInstances: MethodInstances) throws -> Expression
        {
        let location = self.token.location
        let args = try self.parseParentheses
            {
            try self.parseArguments()
            }
        let expression = MethodInvocationExpression(methodInstances: methodInstances,arguments: args)
        expression.addDeclaration(location)
        return(expression)
        }
        
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
//        invocation.addDeclaration(location)
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
        if try self.token.isIdentifier && self.peekToken1().isGluon
            {
            let tag = token.identifier
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
            else if self.token.isSelf || self.token.isSELF || self.token.isSuper
                {
                block.addBlock(ExpressionBlock(try self.parseExpression()))
                }
            else
                {
                self.currentScope.appendIssue(at: self.token.location,message: "A statement was expected but \(self.token) was found.")
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
                self.currentScope.appendIssue(at: location, message: "Integer literal primitive index expected.")
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
//        self.startClip()
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
                    selectBlock.appendIssue(at: location,message: "WHEN expected after SELECT clause")
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
//        self.stopClip(into: selectBlock)
        }
        
    private func parseElseIfBlock(into block: IfBlock) throws
        {
//        self.startClip()
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
//        self.stopClip(into: statement)
        }
        
    private func parseIfBlock(into block: Block) throws
        {
//        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let expression = try self.parseExpression()
        let statement = IfBlock(condition: expression)
        if expression is EnumerationDecompositionExpression
            {
            (expression as! EnumerationDecompositionExpression).block = statement
            }
        block.addBlock(statement)
        statement.addDeclaration(location)
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
//        self.stopClip(into: statement)
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
            let symbol = self.token.operator
            try self.nextToken()
            lhs = AssignmentOperatorExpression(lhs, symbol, try self.parseExpression())
            }
        else if self.token.isAssign
            {
            if lhs.isReadOnlyExpression
                {
                self.cancelCompletion()
                self.dispatchError(at: location,message: "A read only slot can not be assigned to.")
                }
            try self.nextToken()
            let rhs = try self.parseExpression()
            lhs = AssignmentExpression(lhs, rhs)
            }
        lhs.addDeclaration(location)
        let stop = self.token.location.tokenStop
        let newBlock = ExpressionBlock(lhs)
        newBlock.source = self.source?.substring(with: start..<stop + 1) ?? ""
        newBlock.addDeclaration(location)
        block.addBlock(newBlock)
        }
        
    private func parseLetBlock(into block: Block) throws
        {
//        self.startClip()
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
                self.dispatchError(at: location,message: "LET assignment can only be done to an uninitialized slot, '\(label)' is already defined.")
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
            self.dispatchError(at: location,message: "An identifier or a tuple was expected after LET but \(self.token) was found.")
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
        statement.addDeclaration(location)
//        self.stopClip(into: statement)
        }
        
    private func parseReturnBlock(into block: Block) throws
        {
//        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let value = try self.parseParentheses
            {
            () -> Expression? in
            if self.token.isRightPar
                {
                return(nil)
                }
            return(try self.parseExpression())
            }
        let returnBlock = ReturnBlock(expression: value)
        returnBlock.addDeclaration(location)
        block.addBlock(returnBlock)
//        self.stopClip(into: returnBlock)
        }
        
    private func parseWhileBlock(into block: Block) throws
        {
//        self.startClip()
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
//        self.stopClip(into: block)
        }
        
    private func parseInductionVariable() throws
        {
        }
        
    private func parseForkBlock(into block: Block) throws
        {
//        self.startClip()
//        let location = self.token.location
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
//                self.dispatchError(at: location,"A closure or a variable containing a closure was expected in a fork block.")
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
    
//    private func startClip()
//        {
//        self.textStart = self.token.location.tokenStart
//        }
//
//    private func stopClip(into block: Block)
//        {
//        let stop = self.token.location.tokenStop
//        if self.source.isNotNil
//            {
//            block.source = self.source!.substring(with: self.textStart..<stop + 1)
//            }
//        }
//
//    private func stopClip(into symbol: Symbol)
//        {
//        let stop = self.token.location.tokenStop
//        if self.source.isNotNil
//            {
//            symbol.source = self.source!.substring(with: self.textStart..<stop + 1)
//            }
//        }
        
        
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
//        self.startClip()
        try self.nextToken()
        let location = self.token.location
        let statement = LoopBlock()
        self.pushContext(statement)
        let (start,end,update) = try self.parseLoopConstraints()
        statement.startExpressions = start
        statement.endExpression = end
        statement.updateExpressions = update
        statement.addDeclaration(location)
        block.addBlock(statement)
        try self.parseBraces
            {
            try self.parseBlock(into: statement)
            }
        self.popContext()
        if statement.isEmpty
            {
            statement.appendIssue(at: location, message: "LOOP block does nothing and can be removed.",isWarning: true)
            }
//        self.stopClip(into: statement)
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
            lhs.addDeclaration(self.token.location)
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
                self.reportingContext.dispatchError(at: self.token.location, message: "';' was expected between LOOP clauses.")
                }
            try self.nextToken()
            if !self.token.isSemicolon
                {
                end = try self.parseExpression()
                if !self.token.isSemicolon
                    {
                    self.reportingContext.dispatchError(at: self.token.location, message: "';' was expected between LOOP clauses.")
                    }
                try self.nextToken()
                }
            if !self.token.isRightPar
                {
                repeat
                    {
                    try self.parseComma()
                    update.append(try self.parseExpression())
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
                self.currentScope.appendIssue(at: location,message:"Symbol expected but \(self.token) was found instead.")
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
        var type:Type = ArgonModule.shared.void
        var issues = CompilerIssues()
        if !self.token.isGluon && self.token.isIdentifier
            {
            relabel = try self.parseLabel()
            }
        if !self.token.isGluon
            {
            issues.appendIssue(at: location, message: "Gluon expected after tag/tag label.")
            }
        try self.nextToken()
        if self.token.isFullRange
            {
            try self.nextToken()
            isVariadic = true
            }
        else
            {
            type = try self.parseType(&issues)
            }
        let parameter = Parameter(label: tag, relabel: relabel,type: type,isVisible: !isHidden,isVariadic: isVariadic)
        parameter.appendIssues(issues)
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
        var issues = CompilerIssues()
        if self.token.isRightArrow
            {
            try self.nextToken()
            function.returnType = try self.parseType(&issues)
            }
        self.addSymbol(function)
        function.appendIssues(issues)
        return(function)
        }
        
    @discardableResult
    private func parseTypeAlias() throws -> TypeAlias
        {
        try self.nextToken()
        let location = self.token.location
        self.tokenRenderer.setKind(.type,ofToken: self.token)
        let label = try self.parseLabel()
        var issues = CompilerIssues()
        if !self.token.isIs
            {
            issues.appendIssue(at: location, message: "IS expeected after new name for type.")
            }
        try self.nextToken()
        let type = try self.parseType(&issues)
        let alias = TypeAlias(label: label,type: type)
        alias.addDeclaration(location)
        self.addSymbol(alias)
        alias.appendIssues(issues)
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
                    handler.appendIssue(at: location,message: "A symbol was expected in the handler clause, but \(self.token) was found.")
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
                handler.appendIssue(at: location,message: "WITH expected in first line of HANDLE clause, but \(self.token) was found.")
                }
            try self.nextToken()
            var name:String = ""
            try self.parseParentheses
                {
                if !self.token.isIdentifier
                    {
                    handler.appendIssue(at: location,message: "The name of an induction variable to contain the symbol this handler is receiving was expected but \(self.token) was found.")
                    }
                name = self.token.isIdentifier ? self.token.identifier : "VariableName"
                handler.addParameter(label: name,type: ArgonModule.shared.symbol)
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
