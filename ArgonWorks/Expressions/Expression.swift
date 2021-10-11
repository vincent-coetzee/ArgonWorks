//
//  ParseExpression.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 5/3/21.
//

import Foundation

public class Expression: NSObject,NSCoding
    {
    public func operation(_ symbol:Token.Symbol,_ rhs:Expression) -> Expression
        {
        return(BinaryExpression(self,symbol,rhs))
        }
        
    public func unary(_ symbol:Token.Symbol) -> Expression
        {
        return(UnaryExpression(symbol, self))
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
        
    public func index(_ index:Expression) -> Expression
        {
        return(ArrayAccessExpression(array:self,index:index))
        }
        
    public func assign(_ operation: Token.Operator,_ index:Expression) -> Expression
        {
        return(AssignmentExpression(self,operation,index))
        }
        
    public func slot(_ index:Expression) -> Expression
        {
        return(SlotAccessExpression(self,slotExpression: index as! SlotSelectorExpression))
        }
        
    public func cast(into: Type) -> Expression
        {
        return(AsExpression(self,into: into))
        }
        
    public var rhsValue: Expression?
        {
        return(nil)
        }
        
    public var lhsValue: Expression?
        {
        return(nil)
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
        
    public var type: Type
        {
        .unknown
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
    internal private(set) var context: Context = .none
    internal var compiler: Compiler!
    
    public override init()
        {
        }
        
    public required init?(coder: NSCoder)
        {
        print("DECODE EXPRESSION")
        self.parent = coder.decodeParent(forKey: "parent")!
        self.locations = coder.decodeSourceLocations(forKey: "locations")
        super.init()
        }

    public func encode(with coder:NSCoder)
        {
        print("ENCODE EXPRESSION")
        coder.encodeParent(self.parent,forKey: "parent")
        coder.encodeSourceLocations(self.locations,forKey:"locations")
        }
        
    public func setContext(_ context: Context)
        {
        self.context = context
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
        
    public func realize(using: Realizer)
        {
        }
        
    public func setType(_ type:Type)
        {
        }
        
    public func becomeLValue()
        {
        }
        
    public func scopedExpression(for child: String) -> Expression?
        {
        return(nil)
        }
        
    public func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
        

    public func emitCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
//        fatalError("This should have been implemented")
        }
        
    public func emitAddressCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
//        fatalError("This should have been implemented")
        }
        
    public func setParent(_ block: Block)
        {
        self.parent = .block(block)
        }
        
    public func setParent(_ node: Node)
        {
        self.parent = .node(node)
        }
        
    public func setParent(_ expression: Expression)
        {
        self.parent = .expression(expression)
        }
        
    public var displayString: String
        {
        return("")
        }
        
   public func activate(context: Context,withInitialValue value: Expression)
        {
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
    }
    

public typealias Expressions = Array<Expression>
