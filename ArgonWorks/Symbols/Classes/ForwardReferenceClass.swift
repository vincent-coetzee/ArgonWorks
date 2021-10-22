//
//  ForwardReferenceClass.swift
//  ForwardReferenceClass
//
//  Created by Vincent Coetzee on 17/8/21.
//

import Foundation

public class ForwardReferenceClass: Class
    {
    public override var isForwardReferenceClass: Bool
        {
        return(true)
        }
        
    private let localName: Name
    private let context: Context?
    internal var theClass: Class?
    
    init(name: Name,context: Context? = nil)
        {
        self.localName = name
        self.context = context
        super.init(label: name.last)
        }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func allocateAddresses(using allocator:AddressAllocator)
        {
        }
        
    public func realizeClass(topModule: TopModule)
        {
        let aContext = self.context.isNil ? Context.node(topModule.argonModule) : self.context!
        let newName = localName
//        newName.topModule = topModule
        self.theClass = aContext.lookup(name: newName) as? Class
        if self.theClass.isNil
            {
            NullReportingContext.shared.dispatchError(at: self.declaration!, message: "The forward reference to class '\(self.localName)' could not be resolved.")
            }
        }
        
    public override func realize(using realizer: Realizer)
        {
        let aContext = self.context.isNil ? Context.node(realizer.argonModule) : self.context!
        self.theClass = aContext.lookup(name: self.localName) as? Class
        if self.theClass.isNil
            {
            realizer.cancelCompletion()
            realizer.dispatchError(at: self.declaration!, message: "The forward reference to class '\(self.localName)' could not be resolved.")
            }
        }
        
    public override func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        fatalError()
        }

    public override func emitCode(into instance: T3ABuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
    }
