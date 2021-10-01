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
        return(SlotExpression(self,slot: index))
        }
        
    public func cast(into: Type) -> Expression
        {
        return(AsExpression(self,into: into))
        }
        
    public var declaration: Location?
        {
        return(self.locations.declaration)
        }
        
    public var isLValue: Bool
        {
        return(false)
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
        
    public var resultType: Type
        {
        .error(.mismatch)
        }
    
    public var isEnumerationCaseExpression: Bool
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
    public var _place: Instruction.Operand = .none
    public var parent: Parent = .none
    
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
        
    public func scopedExpression(for child: String) -> Expression?
        {
        return(nil)
        }
        
    public func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
        

    public func emitCode(into instance: InstructionBuffer,using: CodeGenerator) throws
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
