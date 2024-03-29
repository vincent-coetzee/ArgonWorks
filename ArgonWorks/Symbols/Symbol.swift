//
//  Symbol.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import AppKit

public class Symbol:Node,VisitorReceiver,IssueHolder
    {
    public var argonHash: Int
        {
        let hash1 = "Swift.type(of: self)".polynomialRollingHash
        let hash2 = self.label.polynomialRollingHash
        let hashValue = hash1 << 13 ^ hash2
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
    public var fullName: Name
        {
        self.container.fullName + self.label
        }
        
    public var isEnumerationInstanceClass: Bool
        {
        false
        }
        
    public var methodInstances:MethodInstances
        {
        []
        }
        
    public var allImportedSymbols: Symbols
        {
        []
        }
        
    public var asLiteralExpression: LiteralExpression?
        {
        return(nil)
        }
        
    public var isType: Bool
        {
        return(false)
        }

    public var isInvokable: Bool
        {
        return(false)
        }
        
    public var isLiteral: Bool
        {
        return(false)
        }
        
    public var sizeInBytes: Int
        {
        fatalError()
        }
        
    public var extraSizeInBytes: Int
        {
        0
        }
        
    public var segmentType: Segment.SegmentType
        {
        .managed
        }
        
    public var isArgonModule: Bool
        {
        return(false)
        }
        
    public var isGenericType: Bool
        {
        return(false)
        }
        
    public var defaultColor:NSColor
        {
        Palette.shared.argonPrimaryColor
        }
        
    public var canBecomeAType: Bool
        {
        return(false)
        }
        
    public var canBecomeAClass: Bool
        {
        return(false)
        }
        
    public var isSlot: Bool
        {
        return(false)
        }

    public var isForwardReferenceClass: Bool
        {
        return(false)
        }
        
    public var isArrayClassInstance: Bool
        {
        return(false)
        }
        
    public var isSystemClass: Bool
        {
        false
        }
        
    public var isEnumeration: Bool
        {
        return(false)
        }
        
    public var isEnumerationCase: Bool
        {
        return(false)
        }
        
    public var isSymbolGroup: Bool
        {
        return(false)
        }
        
    public var isTypeAlias: Bool
        {
        return(false)
        }
        
    public var asType: Type
        {
        fatalError("asType should not be sent to a symbol that does not override it.")
        }
        
    public var isSymbolContainer: Bool
        {
        return(false)
        }
        
    public var isSystemSymbol: Bool
        {
        return(false)
        }
        
    public var selectionColor: NSColor
        {
        get
            {
            if self._selectionColor.isNil
                {
                return(self.defaultColor)
                }
            return(self._selectionColor!)
            }
        set
            {
            self._selectionColor = newValue
            }
        }
        
    public var isSystemModule: Bool
        {
        return(false)
        }
        
        
    public var isSystemType: Bool
        {
        false
        }
        
    public var isSystemContainer: Bool
        {
        return(false)
        }
        
    public var childName: (String,String)
        {
        return(("item","items"))
        }
        
    public var isClass: Bool
        {
        return(false)
        }
        
    public var isModule: Bool
        {
        return(false)
        }

    public var declaration: Location?
        {
        self.locations.declaration
        }
        
    public var displayString: String
        {
        self.label
        }
        
    public override var description: String
        {
        return("\(Swift.type(of:self))(\(self.label))")
        }
        
    public var iconName: String
        {
        "IconEmpty"
        }
        
    public var symbolColor: NSColor
        {
        .black
        }
        
    public var isPrimitiveType: Bool
        {
        false
        }
        
    public var childCount: Int
        {
        return(self.children.count)
        }
        
    public var isExpandable: Bool
        {
        return(false)
        }
    
    public var isGenericClassInstance: Bool
        {
        return(false)
        }
        
    public var typeCode:TypeCode
        {
        fatalError("TypeCode being called on Symbol which is not valid")
        }
        
    public var children:Symbols
        {
        return([])
        }
 
    public var allChildren: Symbols
        {
        return([])
        }
        
    public var weight: Int
        {
        10
        }
        
    public var allIssues: CompilerIssues
        {
        return(self.issues)
        }
        
    internal var wasAddressAllocationDone = false
    internal var wasMemoryLayoutDone = false
    internal var wasSlotLayoutDone = false
    internal var locations: SourceLocations = SourceLocations()
    private var _selectionColor: NSColor?
    public private(set) var isImported = false
    public private(set) var loader: Loader?
    public var issues = CompilerIssues()
    public var type: Type!
    public var place: T3AInstruction.Operand = .none
    public var memoryAddress: Address = 0
    public private(set) var container: Container = .none
    public var module: Module!
    
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public required init?(coder: NSCoder)
        {
//        #if DEBUG
//        print("START DECODE SYMBOL")
//        #endif
        self.type = coder.decodeObject(forKey: "theType") as? Type
        self.memoryAddress = Address(coder.decodeInteger(forKey: "memoryAddress"))
        self.issues = coder.decodeCompilerIssues(forKey: "issues")
        self.container = coder.decodeContainer(forKey: "container")
        self.module = coder.decodeObject(forKey: "module") as? Module
        super.init(coder: coder)
//        #if DEBUG
//        print("END DECODE SYMBOL \(self.label)")
//        #endif
        }
        
    public override func encode(with coder:NSCoder)
        {
//        #if DEBUG
//        print("ENCODE SYMBOL \(self.label)")
//        #endif
        coder.encode(self.container,forKey: "container")
        coder.encode(self.type,forKey: "theType")
        coder.encode(Int(self.memoryAddress),forKey: "memoryAddress")
        coder.encodeCompilerIssues(self.issues,forKey: "issues")
        coder.encode(self.module,forKey: "module")
        super.encode(with: coder)
        }
        
    public func setContainer(_ container: Container)
        {
        self.container = container
        }
        
    public func setContainer(_ scope:Scope?)
        {
        self.container = .scope(scope!)
        }
        
   public func allocateAddresses(using: AddressAllocator) throws
        {
        }
        
    public func emitCode(using: CodeGenerator) throws
        {
        }
        
    public func emitCode(into: T3ABuffer,using: CodeGenerator) throws
        {
//        fatalError("Should not have been called")
        }
        
    public func analyzeSemantics(using: SemanticAnalyzer)
        {
        }
        
    public func typeCheck() throws
        {
        }
        
    public func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        self
        }
        
    public func initializeTypeConstraints(inContext context: TypeContext)
        {
        }
        
    public func initializeType(inContext context: TypeContext)
        {
        }
        
    public func appendWarningIssue(at: Location,message: String)
        {
        self.issues.append(CompilerIssue(location: at, message: message,isWarning: true))
        }
        
    public func appendIssue(at: Location,message: String)
        {
        self.issues.append(CompilerIssue(location: at, message: message,isWarning: false))
        }
        
    public func appendIssue(at: Location,message: String,isWarning:Bool = false)
        {
        self.issues.append(CompilerIssue(location: at, message: message,isWarning: isWarning))
        }
        
    public func appendIssue(_ issue: CompilerIssue)
        {
        self.issues.append(issue)
        }
        
    public func appendIssues(_ issues: CompilerIssues)
        {
        self.issues.append(contentsOf: issues)
        }
        
    public override func replacementObject(for archiver: NSKeyedArchiver) -> Any?
        {
        if let exporter = archiver as? ImportArchiver
            {
            if exporter.isSwappingSystemTypes && self.isSystemType
                {
                if self is TypeClass && self.isSystemType
                    {
                    print("Error substituting class, should be type")
                    }
                exporter.noteSwappedSystemType(self)
                let holder = SystemSymbolPlaceholder(original: self)
                if self.argonHash == 0
                    {
                    print("halt")
                    }
                print("SUBSTITUTING \(self.argonHash) \(self.displayString)")
                return(holder)
                }
            if exporter.isSwappingImportedSymbols && self.isImported
                {
                assert(self.loader.isNotNil,"self.loader should not be nil")
                exporter.noteSwappedImportedSymbol(self)
                return(ImportedSymbolPlaceholder(original: self))
                }
            }
        return(self)
        }
        
    public func assign(from: Expression,into buffer: T3ABuffer,using: CodeGenerator) throws
        {
        fatalError("This should have been implemented in subclass \(Swift.type(of: self)).")
        }
        
    public func emitRValue(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public func emitLValue(into buffer: T3ABuffer,using generator: CodeGenerator) throws
        {
        fatalError("This should have been implemented in subclass \(Swift.type(of: self)).")
        }
        
    public func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let copy = Self.init(label: self.label)
        copy.type = substitution.substitute(self.type)
        copy.issues = self.issues
        return(copy)
        }
        
    public func dump(depth: Int)
        {
        let string = String(repeating: "\t", count: depth)
        print("\(string)\(Swift.type(of: self)) \(self.label)")
        }
        
    public func display(indent: String)
        {
        print("\(indent)\(Swift.type(of: self)): \(self.label) \(self.type.displayString)")
        }
        
    public func replaceSymbol(_ source: Symbol,with replacement: Symbol)
        {
        }
        
    public func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
        {
//        cell.text.stringValue = self.displayString
//        let image = NSImage(named: self.imageName)!
//        image.isTemplate = true
//        cell.icon.image = image
//        cell.icon.contentTintColor = foregroundColor.isNil ? self.defaultColor : foregroundColor!
//        cell.text.textColor = foregroundColor.isNil ? self.defaultColor : foregroundColor!
//
        cell.text.stringValue = self.displayString
        let image = NSImage(named: self.iconName)!
        image.isTemplate = true
        cell.icon.image = image
//        var iconColor = NSColor.black
        var textColor = Palette.shared.hierarchyTextColor
        if self.isSymbolContainer
            {
//            var textColor = Palette.shared.hierarchyTextColor
            if self.childCount == 0
                {
//                iconColor = .argonMidGray
                textColor = .argonWhite70
                self.selectionColor = NSColor.argonMidGray
                }
            else
                {
//                iconColor = .argonNeonOrange
                }
            }
        else
            {
            textColor = .argonWhite30
            if self.isSlot
                {
//                iconColor = NSColor.argonThemeBlueGreen
                }
            else
                {
//                iconColor = NSColor.argonNeonOrange
                }
            }
        cell.icon.contentTintColor = Palette.shared.headerTextColor
        cell.text.textColor = textColor
        }
        
    public func visit(visitor: Visitor) throws
        {
        try visitor.accept(self)
        }
        
    public func invert(cell: HierarchyCellView)
        {
        let image = NSImage(named: self.iconName)!.image(withTintColor: NSColor.black)
        cell.icon.image = image
        cell.icon.contentTintColor = NSColor.black
        cell.icon.isHighlighted = false
        cell.text.textColor = NSColor.black
        }
        
    public func configure(leaderCell: NSTableCellView,foregroundColor:NSColor? = nil)
        {
        leaderCell.textField?.stringValue = ""
        }
        
    public func isElement(ofType: Group.ElementType) -> Bool
        {
        return(false)
        }
        
    public func child(atIndex: Int) -> Symbol
        {
        return(self.children[atIndex])
        }
    
    public func childCount(forChildType type: ChildType) -> Int
        {
        let kids = self.children(forChildType: type)
        return(kids.count)
        }
        
    public func printContents(_ indent: String = "")
        {
        let typeName = Swift.type(of: self)
        print("\(indent)\(typeName): \(self.label)")
        print("\(indent)INDEX: \(self.index)")
        }
        
    public func isExpandable(forChildType type: ChildType) -> Bool
        {
        return(self.isExpandable && self.childCount(forChildType: type) > 0)
        }
        
    public func children(forChildType type: ChildType) -> Array<Symbol>
        {
        let allKids = self.children
        if type == .class
            {
            return(allKids.filter{$0 is TypeClass || $0 is SymbolGroup}.sorted{$0.label < $1.label})
            }
        else if type == .method
            {
            return(allKids.filter{$0 is MethodInstance || $0 is Module || $0 is SymbolGroup}.sorted{$0.label < $1.label})
            }
        else
            {
            return(allKids.map{ElementHolder($0)}.sorted{$0.label < $1.label})
            }
        }
        
    public func child(forChildType type: ChildType,atIndex: Int) -> Symbol
        {
        return(self.children(forChildType: type)[atIndex])
        }
        
    public var isGroup: Bool
        {
        return(false)
        }
        
    public func directlyContains(symbol:Symbol) -> Bool
        {
        return(false)
        }
//        
//    public func lookup(index: UUID) -> Symbol?
//        {
//        if self.index == index
//            {
//            return(self)
//            }
//        return(nil)
//        }
        
    public func addLocalSlot(_ localSlot: LocalSlot)
        {
        fatalError()
        }
        
    public func addSymbol(_ symbol: Symbol)
        {
        fatalError("addSymbol should not be called on a \(Swift.type(of: self)).")
        }
        
    public func lookup(label: Label) -> Symbol?
        {
        fatalError("lookup should not be called on a \(Swift.type(of: self)).")
        }
        
    public func lookup(name: Name) -> Symbol?
        {
        if name.isRooted
            {
            if name.count == 1
                {
                return(nil)
                }
            if let start = TopModule.shared.lookup(label: name.first)
                {
                if name.count == 2
                    {
                    return(start)
                    }
                if let symbol = start.lookup(name: name.withoutFirst)
                    {
                    return(symbol)
                    }
                }
            }
        if name.isEmpty
            {
            return(nil)
            }
        else if name.count == 1
            {
            if let symbol = self.lookup(label: name.first)
                {
                return(symbol)
                }
            }
        else if let start = self.lookup(label: name.first)
            {
            if let symbol = (start as? Scope)?.lookup(name: name.withoutFirst)
                {
                return(symbol)
                }
            }
        return(self.module?.lookup(name: name))
        }
        
    public func lookupN(label: Label) -> Symbols?
        {
        return(self.module?.lookupN(label: label))
        }
        
    public func lookupN(name: Name) -> Symbols?
        {
        if name.isRooted
            {
            if name.count == 1
                {
                return(nil)
                }
            if let start = TopModule.shared.lookupN(label: name.first)
                {
                if name.count == 2
                    {
                    return(start.nilIfEmpty)
                    }
                if let symbol = (start.first)?.lookupN(name: name.withoutFirst)
                    {
                    return(symbol.nilIfEmpty)
                    }
                }
            return(nil)
            }
        if name.isEmpty
            {
            return(nil)
            }
        else if name.count == 1
            {
            if let symbol = self.lookupN(label: name.first)
                {
                return(symbol.nilIfEmpty)
                }
            }
        else if let start = self.lookupN(label: name.first)
            {
            if let symbol = start.first?.lookupN(name: name.withoutFirst)
                {
                return(symbol.nilIfEmpty)
                }
            }
        return(self.module?.lookupN(name: name))
        }
        
    public func layoutObjectSlots()
        {
        }
        
    public func layoutInMemory(using: AddressAllocator)
        {
        }
        
    public func install(inContext: ExecutionContext)
        {
        }
        
    public func addDeclaration(_ location:Location)
        {
        for index in 0..<self.locations.count
            {
            if self.locations[index].isDeclaration
                {
                self.locations[index] = .declaration(location)
                return
                }
            }
        self.locations.append(.declaration(location))
        }
        
//    public func superclass(_ string: String) -> Class
//        {
//        fatalError("This should have been overridden")
//        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
    }

public typealias SymbolDictionary = Dictionary<Label,Symbol>
public typealias Symbols = Array<Symbol>

