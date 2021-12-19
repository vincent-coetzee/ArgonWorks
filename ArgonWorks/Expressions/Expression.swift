//
//  ParseExpression.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 5/3/21.
//

import Foundation

public class Expression: NSObject,NSCoding,VisitorReceiver
    {
    public var enclosingMethodInstanceScope: Scope
        {
        var aScope = self.enclosingScope
        while !aScope.isMethodInstanceScope
            {
            aScope = aScope.enclosingScope
            }
        return(aScope)
        }
        
    public var declarationLine: Int
        {
        if let location = self.declaration
            {
            return(location.line)
            }
//        print("\(Swift.type(of: self)) missing declaration location. Parent is \(self.parent).")
        return(0)
        }
        
    public var diagnosticString: String
        {
        ""
        }
        
    public var enclosingScope: Scope
        {
        return(self.parent.enclosingScope)
        }
        
    public var enumerationCaseHasAssociatedTypes: Bool
        {
        return(false)
        }

    public var isUnresolved: Bool
        {
        return(false)
        }
        
    public var isSelf: Bool
        {
        return(false)
        }
        
    public var isSELF: Bool
        {
        return(false)
        }
        
    public var isSuper: Bool
        {
        return(false)
        }
    
    public var rhsValue: Expression?
        {
        return(nil)
        }
        
    public var lhsValue: Expression?
        {
        return(nil)
        }
        
    public func display(indent: String)
        {
        }
        
    public var declaration: Location?
        {
        return(self.locations.declaration.isNil ? .zero : self.locations.declaration)
        }
        
    public var unresolvedLabel: String
        {
        fatalError()
        }
        
    public var isLiteralExpression: Bool
        {
        return(false)
        }
        
    public var topModule: TopModule
        {
        return(self.parent.topModule)
        }
        
    public var canBeScoped: Bool
        {
        return(false)
        }

    public var isEnumerationCaseExpression: Bool
        {
        return(false)
        }
        
    public var isVariableExpression: Bool
        {
        return(false)
        }
        
    public var enumerationCase: EnumerationCase
        {
        fatalError()
        }
        
    public var place: T3AInstruction.Operand
        {
        return(self._place)
        }
    
    public private(set) var locations = SourceLocations()
    public internal(set) var _place: T3AInstruction.Operand = .none
    public private(set) var parent: Parent = .none
    internal var type: Type? = nil
    public var issues = CompilerIssues()
    public private(set) var container: Container?
    
    public override init()
        {
        }
        
    public required init?(coder: NSCoder)
        {
        self.parent = coder.decodeParent(forKey: "parent")!
        self.locations = coder.decodeSourceLocations(forKey: "locations")
        self.type = coder.decodeObject(forKey: "type") as? Type
        super.init()
        }

    public func encode(with coder:NSCoder)
        {
        coder.encodeParent(self.parent,forKey: "parent")
        coder.encodeSourceLocations(self.locations,forKey:"locations")
        coder.encode(self.type,forKey: "type")
        }
        
    public func initializeType(inContext context: TypeContext)
        {
        print("WARNING: initializeType not implemented in \(Swift.type(of: self))")
        self.type = context.voidType
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext)
        {
        print("WARNING: initializeTypeConstraints not implemented in \(Swift.type(of: self))")
        }
        
    public func addDeclaration(_ location:Location)
        {
        self.locations.append(.declaration(location))
        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
        
    public func allocateAddresses(using allocator:AddressAllocator) throws
        {
        }
        
    public func lookup(label: Label) -> Symbol?
        {
        return(self.parent.lookup(label: label))
        }
        
    public func lookupN(name: Name) -> Symbols?
        {
        return(self.parent.lookupN(name: name))
        }

    public func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }

    public func substitute(from: TypeContext.Substitution) -> Self
        {
        self
        }
        
    public func appendIssue(_ issue: CompilerIssue)
        {
        self.issues.append(issue)
        }
        
    public func appendIssue(at: Location,message: String,isWarning:Bool = false)
        {
        self.issues.append(CompilerIssue(location: at, message: message,isWarning: isWarning))
        }
        
    @discardableResult
    public func appendIssues(_ issues: CompilerIssues) -> Expression
        {
        self.issues.append(contentsOf: issues)
        return(self)
        }

    public func assign(from expression: Expression,into: T3ABuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
        
    ///
    ///
    /// Emitting an LValue for an expression, emit the code to generate a
    /// pointer to the item in question. It will leave a pointer in the
    /// "place" of the expression.
    ///
    ///
    public func emitPointerCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
    ///
    ///
    /// Emitting an RValue for an expression, emits the code to generate a
    /// value of the expression rather than a point to the item. RValues always
    /// occur on the RHS which is why they are called RValues.
    ///
    ///
    public func emitValueCode(into: T3ABuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
        
    public func visit(visitor: Visitor) throws
        {
        }
        
    public func emitCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
//        fatalError("This should have been implemented")
        }
        
    public func setParent(_ block: Block)
        {
        self.parent = .block(block)
        }
        
    public func setParent(_ symbol: Symbol)
        {
        self.parent = .node(symbol)
        }
        
    public func setParent(_ expression: Expression)
        {
        self.parent = .expression(expression)
        }
        
    public func setParent(_ parent: Parent)
        {
        self.parent = parent
        }
        
    public var displayString: String
        {
        return("")
        }
        
    public func lookupSlot(selector: String) -> Slot?
        {
        return(nil)
        }
        
    public func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        return(self)
        }
        
    public func printParentChain()
        {
        print("\(self)")
        self.parent.printParentChain()
        }
    }
    

public typealias Expressions = Array<Expression>

extension Expressions
    {
    public func setParent(_ block: Block)
        {
        for element in self
            {
            element.setParent(block)
            }
        }
    }
