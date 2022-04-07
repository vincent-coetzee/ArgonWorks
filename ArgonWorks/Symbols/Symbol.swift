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
    public var argonModule: ArgonModule
        {
        self.container.argonModule
        }
        
    public var enclosingModule: Module
        {
        self.module
        }
        
    public var parentSymbol: Symbol?
        {
        self.module
        }
        
    public var classLabel: String
        {
        "\(Swift.type(of: self)) \(self.label)"
        }
        
    public var memoryAddressField: String
        {
        String(format: "%010llX",self.memoryAddress)
        }
        
    public var typeNameField: String
        {
        self.type.isNil ? "nil" : "\(Swift.type(of: self.type!))(\(self.type!.label))"
        }
    
    public var localLabel: Label
        {
        self.label
        }
        
    public var childOutlineItemCount: Int
        {
        1
        }

    public var hasChildOutlineItems: Bool
        {
        true
        }
        
    public var isOutlineItemExpandable: Bool
        {
        true
        }
    
    public static func ==(lhs:Symbol,rhs:Symbol) -> Bool
        {
        lhs.fullName == rhs.fullName
        }
        
    public var argonHash: Int
        {
        let hash1 = "Swift.type(of: self)".polynomialRollingHash
        let hash2 = self.label.polynomialRollingHash
        let hashValue = hash1 << 13 ^ hash2
        return(hashValue)
        }
        
    public var fullName: Name
        {
        self.module!.fullName + self.label
        }
        
    public var isEnumerationInstanceClass: Bool
        {
        false
        }
        
    public var identityHash: Int
        {
        var hash = 0
        if self.module.isNotNil
            {
            hash = self.module.identityHash
            }
        hash = hash << 13 ^ "\(Swift.type(of: self))".polynomialRollingHash
        hash = hash << 13 ^ self.label.polynomialRollingHash
        return(hash)
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
        
    public var isMethod: Bool
        {
        false
        }
        
    public var isLiteral: Bool
        {
        return(false)
        }
        
    ///
    /// This is the size in memory of the actual structure this represents.
    /// For example: the sizeInBytes of a TypeClass is the size of an instance
    /// of a class in memory.
    ///
    public var sizeInBytes: Int
        {
        fatalError()
        }
    ///
    ///
    /// This number represents the size of the actual instance of one of the
    /// receiver's types in memory. For example, the instance size in bytes is
    /// the amount of space an instance of the given class will take in memory.
    ///
    ///
    public var instanceSizeInBytes: Int
        {
        fatalError()
        }
    public var extraSizeInBytes: Int
        {
        0
        }
        
    public var isArgonModule: Bool
        {
        false
        }
        
    public var segmentType: Segment.SegmentType
        {
        .managed
        }

        
    public var isRootClass: Bool
        {
        false
        }
        
    public var isGenericType: Bool
        {
        return(false)
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
        
//    public var selectionColor: NSColor
//        {
//        get
//            {
//            if self._selectionColor.isNil
//                {
//                return(self.defaultColor)
//                }
//            return(self._selectionColor!)
//            }
//        set
//            {
//            self._selectionColor = newValue
//            }
//        }
//
    public var isSystemModule: Bool
        {
        return(false)
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
        "Module(\(self.label))"
        }
        
    public override var description: String
        {
        return("\(Swift.type(of:self))(\(self.label))")
        }
        
    public var iconName: String
        {
        "IconEmpty"
        }
        
    public var icon: NSImage
        {
        let image = NSImage(named: self.iconName)!
        image.isTemplate = true
        return(image)
        }
        
    public var iconTint: NSColor
        {
        SyntaxColorPalette.textColor
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
        
    public var isMetaclass: Bool
        {
        false
        }
        
    public var moduleScope: Module?
        {
        self.module
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
        
    public var displayName: String
        {
        self.label
        }
        
    public var allIssues: CompilerIssues
        {
        return(self.issues)
        }
        
    public var symbolType: SymbolType
        {
        .none
        }
        
    internal var wasAddressAllocationDone = false
    internal var wasInstallationDone = false
    internal var wasMemoryLayoutDone = false
    internal var wasSlotLayoutDone = false
    internal var locations: SourceLocations = SourceLocations()
    private var _selectionColor: NSColor?
    public private(set) var isImported = false
    public private(set) var loader: Loader?
    public var issues = CompilerIssues()
    public var type: Type!
    public var place: Instruction.Operand = .none
    public private(set) var memoryAddress: Address = 0
    public private(set) var module: Module!
    public var isSystemType = false
    public var itemKey: Int?
    public var container: Container!
    public var wasSymbolPatchingDone = false
    
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public required init?(coder: NSCoder)
        {
        let value = coder.decodeInteger(forKey: "itemKey")
        self.itemKey = value == -1 ? nil : value
        self.wasAddressAllocationDone = coder.decodeBool(forKey: "wasAddressAllocationDone")
        self.wasMemoryLayoutDone = coder.decodeBool(forKey: "wasMemoryLayoutDone")
        self.wasSlotLayoutDone = coder.decodeBool(forKey: "wasSlotLayoutDone")
        self.type = coder.decodeObject(forKey: "type") as? Type
        self.memoryAddress = Address(coder.decodeInteger(forKey: "memoryAddress"))
        self.issues = coder.decodeCompilerIssues(forKey: "issues")
        self.isSystemType = coder.decodeBool(forKey: "isSystemType")
        self.module = coder.decodeObject(forKey: "module") as? Module
        self.locations = coder.decodeSourceLocations(forKey: "symbolLocations")
        self.container = coder.decodeContainer(forKey: "container")
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encodeContainer(self.container,forKey: "container")
        coder.encode(self.itemKey.isNil ? -1 : self.itemKey!,forKey: "itemKey")
        coder.encode(self.isSystemType,forKey: "isSystemType")
        coder.encode(self.wasAddressAllocationDone,forKey: "wasAddressAllocationDone")
        coder.encode(self.wasMemoryLayoutDone,forKey: "wasMemoryLayoutDone")
        coder.encode(self.wasSlotLayoutDone,forKey: "wasSlotLayoutDone")
        coder.encodeSourceLocations(self.locations,forKey: "symbolLocations")
        coder.encode(self.type.isNil ? nil : TypeSurrogate(type: self.type!),forKey: "type")
        coder.encode(Int(self.memoryAddress),forKey: "memoryAddress")
        coder.encodeCompilerIssues(self.issues,forKey: "issues")
        coder.encode(self.module,forKey: "module")
        super.encode(with: coder)
        }
        
    public override func isEqual(_ object: Any?) -> Bool
        {
        if let second = object as? Symbol
            {
            return(self.label == second.label && self.module == second.module)
            }
        return(super.isEqual(object))
        }
        
    public func insertInHierarchy()
        {
        }
        
    public func postCompile(inSourceRecord sourceRecord: SourceRecord,inModule aModule: Module)
        {
        }
        
    public func patchSymbols(topModule: TopModule)
        {
        guard !self.wasSymbolPatchingDone else
            {
            return
            }
        self.wasSymbolPatchingDone = true
        self.type = self.type?.patchType(topModule: topModule)
        }
        
    public func patchType(topModule: TopModule) -> Type?
        {
        self as? Type
        }
        
    public func removeFromParentSymbol()
        {
        self.module.removeSymbol(self)
        }
        
    public func setModule(_ module: Module)
        {
        self.module = module
        }
        
    public func setMemoryAddress(_ address: Address)
        {
        self.memoryAddress = address
        }
        
    public func emitCode(using: CodeGenerator) throws
        {
        }
        
    public func emitCode(into: InstructionBuffer,using: CodeGenerator) throws
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
        
    public func inferType(inContext context: TypeContext)
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
            if self.isSystemType
                {
                return(SystemSymbolPlaceholder(original: self))
                }
            if self.isImported
                {
                return(ImportedSymbolPlaceholder(original: self))
                }
            }
        return(self)
        }
        
    public func assign(from: Expression,into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        fatalError("This should have been implemented in subclass \(Swift.type(of: self)).")
        }
        
    public func emitValueCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public func emitAddressCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        fatalError("This should have been overriden in a subclass.")
        }
        
    public func substitute(from substitution: TypeContext.Substitution) -> Self
        {
        let copy = Self.init(label: self.label)
        copy.setIndex(self.index)
        copy.type = substitution.substitute(self.type)
        copy.issues = self.issues
        return(copy)
        }
        
    public func display(indent: String)
        {
        print("\(indent)\(Swift.type(of: self)): \(self.label) \(self.type.displayString)")
        }
        
    public func replaceSymbol(_ source: Symbol,with replacement: Symbol)
        {
        }

    public func visit(visitor: Visitor) throws
        {
        try visitor.accept(self)
        }
        
    public func directlyContains(symbol:Symbol) -> Bool
        {
        return(false)
        }

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
        self.module.lookup(label: label)
        }

    public func lookup(name: Name) -> Symbol?
        {
        nil
        }
        
    public func lookupN(label: Label) -> Symbols?
        {
        return(self.module?.lookupN(label: label))
        }
        
    public func lookupType(label: Label) -> Type?
        {
        self.module.lookupType(label: label)
        }
        
    public func lookupMethod(label: Label) -> ArgonWorks.Method?
        {
        self.module.lookupMethod(label: label)
        }
        
    public func layoutObjectSlots()
        {
        self.wasSlotLayoutDone = true
        }
        
    public func layoutInMemory(using: AddressAllocator)
        {
        self.wasMemoryLayoutDone = true
        }
        
    public func install(inContext: ExecutionContext)
        {
        self.wasInstallationDone = true
        }
        
    public func inferType()
        {
        }
        
   public func allocateAddresses(using: AddressAllocator)
        {
        self.wasAddressAllocationDone = true
        }
        
    public func prepareSymbol(allocator: AddressAllocator)
        {
        self.layoutObjectSlots()
        self.allocateAddresses(using: allocator)
        self.layoutInMemory(using: allocator)
        self.install(inContext: allocator.payload)
        }
        
    public func addDeclaration(itemKey: Int,location aLocation: Location)
        {
        var location = aLocation
        location.itemKey = itemKey
        self.addDeclaration(location)
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
        
    public func addReference(itemKey: Int,location: Location)
        {
        var aLocation = location
        aLocation.itemKey = itemKey
        self.locations.append(.reference(aLocation))
        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
    }

public typealias SymbolDictionary = Dictionary<Label,Symbol>
public typealias Symbols = Array<Symbol>

