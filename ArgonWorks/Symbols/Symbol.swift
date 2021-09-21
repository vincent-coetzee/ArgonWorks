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
    public var isEnumeration: Bool
        {
        return(false)
        }
        
    public var isClassParameter: Bool
        {
        return(false)
        }
        
    public var isClass: Bool
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
        
    public var displayName: String
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
        
    public func realizeSuperclasses(in vm: VirtualMachine)
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
    
    public func child(atIndex: Int) -> Symbol
        {
        return(self.children![atIndex])
        }
        
    public var isGroup: Bool
        {
        return(false)
        }
        
    public func directlyContains(symbol:Symbol) -> Bool
        {
        return(false)
        }
        
    public func layoutInMemory(in vm: VirtualMachine)
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
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
    }

public typealias SymbolDictionary = Dictionary<Label,Symbol>
public typealias Symbols = Array<Symbol>
