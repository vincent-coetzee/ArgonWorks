//
//  ParseExpression.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 5/3/21.
//

import Foundation

public class Expression: NSObject,NSCoding,VisitorReceiver
    {
    public var diagnosticString: String
        {
        ""
        }
        
    public var enclosingScope: Scope
        {
        return(self.parent.enclosingScope)
        }
        
    public var assignedSlots: Slots
        {
        []
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
        return(self.locations.declaration)
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
    internal var type: Type = Type()
    public var issues = CompilerIssues()
    
    public override init()
        {
        }
        
    public required init?(coder: NSCoder)
        {
        self.parent = coder.decodeParent(forKey: "parent")!
        self.locations = coder.decodeSourceLocations(forKey: "locations")
        super.init()
        }

    public func encode(with coder:NSCoder)
        {
        coder.encodeParent(self.parent,forKey: "parent")
        coder.encodeSourceLocations(self.locations,forKey:"locations")
        }
        
    @discardableResult
    public func inferType(context: TypeContext) throws -> Type
        {
        self.type = context.voidType
        return(self.type)
        }
        
    public func initializeType(inContext context: TypeContext) throws
        {
        print("WARNING: initializeType not implemented in \(Swift.type(of: self))")
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext) throws
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
        
    public func allocateAddresses(using allocator:AddressAllocator)
        {
        }
        
    public func becomeLValue()
        {
        }
        
    public func lookup(label: Label) -> Symbol?
        {
        return(nil)
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

    public func visit(visitor: Visitor) throws
        {
        }
        
    public func emitCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
//        fatalError("This should have been implemented")
        }
        
    public func emitAssign(value: Expression,into instance: T3ABuffer,using: CodeGenerator) throws
        {
        }
        
    public func emitAddress(into instance: T3ABuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
        
    public func emitAddressCode(into instance: T3ABuffer,using: CodeGenerator) throws
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
        
    public func substitute(from: TypeContext) -> Self
        {
        Expression() as! Self
        }
        
    public func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)EXPRESSION()")
        }
        
    public func lookupSlot(selector: String) -> Slot?
        {
        return(nil)
        }
        
    public func operation(_ symbol:Token.Symbol,_ rhs:Expression) -> Expression
        {
        let expression = BinaryExpression(self,symbol,rhs)
        self.setParent(expression)
        rhs.setParent(expression)
        return(expression)
        }
        
    public func unary(_ symbol:Token.Symbol) -> Expression
        {
        let expression = UnaryExpression(symbol, self)
        self.setParent(expression)
        return(expression)
        }
        
    public func index(_ index:Expression) -> Expression
        {
        let expression = ArrayAccessExpression(array:self,index:index)
        self.setParent(expression)
        index.setParent(expression)
        return(expression)
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
