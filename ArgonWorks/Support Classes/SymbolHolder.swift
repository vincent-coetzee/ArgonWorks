//
//  SymbolHolder.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 16/7/21.
//

import Foundation

//public class SymbolHolder:Symbol
//    {
//    private static var list:Array<SymbolHolder> = []
//    private let symbolName: Name
//    private let reporter: Reporter
//    private let location: Location
//    public private(set) var symbol: Symbol?
//    private let types: Classes?
//    
//    init(name:Name,location:Location,namingContext:NamingContext?,reporter:Reporter,types:Classes? = nil)
//        {
//        self.symbolName = name
//        self.types = types
//        self.context = namingContext
//        self.reporter = reporter
//        self.location = location
//        super.init(label: name.string)
//        Self.list.append(self)
//        }
//    
//    public required init?(coder: NSCoder)
//        {
//        fatalError("init(coder:) has not been implemented")
//        }
//    
//     public required init(label: Label)
//        {
//        self.symbolName = Name()
//        self.context = nil
//        self.reporter = NullReporter.shared
//        self.location = .zero
//        self.types = Classes()
//        super.init(label: label)
//        }
//        
//    @discardableResult
//    public func reify() -> Symbol?
//        {
//        let theContext = context.isNil ? self.topModule.argonModule : context!
//        if let theSymbol = theContext.lookup(name: self.symbolName)
//            {
//            self.symbol = theSymbol
//            return(self.symbol!)
//            }
//        reporter.dispatchError(at: self.location,message: "Could not resolve symbol with reference \(self.symbolName), unresolved reference.")
//        return(nil)
//        }
//    }
//
//public typealias SymbolHolders = Array<SymbolHolder>
