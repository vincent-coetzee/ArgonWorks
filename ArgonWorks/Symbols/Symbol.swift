//
//  Symbol.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import AppKit
import SwiftUI

public class Symbol:Node,ParseNode
    {
    public var defaultColor: NSColor
        {
        NSColor.argonZomp
        }
    
    public var isEnumeration: Bool
        {
        return(false)
        }
        
    public var isSymbolContainer: Bool
        {
        return(false)
        }
        
    public var isSystemSymbol: Bool
        {
        return(false)
        }
        
    public var isClassParameter: Bool
        {
        return(false)
        }
        
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
        
    public func newItemButton(_ binding:Binding<String?>) -> AnyView
        {
        return(AnyView(EmptyView()))
        }
        
    public func newItemView(_ binding:Binding<String>) -> AnyView
        {
        return(AnyView(EmptyView()))
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
        
    public var imageName: String
        {
        "IconEmpty"
        }
        
    public var symbolColor: NSColor
        {
        .black
        }
        
    public var childCount: Int
        {
        return(self.children?.count ?? 0)
        }
        
    public var isExpandable: Bool
        {
        return(false)
        }
        
    public var symbolType: SymbolType
        {
        .none
        }    
    
    public var typeCode:TypeCode
        {
        fatalError("TypeCode being called on Symbol which is not valid")
        }
        
    public var children:Symbols?
        {
        return(nil)
        }
 
    public var allChildren: Symbols
        {
        return([])
        }
        
    public var weight: Int
        {
        10
        }
        
    public var memoryAddress: Word
        {
        get
            {
            return(self.addresses.memoryAddress!.memoryAddress)
            }
        }
        
    public func realizeSuperclasses()
        {
        }
        
   public func allocateAddresses(using: AddressAllocator)
        {
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
        
    internal var isMemoryLayoutDone: Bool = false
    internal var isSlotLayoutDone: Bool = false
    internal var locations: SourceLocations = SourceLocations()
    public var privacyScope:PrivacyScope? = nil
    internal var addresses = Addresses()
    internal var source: String?
    
    public override init(label:Label)
        {
        super.init(label:label)
        self.addresses.append(.absolute(0))
        }
    
    public required init?(coder: NSCoder)
        {
        self.privacyScope = PrivacyScope(rawValue: coder.decodeObject(forKey: "privacyScope") as! String)!
        self.source = coder.decodeObject(forKey: "source") as? String
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self.privacyScope?.rawValue,forKey: "privacyScope")
        coder.encode(self.source,forKey: "source")
        }
        
    public func configure(cell: HierarchyCellView,foregroundColor: NSColor? = nil)
        {
        cell.text.stringValue = self.displayString
        let image = NSImage(named: self.imageName)!
        image.isTemplate = true
        cell.icon.image = image
        cell.icon.contentTintColor = foregroundColor.isNil ? self.defaultColor : foregroundColor!
        cell.text.textColor = foregroundColor.isNil ? self.defaultColor : foregroundColor!
        }

    public func invert(cell: HierarchyCellView)
        {
        let image = NSImage(named: self.imageName)!.image(withTintColor: NSColor.black)
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
        return(self.children![atIndex])
        }
        
    public override func removeSymbol(_ symbol: Symbol)
        {
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
        }
            
    public func isExpandable(forChildType type: ChildType) -> Bool
        {
        return(self.isExpandable && self.childCount(forChildType: type) > 0)
        }
        
    public func children(forChildType type: ChildType) -> Array<Symbol>
        {
        let allKids = self.children ?? []
        if type == .class
            {
            return(allKids.filter{$0 is Class || $0 is SymbolGroup}.sorted{$0.label < $1.label})
            }
        else if type == .method
            {
            return(allKids.filter{$0 is Method || $0 is MethodInstance || $0 is Module || $0 is SymbolGroup}.sorted{$0.label < $1.label})
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
        
    public func layoutInMemory()
        {
        self.isMemoryLayoutDone = true
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
        
    public func superclass(_ string: String) -> Class
        {
        fatalError("This should have been overridden")
        }
        
    public func removeObject(taggedWith: Int)
        {
        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
    }

public typealias SymbolDictionary = Dictionary<Label,Symbol>
public typealias Symbols = Array<Symbol>

