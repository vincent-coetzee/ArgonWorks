//
//  BrowsingContext.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/4/22.
//

import Foundation

public class BrowsingContext: NSObject,NSCoding
    {
    public var classesRootItems: SymbolHolders!
    public var modulesRootItems: SymbolHolders!
    public var constantsRootItems: SymbolHolders!
    public var enumerationsRootItems: SymbolHolders!
    public var methodsRootItems: SymbolHolders!
    public var project: Project!
    public var argonModule: ArgonModule!
    public var topModule: TopModule!
    
    public override init()
        {
        }
        
    public required init?(coder: NSCoder)
        {
        self.methodsRootItems = coder.decodeObject(forKey: "methodsRootItems") as? SymbolHolders
        self.classesRootItems = coder.decodeObject(forKey: "classesRootItems") as? SymbolHolders
        self.modulesRootItems = coder.decodeObject(forKey: "modulesRootItems") as? SymbolHolders
        self.enumerationsRootItems = coder.decodeObject(forKey: "enumerationsRootItems") as? SymbolHolders
        self.constantsRootItems = coder.decodeObject(forKey: "constantsRootItems") as? SymbolHolders
        self.project = coder.decodeObject(forKey: "project") as? Project
        self.argonModule = coder.decodeObject(forKey: "argonModule") as? ArgonModule
        self.topModule = coder.decodeObject(forKey: "topModule") as? TopModule
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.methodsRootItems,forKey: "methodsRootItems")
        coder.encode(self.classesRootItems,forKey: "classesRootItems")
        coder.encode(self.enumerationsRootItems,forKey: "enumerationsRootItems")
        coder.encode(self.constantsRootItems,forKey: "constantsRootItems")
        coder.encode(self.modulesRootItems,forKey: "modulesRootItems")
        coder.encode(self.project,forKey: "project")
        coder.encode(self.topModule,forKey: "topModule")
        coder.encode(self.argonModule,forKey: "argonModule")
        }
    }
