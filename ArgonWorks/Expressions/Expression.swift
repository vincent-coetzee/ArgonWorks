//
//  ParseExpression.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 5/3/21.
//

import Foundation

public class Expression: NSObject,NSCoding,VisitorReceiver
    {
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
        self.displayString
        }
        
    public var isReadOnlyExpression: Bool
        {
        false
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
        if self.locations.declaration.isNil
            {
            print("halt")
            }
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
        
    public var canBeScoped: Bool
        {
        return(false)
        }

    public var isEnumerationExpression: Bool
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
        
    public var place: Instruction.Operand
        {
        return(self._place)
        }
    
    public var locations = SourceLocations()
    public internal(set) var _place: Instruction.Operand = .none
    internal var type: Type
    public var issues = CompilerIssues()
    public var container: Container = .none
    
    public override init()
        {
        self.type = Type(label: "Dummy Expression Type")
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.locations = coder.decodeSourceLocations(forKey: "locations")
        self.type = coder.decodeObject(forKey: "type") as! Type
        self.issues = coder.decodeCompilerIssues(forKey: "issues")
        super.init()
        }

    public func encode(with coder:NSCoder)
        {
        coder.encodeSourceLocations(self.locations,forKey:"locations")
        coder.encodeCompilerIssues(self.issues,forKey: "issues")
        coder.encode(self.type,forKey: "type")
        }
        
    public func initializeType(inContext context: TypeContext)
        {
        self.type = context.voidType
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext)
        {
        }
        
    public func inferType(inContext: TypeContext)
        {
        self.type = inContext.voidType
        }
        
    public func addDeclaration(itemKey: Int, location aLocation:Location)
        {
        var location = aLocation
        location.itemKey = itemKey
        self.locations.append(.declaration(location))
        }
        
    public func addDeclaration(_ location: Location)
        {
        self.addDeclaration(itemKey: 0,location: location)
        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
        
    public func allocateAddresses(using allocator:AddressAllocator) throws
        {
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

    public func assign(from expression: Expression,into: InstructionBuffer,using: CodeGenerator) throws
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
    public func emitPointerCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
        
    public func emitAddressCode(into: InstructionBuffer,using: CodeGenerator) throws
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
    public func emitValueCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
        
    public func visit(visitor: Visitor) throws
        {
        }
        
    public func emitCode(into instance: InstructionBuffer,using: CodeGenerator) throws
        {
//        fatalError("This should have been implemented")
        }
        
//    public func setParent(_ block: Block)
//        {
//        self.parent = .block(block)
//        }
//        
//    public func setParent(_ symbol: Symbol)
//        {
//        self.parent = .node(symbol)
//        }
//        
//    public func setParent(_ expression: Expression)
//        {
//        self.parent = .expression(expression)
//        }
//        
//    public func setParent(_ parent: Parent)
//        {
//        self.parent = parent
//        }
        
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
    }
    

public typealias Expressions = Array<Expression>

public typealias ExpressionsList = Array<Expressions>

public class CompoundExpression: Expression
    {
    public override var displayString: String
        {
        self.expressions.map{$0.displayString}.joined(separator: ",")
        }
        
    internal var expressions: Expressions
    
    init(_ expression: Expression)
        {
        self.expressions = [expression]
        super.init()
        }
        
    override init()
        {
        self.expressions = Expressions()
        super.init()
        }
        
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    public func append(_ expression: Expression)
        {
        self.expressions.append(expression)
        }
        
    public override func display(indent: String)
        {
        let dent = indent + "\t"
        print("\(indent)EXPRESSIONS")
        for expression in self.expressions
            {
            expression.display(indent:dent)
            }
        }
        
    public override func initializeType(inContext: TypeContext)
        {
        for expression in self.expressions
            {
            expression.initializeType(inContext: inContext)
            }
        let types = self.expressions.map{$0.type}
        self.type = TypeConstructor(label: "CompoundExpression\(self.expressions.count)",generics: types)
        }
        
    public override func initializeTypeConstraints(inContext: TypeContext)
        {
        for expression in self.expressions
            {
            expression.initializeTypeConstraints(inContext: inContext)
            }
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        let expression = CompoundExpression()
        expression.expressions = self.expressions.map{$0.freshTypeVariable(inContext: context)}
        expression.type = self.type.freshTypeVariable(inContext: context)
        return(expression as! Self)
        }
        
    public override func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let expression = CompoundExpression()
        expression.expressions = self.expressions.map{substitution.substitute($0)}
        expression.type = substitution.substitute(self.type)
        return(expression as! Self)
        }
    }
