//
//  Parser.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/9/21.
//

import Foundation

public enum Context: Equatable
    {
    case block(Block)
    case node(Node)
    
    public func addSymbol(_ symbol:Symbol)
        {
        switch(self)
            {
            case .node(let node):
                node.addSymbol(symbol)
            case .block(let block):
                block.addSymbol(symbol)
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
    public var topModule: TopModule
        {
        return(self.compiler.topModule)
        }
        
    public var virtualMachine: VirtualMachine
        {
        return(self.compiler.virtualMachine)
        }
        
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
    
    public static func parseChunk(_ source:String,in compiler:Compiler) -> ParseNode?
        {
        Parser(compiler: compiler).parseChunk(source)
        }
        
    init(compiler:Compiler)
        {
        self.compiler = compiler
        self.namingContext = compiler.namingContext
        self.visualToken = TokenRenderer(systemClassNames: compiler.systemClassNames)
        }
        
    public var reportingContext:ReportingContext
        {
        return(NullReportingContext.shared)
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    @discardableResult
    public func nextToken() -> Token
        {
        self.lastToken = self.token
        self.token = self.tokens[self.tokenIndex]
        self.visualToken.currentToken = self.token
        self.tokenIndex += 1
        while self.token.isComment || self.token.isInvisible
            {
            self.token = self.tokens[self.tokenIndex]
            self.visualToken.currentToken = self.token
            self.tokenIndex += 1
            }
        print(token)
        return(self.token)
        }
        
    private func peekToken1() -> Token
        {
        return(self.peekToken(0))
        }
        
    private func peekToken2() -> Token
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
        
    @discardableResult
    private func popContext()
        {
        self.currentContext = self.contextStack.pop()
        }
        
    private func initParser(source:String)
        {
        self.source = source
        self.currentContext = .node(self.compiler.topModule)
        let stream = TokenStream(source: source, context: self.reportingContext)
        self.tokens = stream.allTokens(withComments: true, context: self.reportingContext)
        self.nextToken()
        }
        
    public func parseChunk(_ source:String) -> ParseNode?
        {
        self.initParser(source: source)
        let result = self.parsePrivacyModifier
            {
            (scope:PrivacyScope?) -> ParseNode in
            if !self.token.isKeyword
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "KEYWORD expected")
                }
            else
                {
                switch(self.token.keyword)
                    {
                    case .MAIN:
                            return(self.parseMain())
                    case .MODULE:
                            return(self.parseModule())
                    case .CLASS:
                            return(self.parseClass())
                    case .CONSTANT:
                            return(self.parseConstant())
                    case .METHOD:
                            return(self.parseMethod())
                    case .FUNCTION:
                            return(self.parseFunction())
                    case .TYPE:
                            return(self.parseTypeAlias())
                    case .ENUMERATION:
                            return(self.parseEnumeration())
                    default:
                        break
                    }
                }
            return(self.node!)
            }
        return(result)
        }
        
    private func chompKeyword()
        {
        if self.token.isKeyword
            {
            self.nextToken()
            }
        }
        
    private func parseLabel() -> String
        {
        if !self.token.isIdentifier
            {
            self.reportingContext.dispatchWarning(at: self.token.location, message: "An identifier was expected here but \(self.token) was found.")
            return(Argon.nextName("LABEL"))
            }
        let string = self.token.identifier
        self.nextToken()
        return(string)
        }
        
    private func parseName() -> Name
        {
        if self.token.isName
            {
            let name = self.token.nameLiteral
            self.nextToken()
            return(name)
            }
        else if self.token.isIdentifier
            {
            let name = Name(self.token.identifier)
            self.nextToken()
            return(name)
            }
        self.reportingContext.dispatchError(at: self.token.location, message: "A name was expected but a \(self.token) was found.")
        return(Name("error"))
        }
        
    @discardableResult
    private func parsePrivacyModifier(_ closure: (PrivacyScope?) -> ParseNode) -> ParseNode
        {
        let modifier = self.token.isKeyword ? PrivacyScope(rawValue: self.token.keyword.rawValue) : nil
        if self.token.isPrivacyModifier
            {
            self.chompKeyword()
            }
        var value = closure(modifier)
        value.privacyScope = modifier
        return(value)
        }
        
    internal func parseBraces<T>(_ closure: () -> T) -> T
        {
        if !self.token.isLeftBrace
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "'{' expected but a '\(self.token)' was found.")
            }
        else
            {
            self.nextToken()
            }
        let result = closure()
        if !self.token.isRightBrace
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "'}' expected but a '\(self.token)' was found.")
            }
        else
            {
            self.nextToken()
            }
        return(result)
        }
        
    @discardableResult
    private func parseMain() -> ParseNode
        {
        self.nextToken()
        if self.token.isModule
            {
            return(self.parseMainModule())
            }
        else
            {
            return(self.parseMainMethod())
            }
        }
    
    private func parseMainMethod() -> Method
        {
        let method = self.parseMethod()
        method.isMain = true
        return(method)
        }
        
    private func parseMainModule() -> Module
        {
        self.nextToken()
        let label = self.parseLabel()
        let module = MainModule(label: label)
        self.currentContext.addSymbol(module)
        self.parseModule(into: module)
        self.node = module
        return(module)
        }
    
    private func parsePath() -> Token
        {
        if self.token.isPath
            {
            self.visualToken.kind = .path
            self.nextToken()
            return(self.lastToken)
            }
        self.dispatchError("Path expected for a library module but \(self.token) was found.")
        return(.path("",Location.zero))
        }
        
    private func parseModule() -> Module
        {
        let location = self.token.location
        self.nextToken()
        self.visualToken.kind = .module
        let label = self.parseLabel()
        var module:Module = ModuleInstance(label:"")
        module.addDeclaration(location)
        if self.token.isLeftPar
            {
            self.parseParentheses
                {
                let path = self.parsePath().path
                module = LibraryModule(label: label,path: path)
                }
            }
        else
            {
            module = ModuleInstance(label: label)
            }
        self.currentContext.addSymbol(module)
        self.parseModule(into: module)
        self.node = module
        return(module)
        }
        
    private func parseModule(into module:Module)
        {
        self.pushContext(module)
        self.parseBraces
            {
            () -> Void in
            while !self.token.isRightBrace
                {

                if !self.token.isKeyword
                    {
                    self.reportingContext.dispatchError(at: self.token.location, message: "Keyword expected but \(self.token) found")
                    self.nextToken()
                    }
                else
                    {
                    self.parsePrivacyModifier
                        {
                        modifier in
                        switch(self.token.keyword)
                            {
                            case .FUNCTION:
                                    return(self.parseFunction())
                            case .MAIN:
                                    return(self.parseMain())
                            case .MODULE:
                                    return(self.parseModule())
                            case .CLASS:
                                    return(self.parseClass())
                            case .TYPE:
                                    return(self.parseTypeAlias())
                            case .METHOD:
                                    return(self.parseMethod())
                            case .CONSTANT:
                                    return(self.parseConstant())
                            case .SCOPED:
                                    let scoped = self.parseScopedSlot()
                                    module.addSymbol(scoped)
                                    return(scoped)
                            case .ENUMERATION:
                                    return(self.parseEnumeration())
                            case .SLOT:
                                    let slot = self.parseSlot()
                                    module.addSymbol(slot)
                                    return(slot)
                            case .INTERCEPTOR:
                                    let interceptor = self.parseInterceptor()
                                    module.addSymbol(interceptor)
                                    return(interceptor)
                            default:
                                self.reportingContext.dispatchError(at: self.token.location, message: "A declaration for a module element was expected but \(self.token) was found.")
                                self.nextToken()
                                return(Symbol(label:""))
                            }
                        }
                    }
                }
            }
        self.popContext()
        }
        
    private func parseInterceptor() -> Interceptor
        {
        return(Interceptor(label:"Interceptor",parameters: []))
        }
        
    private func parseScopedSlot() -> ScopedSlot
        {
        return(ScopedSlot(label:"Slot",type: self.topModule.argonModule.integer))
        }
        
    private func parseHashString() -> String
        {
        if self.token.isHashStringLiteral
            {
            let string = self.token.hashStringLiteral
            self.nextToken()
            return(string)
            }
        self.reportingContext.dispatchError(at: self.token.location, message: "A symbol was expected but \(self.token) was found.")
        self.nextToken()
        return("#HashString")
        }
        
    private func parseEnumeration() -> Enumeration
        {
        self.startClip()
        self.nextToken()
        let location = self.token.location
        let label = self.parseLabel()
        let enumeration = Enumeration(label: label)
        enumeration.rawType = self.topModule.argonModule.integer
        self.currentContext.addSymbol(enumeration)
        self.pushContext(enumeration)
        enumeration.addDeclaration(location)
        if self.token.isGluon
            {
            self.nextToken()
            let type = self.parseType()
            enumeration.rawType = type
            }
        self.parseBraces
            {
            () -> Void in
            while !self.token.isRightBrace
                {
                self.parseCase(into: enumeration)
                }
            }
        self.popContext()
        self.stopClip(into:enumeration)
        return(enumeration)
        }
        
    private func parseLiteral() -> LiteralExpression
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
        self.nextToken()
        return(literal)
        }
        
    private func parseCase(into enumeration: Enumeration)
        {
        self.startClip()
        let location = self.token.location
        let name = self.parseHashString()
        var types = Array<Class>()
        if self.token.isLeftPar
            {
            self.parseParentheses
                {
                repeat
                    {
                    self.parseComma()
                    let type = self.parseType()
                    types.append(type)
                    }
                while self.token.isComma
                }
            }
        let aCase = EnumerationCase(symbol: name,types: types,enumeration: enumeration)
        enumeration.addSymbol(aCase)
        aCase.addDeclaration(location)
        if self.token.isAssign
            {
            self.nextToken()
            aCase.rawValue = self.parseLiteral()
            }
        self.stopClip(into: aCase)
        }
        
    private func parseSlot() -> Slot
        {
        self.nextToken()
        self.visualToken.kind = .classSlot
        let location = self.token.location
        let label = self.parseLabel()
        var type: Class?
        if self.token.isGluon
            {
            self.nextToken()
            type = self.parseType()
            }
        var initialValue:Expression?
        if self.token.isAssign
            {
            self.nextToken()
            initialValue = self.parseExpression()
            }
        var readBlock:VirtualReadBlock?
        var writeBlock:VirtualWriteBlock?
        if self.token.isLeftBrace
            {
            self.parseBraces
                {
                if self.token.isRead
                    {
                    readBlock = VirtualReadBlock()
                    self.parseBlock(into: readBlock!)
                    }
                if self.token.isWrite
                    {
                    writeBlock = VirtualWriteBlock()
                    self.parseBlock(into: writeBlock!)
                    }
                }
            }
        var slot: Slot?
        if readBlock.isNotNil
            {
            let aSlot = VirtualSlot(label: label,type: type ?? VoidClass.voidClass)
            aSlot.addDeclaration(location)
            aSlot.writeBlock = writeBlock
            aSlot.readBlock = readBlock
            slot = aSlot
            }
        else
            {
            slot = Slot(label: label,type: type ?? VoidClass.voidClass)
            slot?.addDeclaration(location)
            }
        slot!.initialValue = initialValue
        return(slot!)
        }
        
    private func parseClassSlot() -> Slot
        {
        self.nextToken()
        let slot = self.parseSlot()
        slot.isClassSlot = true
        return(slot)
        }
        
    private func parseClassParameters() -> Classes
        {
        let typeParameters = self.parseBrockets
            {
            () -> Classes in
            var types = Classes()
            repeat
                {
                self.parseComma()
                let name = self.parseName()
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
    private func parseClass() -> Class
        {
        self.nextToken()
        let location = self.token.location
        self.visualToken.kind = .class
        let label = self.parseLabel()
        var parameters = Classes()
        if self.token.isLeftBrocket
            {
            parameters = self.parseClassParameters()
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
        if parameters.filter{$0.isGenericClassParameter}.count > 0
            {
            let classParameters = parameters.filter{$0.isGenericClassParameter}.map{$0 as! GenericClassParameter}
            if parameters.count != classParameters.count
                {
                self.cancelCompletion()
                self.dispatchError("Class \(label) can not be half instanciated, either all of the class parameters must be classes or none of them.")
                }
            }
        aClass.addDeclaration(location)
        self.currentContext.addSymbol(aClass)
        self.pushContext(aClass)
        if self.token.isGluon
            {
            self.nextToken()
            repeat
                {
                self.parseComma()
                self.visualToken.kind = .class
                let otherClassName = self.parseName()
                let forwardClass = ForwardReferenceClass(name: otherClassName, context: self.currentContext)
                forwardClass.addDeclaration(location)
                aClass.superclassReferences.append(forwardClass)
                }
            while self.token.isComma
            }
        self.parseBraces
            {
            while self.token.isSlot || self.token.isClass
                {
                if self.token.isSlot
                    {
                    let slot = self.parseSlot()
                    aClass.addSymbol(slot)
                    }
                else if self.token.isClass
                    {
                    let slot = self.parseClassSlot()
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
    private func parseConstant() -> Constant
        {
        let location = self.token.location
        self.nextToken()
        self.visualToken.kind = .constant
        let label = self.parseLabel()
        var type:Class = VoidClass.voidClass
        if self.token.isGluon
            {
            self.parseGluon()
            type = self.parseType()
            }
        if !self.token.isAssign
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "'=' expected to follow the declaration of a CONSTANT.")
            }
        self.nextToken()
        let value = self.parseExpression()
        let constant = Constant(label: label,type: type,value: value)
        constant.addDeclaration(location)
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
        
    internal func parseParentheses<T>(_ closure: () -> T)  -> T
        {
        if !self.token.isLeftPar
            {
            self.dispatchError("'(' was expected but \(self.token) was found.")
            }
        else
            {
            self.nextToken()
            }
        let value = closure()
        if !self.token.isRightPar
            {
            self.dispatchError("')' was expected but \(self.token) was found.")
            }
        else
            {
            self.nextToken()
            }
        return(value)
        }
        
    private func parseComma()
        {
        if self.token.isComma
            {
            self.nextToken()
            }
        }
        
    private func parseGluon()
        {
        if !self.token.isGluon
            {
            self.dispatchError("'::' was expected but '\(self.token)' was found.")
            }
        else
            {
            self.nextToken()
            }
        }
        
    private func parseType() -> Class
        {
        let location = self.token.location
        var name:Name
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
            }
        else if self.token.isName
            {
            self.visualToken.kind = .type
            name = self.token.nameLiteral
            }
        else if self.token.isLeftPar
            {
            return(self.parseMethodType())
            }
        else
            {
            self.dispatchError("A type name was expected but \(self.token) was found.")
            name = Name()
            }
        self.nextToken()
        if name == Name("\\\\Argon\\Array")
            {
            ///
            ///
            /// At this stage do nothing but at a later stage we need to add
            /// in the parsing of the more exotic array dimensions
            ///
            ///
            }
        let parameters = self.parseTypeParameters()
        if let symbol = self.currentContext.lookup(name: name)
            {
            if symbol.isEnumeration
                {
                symbol.addReference(location)
                return(symbol as! Class)
                }
            else if symbol.isClassParameter
                {
                symbol.addReference(location)
                return(symbol as! Class)
                }
            else if symbol.isClass
                {
                var clazz = symbol as! Class
                if !clazz.isGenericClass && !parameters.isEmpty
                    {
                    self.reportingContext.dispatchError(at: location, message: "Class '\(name)' is not a parameterized class but there are class parameters defined for it.")
                    self.nextToken()
                    }
                else if clazz.isGenericClass && !parameters.isEmpty
                    {
                    clazz = (clazz as! GenericClass).instanciate(withTypes: parameters, reportingContext: self.reportingContext)
                    }
                clazz.addReference(location)
                return(clazz)
                }
            else
                {
                self.reportingContext.dispatchError(at: location, message: "A type was expected but was not found, the identifier '\(name)' was found.")
                self.nextToken()
                return(Class(label:""))
                }
            }
        if name.isEmpty
            {
            self.reportingContext.dispatchError(at: location, message: "An invalid type reference was encountered.")
            name = Name("1_name")
            }
        let clazz = ForwardReferenceClass(name: name,context:self.currentContext)
        clazz.addDeclaration(location)
        return(clazz)
        }
        
    private func parseMethodType() -> MethodType
        {
        let location = self.token.location
        let types = self.parseParentheses
            {
            () -> [Class] in
            var types = Classes()
            repeat
                {
                self.parseComma()
                let type = self.parseType()
                types.append(type)
                }
            while self.token.isComma
            return(types)
            }
        if !self.token.isRightArrow
            {
            self.reportingContext.dispatchError(at: location, message: "'->' was expected in a method reference type but '\(self.token)' was found.")
            }
        self.nextToken()
        let returnType = self.parseType()
        let reference = MethodType(label: Argon.nextName("1Method"),types: types,returnType: returnType)
        reference.addDeclaration(location)
        return(reference)
        }
        
    private func parseTypeParameters() -> Classes
        {
        if self.token.isLeftBrocket
            {
            let list = self.parseBrockets
                {
                () -> Classes in
                var list = Classes()
                while !self.token.isRightBrocket
                    {
                    self.parseComma()
                    list.append(self.parseType())
                    }
                return(list)
                }
            return(list)
            }
        return([])
        }
        
    internal func parseBrockets<T>(_ closure: () -> T) -> T
        {
        if self.token.isLeftBrocket
            {
            self.nextToken()
            }
        else
            {
            self.dispatchError("'<' was expected but \(self.token) was found.")
            }
        let value = closure()
        if self.token.isRightBrocket
            {
            self.nextToken()
            }
        else
            {
            self.dispatchError("'>' was expected but \(self.token) was found.")
            }
        return(value)
        }
        
    private func parseParameters() -> Parameters
        {
        let list = self.parseParentheses
            {
            () -> Parameters in
            var parameters = Parameters()
            repeat
                {
                self.parseComma()
                if !self.token.isRightPar
                    {
                    parameters.append(self.parseParameter())
                    }
                }
            while self.token.isComma && !self.token.isRightPar
            return(parameters)
            }
        return(list)
        }
        
    @discardableResult
    private func parseMethod() -> ArgonWorks.Method
        {
        self.nextToken()
        let location = self.token.location
        self.visualToken.kind = .method
        let name = self.parseLabel()
        let existingMethod = self.currentContext.lookup(label: name) as? Method
        let list = self.parseParameters()
        var returnType: Class = VoidClass.voidClass
        
        if self.token.isRightArrow
            {
            self.nextToken()
            returnType = self.parseType()
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
                self.dispatchError("The multimethod '\(existingMethod!.label)' is defined with a return type of '\(existingMethod!.returnType.label)' different from this return type.")
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
        let instance = MethodInstance(label: name,parameters: list,returnType: returnType)
        instance.addDeclaration(location)
        if existingMethod.isNotNil
            {
            existingMethod?.addInstance(instance)
            }
        else
            {
            let method = Method(label: name)
            method.addDeclaration(location)
            self.currentContext.addSymbol(method)
            method.addInstance(instance)
            }
        instance.block.addParameters(list)
        self.parseBraces
            {
            self.pushContext(instance)
            self.parseBlock(into: instance.block)
            self.popContext()
            }
        if returnType != VoidClass.voidClass && !instance.block.hasReturnBlock
            {
            self.cancelCompletion()
            self.dispatchError(at: location,"This method has a return value but there is no RETURN statement in the body of the method.")
            }
        self.currentContext.addSymbol(instance.method)
        return(instance.method)
        }
        
    private func parseStatements() -> Expressions
        {
        return(Expressions())
        }
        
    private func parseExpression() -> Expression
        {
        let location = self.token.location
        let lhs = self.parseAsExpression()
        lhs.addDeclaration(location)
        if self.token.isEquals
            {
            let symbol = self.token.symbol
            self.nextToken()
            let rhs = self.parseAsExpression()
            return(lhs.operation(symbol,rhs))
            }
        print("PARSED EXPRESSION:")
        print(lhs.displayString)
        return(lhs)
        }
        
    private func parseAsExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseScopeExpression()
        if self.token.isAs
            {
            self.nextToken()
            let rhs = self.parseType()
            lhs = lhs.cast(into: rhs)
            lhs.addDeclaration(location)
            }
        return(lhs)
        }
        
    private func parseScopeExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseSlotExpression()
        lhs.addDeclaration(location)
        var child:String
        while self.token.isGluon
            {
            if !lhs.canBeScoped
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "An expression that can be scoped is required before a gluon.")
                lhs = LiteralExpression(.class(Class(label:"")))
                }
            self.nextToken()
            if self.token.isIdentifier
                {
                child = self.token.identifier
                self.nextToken()
                }
            else if self.token.isHashStringLiteral
                {
                child = self.token.hashStringLiteral
                self.nextToken()
                }
            else
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "An identifier was expected after the gluon, but '\(self.token)' was found.")
                self.nextToken()
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
                lhs = self.parseAssociatedValues(with: lhs)
                }
            }
        return(lhs)
        }
        
    private func parseAssociatedValues(with lhs: Expression) -> Expression
        {
        let theCase = lhs.enumerationCase
        self.nextToken()
        if theCase.associatedTypes.isEmpty
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "The case '\(theCase.label)' does not have any associated values.")
            }
        var values = Array<Expression>()
        var index = 0
        while index < theCase.associatedTypes.count && !self.token.isRightPar
            {
            values.append(self.parseExpression())
            self.parseComma()
            index += 1
            }
        if !self.token.isRightPar
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "A ')' was expected after the associated values for '\(theCase.label)' but it was not found.")
            }
        self.nextToken()
        return(EnumerationInstanceExpression(caseLabel: theCase.label,enumeration: theCase.enumeration, enumerationCase: theCase, associatedValues: values))
        }
        
    private func parseSlotExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseIncDecExpression()
        lhs.addDeclaration(location)
        while self.token.isRightArrow
            {
            self.nextToken()
            lhs = lhs.slot(self.parseSlotSelectorExpression())
            }
        return(lhs)
        }
        
    private func parseIncDecExpression() -> Expression
        {
        let location = self.token.location
        let expression = self.parseArrayExpression()
        expression.addDeclaration(location)
        if self.token.isPlusPlus || self.token.isMinusMinus
            {
            let symbol = self.token.operator
            self.nextToken()
            return(SuffixExpression(expression,symbol))
            }
        return(expression)
        }

    private func parseArrayExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseBooleanExpression()
        lhs.addDeclaration(location)
        while self.token.isLeftBracket
            {
            self.nextToken()
            let rhs = self.parseExpression()
            if !self.token.isRightBracket
                {
                self.dispatchError("']' expected but \(self.token) was found.")
                }
            self.nextToken()
            lhs = lhs.index(rhs)
            }
        return(lhs)
        }
        
    private func parseBooleanExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseComparisonExpression()
        lhs.addDeclaration(location)
        while self.token.isAnd || self.token.isOr
            {
            let symbol = token.symbol
            self.nextToken()
            lhs = lhs.operation(symbol,self.parseComparisonExpression())
            }
        return(lhs)
        }
        
    private func parseComparisonExpression() -> Expression
        {
        let location = self.token.location
        let lhs = self.parseArithmeticExpression()
        lhs.addDeclaration(location)
        if self.token.isLeftBrocket || self.token.isLeftBrocketEquals || self.token.isEquals || self.token.isRightBrocket || self.token.isRightBrocketEquals
            {
            let symbol = self.token.symbol
            self.nextToken()
            let rhs = self.parseArithmeticExpression()
            return(lhs.operation(symbol,rhs))
            }
        return(lhs)
        }
        
    private func parseArithmeticExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseMultiplicativeExpression()
        lhs.addDeclaration(location)
        while self.token.isAdd || self.token.isSub
            {
            let symbol = token.symbol
            self.nextToken()
            lhs = lhs.operation(symbol,self.parseMultiplicativeExpression())
            }
        return(lhs)
        }
        
    private func parseMultiplicativeExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseBitExpression()
        lhs.addDeclaration(location)
        while self.token.isMul || self.token.isDiv || self.token.isModulus
            {
            let symbol = token.symbol
            self.nextToken()
            lhs = lhs.operation(symbol,self.parseBitExpression())
            }
        return(lhs)
        }
        
    private func parseBitExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseUnaryExpression()
        lhs.addDeclaration(location)
        while self.token.isBitAnd || self.token.isBitOr || self.token.isBitXor
            {
            let symbol = token.symbol
            self.nextToken()
            lhs = lhs.operation(symbol,self.parseUnaryExpression())
            }
        return(lhs)
        }
        
    private func parseUnaryExpression() -> Expression
        {
        if self.token.isSub || self.token.isBitNot || self.token.isNot
            {
            return(self.parseUnaryExpression().unary(self.token.symbol))
            }
        else
            {
            let location = self.token.location
            let term = self.parsePrimary()
            term.addDeclaration(location)
            return(term)
            }
        }
        
    private func parsePrimary() -> Expression
        {
        if self.token.isIntegerLiteral
            {
            self.nextToken()
            return(LiteralExpression(.integer(self.lastToken.integerLiteral)))
            }
        else if self.token.isFloatingPointLiteral
            {
            self.nextToken()
            return(LiteralExpression(.float(self.lastToken.floatingPointLiteral)))
            }
        else if self.token.isStringLiteral
            {
            self.nextToken()
            return(LiteralExpression(.string(self.lastToken.stringLiteral)))
            }
        else if self.token.isHashStringLiteral
            {
            self.nextToken()
            return(LiteralExpression(.symbol(self.lastToken.hashStringLiteral)))
            }
        else if self.token.isNilLiteral
            {
            self.nextToken()
            return(LiteralExpression(.nil))
            }
        else if self.token.isBooleanLiteral
            {
            self.nextToken()
            return(LiteralExpression(.boolean(self.lastToken.booleanLiteral)))
            }
        else if self.token.isIdentifier
            {
            return(self.parseIdentifierTerm())
            }
        else if self.token.isGluon
            {
            return(self.parseEnumerationCaseExpression())
            }
        else if self.token.isLeftPar
            {
            return(self.parseParentheses
                {
                return(self.parseExpression())
                })
            }
        else if self.token.isLeftBrace
            {
            return(self.parseClosureTerm())
            }
        else
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "This expression is invalid.")
            fatalError("Invalid parse state \(self.lastToken) \(self.token)")
            }
        }
        
    private func parseEnumerationCaseExpression() -> Expression
        {
        self.nextToken()
        if !self.token.isIdentifier
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "When a gluon is used to begin an enumeration case, it must be followed by an identifier.")
            self.nextToken()
            return(Expression())
            }
        let theCaseKey = self.token.identifier
        self.nextToken()
        return(EnumerationInstanceExpression(caseLabel: theCaseKey,enumeration: nil, enumerationCase: nil, associatedValues: nil))
        }
        
    private func parseSlotSelectorExpression() -> Expression
        {
        self.visualToken.kind = .classSlot
        let location = self.token.location
        let first = self.parseLabel()
        let lhs = SlotSelectorExpression(selector: first)
        lhs.addDeclaration(location)
        return(lhs)
        }
        
    private func parseIdentifierTerm() -> Expression
        {
        let location = self.token.location
        let name = self.parseName()
        let aSymbol = self.currentContext.lookup(name: name)
        if let symbol = aSymbol as? Enumeration
            {
            let enumeration = LiteralExpression(.enumeration(symbol))
            enumeration.addDeclaration(location)
            return(enumeration)
            }
        else if let symbol = aSymbol as? Class
            {
            var clazz = symbol
            if clazz.isGenericClass
                {
                let genericClass = clazz as! GenericClass
                if !self.token.isLeftBrocket
                    {
                    self.cancelCompletion()
                    self.dispatchError(at: self.token.location, message: "A '<' was expected after a generic class reference but \(self.token) was found.")
                    }
                else
                    {
                    let types = self.parseTypeParameters()
                    clazz = genericClass.instanciate(withTypes: types, reportingContext: self.reportingContext)
                    }
                }
            if self.token.isLeftPar
                {
                return(self.parseInstanciationTerm(ofClass: clazz))
                }
            let literal = LiteralExpression(.class(clazz))
            literal.addDeclaration(location)
            return(literal)
            }
        else if let symbol = aSymbol as? Module
            {
            let module = LiteralExpression(.module(symbol))
            module.addDeclaration(location)
            return(module)
            }
        else if let symbol = aSymbol as? Slot
            {
            let read = LocalSlotExpression(slot: symbol)
            read.addDeclaration(location)
            return(read)
            }
        else if self.token.isLeftPar
            {
            return(self.parseInvocationTerm(name))
            }
        else
            {
            let term = LocalSlotExpression(slot: Slot(label: name.last, type: VoidClass.voidClass))
            term.addDeclaration(location)
            return(term)
            }
        }
        
    private func parseClosureTerm() -> BlockExpression
        {
        let closure = ClosureBlock()
        let location = self.token.location
        self.parseBraces
            {
            if self.token.isWith
                {
                self.nextToken()
                closure.parameters = self.parseParameters()
                }
            if self.token.isRightArrow
                {
                self.nextToken()
                closure.returnType = self.parseType()
                }
            for parameter in closure.parameters
                {
                closure.addLocalSlot(parameter)
                }
            while !self.token.isRightBrace
                {
                self.parseBlock(into: closure)
                }
            }
        let block = BlockExpression(block: closure)
        block.addDeclaration(location)
        return(block)
        }
        
    private func parseInvocationTerm(method: Method) -> Expression
        {
        let location = self.token.location
        let args = self.parseParentheses
            {
            self.parseArguments()
            }
        let expression = MethodInvocationExpression(method: method,arguments: args)
        expression.addDeclaration(location)
        return(expression)
        }
        
    private func parseArguments() -> Arguments
        {
        var arguments = Arguments()
        while !self.token.isRightPar
            {
            repeat
                {
                self.parseComma()
                arguments.append(self.parseArgument())
                }
            while self.token.isComma
            }
        return(arguments)
        }
        
    private func parseArgument() -> Argument
        {
        if self.token.isIdentifier && self.peekToken1().isGluon
            {
            let tag = token.identifier
            self.nextToken()
            self.nextToken()
            return(Argument(tag: tag, value: self.parseExpression()))
            }
        return(Argument(tag: nil,value: self.parseExpression()))
        }
        
    private func parseInvocationTerm(_ name:Name) -> Expression
        {
        let location = self.token.location
        self.visualToken.kind = .methodInvocation
        let method = self.currentContext.lookup(name: name) as? Method
        if method.isNotNil
            {
            return(self.parseInvocationTerm(method: method!))
            }
        let args = self.parseParentheses
            {
            self.parseArguments()
            }
        let expression = InvocationExpression(name: name,arguments: args, location: self.token.location,context: self.currentContext, reportingContext: self.reportingContext)
        expression.addDeclaration(location)
        return(expression)
        }
        
    private func parseInstanciationTerm(ofClass aClass: Class) -> Expression
        {
        let location = self.token.location
        var arguments = Arguments()
        self.parseParentheses
            {
            () -> Void in
            if !self.token.isRightPar
                {
                repeat
                    {
                    self.parseComma()
                    arguments.append(self.parseArgument())
                    }
                while self.token.isComma
                }
            }
        let invocation = ClassInstanciationTerm(type: aClass,arguments: arguments)
        invocation.addDeclaration(location)
        return(invocation)
        }
        
    private func parseBlock(into block: Block)
        {
        while !self.token.isRightBrace
            {
            if self.token.isSelect
                {
                self.parseSelectBlock(into: block)
                }
            else if self.token.isIf
                {
                self.parseIfBlock(into: block)
                }
            else if self.token.isWhile
                {
                self.parseWhileBlock(into: block)
                }
            else if self.token.isFork
                {
                self.parseForkBlock(into: block)
                }
            else if self.token.isLoop
                {
                self.parseLoopBlock(into: block)
                }
            else if self.token.isSignal
                {
                self.parseSignalBlock(into: block)
                }
            else if self.token.isHandle
                {
                self.parseHandleBlock(into: block)
                }
            else if self.token.isIdentifier
                {
                self.parseIdentifierBlock(into: block)
                }
            else if self.token.isReturn
                {
                self.parseReturnBlock(into: block)
                }
            else if self.token.isLet
                {
                self.parseLetBlock(into: block)
                }
            else
                {
                self.dispatchError("A statement was expected but \(self.token) was found.")
                self.nextToken()
                }
            }
        }
        
    private func parseSelectBlock(into block: Block)
        {
        self.startClip()
        self.nextToken()
        let location = self.token.location
        let value = self.parseParentheses
            {
            return(self.parseExpression())
            }
        let selectBlock = SelectBlock(value: value)
        selectBlock.addDeclaration(location)
        block.addBlock(selectBlock)
        self.parseBraces
            {
            while !self.token.isRightBrace && !self.token.isOtherwise
                {
                if !self.token.isWhen
                    {
                    self.dispatchError("WHEN expected after SELECT clause")
                    self.nextToken()
                    }
                self.nextToken()
                let location1 = self.token.location
                let inner = self.parseParentheses
                    {
                    self.parseExpression()
                    }
                let when = WhenBlock(condition: inner)
                when.addDeclaration(location1)
                selectBlock.addWhen(block: when)
                self.parseBraces
                    {
                    self.parseBlock(into: when)
                    }
                }
            if self.token.isOtherwise
                {
                let otherwise = OtherwiseBlock()
                self.nextToken()
                self.parseBraces
                    {
                    self.parseBlock(into: otherwise)
                    }
                selectBlock.addOtherwise(block: otherwise)
                }
            }
        self.stopClip(into: selectBlock)
        }
        
    private func parseElseIfBlock(into block: IfBlock)
        {
        self.startClip()
        self.nextToken()
        let location = self.token.location
        let expression = self.parseExpression()
        let statement = ElseIfBlock(condition: expression)
        block.elseBlock = statement
        statement.addDeclaration(location)
        self.parseBraces
            {
            self.parseBlock(into: statement)
            }
        if self.token.isElse && self.peekToken1().isIf
            {
            self.nextToken()
            self.parseElseIfBlock(into: statement)
            }
        if self.token.isElse
            {
            self.nextToken()
            let elseClause = ElseBlock()
            statement.elseBlock = elseClause
            self.parseBraces
                {
                self.parseBlock(into: elseClause)
                }
            }
        self.stopClip(into: statement)
        }
        
    private func parseIfBlock(into block: Block)
        {
        self.startClip()
        self.nextToken()
        let location = self.token.location
        let expression = self.parseExpression()
        let statement = IfBlock(condition: expression)
        block.addBlock(statement)
        statement.addDeclaration(location)
        self.parseBraces
            {
            self.parseBlock(into: statement)
            }
        if self.token.isElse && self.peekToken1().isIf
            {
            self.nextToken()
            self.parseElseIfBlock(into: statement)
            }
        if self.token.isElse
            {
            self.nextToken()
            let elseClause = ElseBlock()
            statement.elseBlock = elseClause
            self.parseBraces
                {
                self.parseBlock(into: elseClause)
                }
            }
        self.stopClip(into: statement)
        }
        
    private func parseLetBlock(into block: Block)
        {
        self.startClip()
        let location = self.token.location
        self.nextToken()
        let someVariable = self.parseName()
        if !self.token.isAssign
            {
            self.dispatchError("'=' expected after LET clause.")
            }
        self.nextToken()
        let value = self.parseExpression()
        value.setParent(block)
        let aClass = value.resultType.class ?? VoidClass.voidClass
        print(aClass)
        let localSlot = LocalSlot(label: someVariable.last, type: value)
        block.addLocalSlot(localSlot)
        let statement = LetBlock(name: someVariable,slot:localSlot,location: self.token.location,namingContext: block,value: value)
        statement.addDeclaration(location)
        block.addBlock(statement)
        self.stopClip(into: statement)
        }
        
    private func parseReturnBlock(into block: Block)
        {
        self.startClip()
        self.nextToken()
        let location = self.token.location
        let value = self.parseParentheses
            {
            self.parseExpression()
            }
        let returnBlock = ReturnBlock()
        returnBlock.addDeclaration(location)
        returnBlock.value = value
        block.addBlock(returnBlock)
        self.stopClip(into: returnBlock)
        }
        
    private func parseWhileBlock(into block: Block)
        {
        self.startClip()
        let location = self.token.location
        self.nextToken()
        let expression = self.parseComparisonExpression()
        let statement = WhileBlock(condition: expression)
        statement.addDeclaration(location)
        self.parseBlock(into: statement)
        block.addBlock(statement)
        self.stopClip(into: block)
        }
        
    private func parseInductionVariable()
        {
        }
        
    private func parseForkBlock(into block: Block)
        {
        self.startClip()
        let location = self.token.location
        let variableName = self.parseLabel()
        self.parseInductionVariable()
        let statement = ForBlock(name: variableName)
        statement.addDeclaration(location)
        self.parseBlock(into: statement)
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
        
    private func parseLoopBlock(into block: Block)
        {
        self.startClip()
        self.nextToken()
        let location = self.token.location
        let (start,end,update) = self.parseLoopConstraints()
        let statement = LoopBlock(start: start,end: end,update: update)
        statement.addDeclaration(location)
        block.addBlock(statement)
        self.parseBlock(into: statement)
        self.stopClip(into: statement)
        }
        
    private func parseLoopConstraints() -> ([Expression],Expression,[Expression])
        {
        var start = Array<Expression>()
        var end:Expression = Expression()
        var update = Array<Expression>()
        self.parseParentheses
            {
            repeat
                {
                self.parseComma()
                start.append(self.parseExpression())
                }
            while self.token.isComma
            if !self.token.isGluon
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "'::' was expected between LOOP clauses.")
                }
            self.nextToken()
            end = self.parseExpression()
            if !self.token.isGluon
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "'::' was expected between LOOP clauses.")
                }
            self.nextToken()
            repeat
                {
                self.parseComma()
                update.append(self.parseExpression())
                }
            while self.token.isComma
            }
        return((start,end,update))
        }
        
    private func parseSignalBlock(into block: Block)
        {
        self.nextToken()
        let location = self.token.location
        self.parseParentheses
            {
            if self.nextToken().isHashStringLiteral
                {
                let symbol = self.token.hashStringLiteral
                let signal = SignalBlock(symbol: symbol)
                signal.addDeclaration(location)
                block.addBlock(signal)
                self.nextToken()
                }
            else
                {
                self.dispatchError("Symbol expected but \(self.token) was found instead.")
                }
            }
        }

    private func parseIdentifierBlock(into block: Block)
        {
        let start = self.token.location.tokenStart
        var expression = self.parseExpression()
        if self.token.isPlusPlus || self.token.isMinusMinus
            {
            let symbol = self.token.operator
            self.nextToken()
            expression = SuffixExpression(expression,symbol)
            }
        else if self.token.isAddEquals || self.token.isSubEquals || self.token.isMulEquals || self.token.isDivEquals || self.token.isBitAndEquals || self.token.isBitOrEquals || self.token.isBitNotEquals || self.token.isBitXorEquals
            {
            let symbol = self.token.operator
            self.nextToken()
            expression = expression.assign(symbol,self.parseExpression())
            }
        else if self.token.isAssign
            {
            self.nextToken()
            expression = expression.assign(Token.Operator.assign,self.parseExpression())
            }
        let stop = self.token.location.tokenStop
        let newBlock = ExpressionBlock(expression)
        newBlock.source = self.source!.substring(with: start..<stop + 1)
        block.addBlock(newBlock)
        }
        
    private func parseAssignmentBlock(into block: Block)
        {
        print("HALT")
        }
        
    private func parseParameter() -> Parameter
        {
        let location = self.token.location
        var isHidden = false
        if self.token.isAssign
            {
            isHidden = true
            self.nextToken()
            }
        let tag = self.parseLabel()
        self.parseGluon()
        let type = self.parseType()
        var isVariadic = false
        if self.token.isFullRange
            {
            self.nextToken()
            isVariadic = true
            }
        let parameter = Parameter(label: tag, type: type,isVisible: isHidden,isVariadic: isVariadic)
        parameter.addDeclaration(location)
        return(parameter)
        }
        
    @discardableResult
    private func parseFunction() -> Function
        {
        self.nextToken()
        let location = self.token.location
        self.visualToken.kind = .function
        let name = self.parseLabel()
        let cName = self.parseParentheses
            {
            () -> String in
            let string = self.parseLabel()
            return(string)
            }
        let parameters = self.parseParameters()
        let function = Function(label: name)
        function.addDeclaration(location)
        function.cName = cName
        function.parameters = parameters
        if self.token.isRightArrow
            {
            self.nextToken()
            function.returnType = self.parseType()
            }
        self.currentContext.addSymbol(function)
        return(function)
        }
        
    @discardableResult
    private func parseTypeAlias() -> TypeAlias
        {
        self.nextToken()
        let location = self.token.location
        self.visualToken.kind = .type
        let label = self.parseLabel()
        if !self.token.isIs
            {
            self.dispatchError("IS expeected after new name for type.")
            }
        self.nextToken()
        let type = self.parseType()
        let alias = TypeAlias(label: label,type: type)
        alias.addDeclaration(location)
        self.currentContext.addSymbol(alias)
        return(alias)
        }
        
    private func parseHandleBlock(into block: Block)
        {
        let start = self.token.location.tokenStart
        self.nextToken()
        let location = self.token.location
        let handler = HandlerBlock()
        handler.addDeclaration(location)
        block.addBlock(handler)
        self.pushContext(handler)
        self.parseParentheses
            {
            repeat
                {
                self.parseComma()
                if !self.token.isHashStringLiteral
                    {
                    self.dispatchError("A symbol was expected in the handler clause, but \(self.token) was found.")
                    }
                let symbol = self.token.isHashStringLiteral ? self.token.hashStringLiteral : "#SYMBOL"
                self.nextToken()
                handler.symbols.append(symbol)
                }
            while self.token.isComma
            }
        self.parseBraces
            {
            if !self.token.isWith
                {
                self.dispatchError("WITH expected in first line of HANDLE clause, but \(self.token) was found.")
                }
            self.nextToken()
            var name:String = ""
            self.parseParentheses
                {
                if !self.token.isIdentifier
                    {
                    self.dispatchError("The name of an induction variable to contain the symbol this handler is receiving was expected but \(self.token) was found.")
                    }
                name = self.token.isIdentifier ? self.token.identifier : "VariableName"
                handler.addParameter(label: name,type: self.topModule.argonModule.symbol)
                self.nextToken()
                }
            self.parseBlock(into: handler)
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
