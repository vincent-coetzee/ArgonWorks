//
//  ForwardReferenceClass.swift
//  ForwardReferenceClass
//
//  Created by Vincent Coetzee on 17/8/21.
//

import Foundation

public class ForwardReferenceClass: Class
    {
    private let localName: Name
    private let context: Context?
    internal var theClass: Class?
    
    init(name: Name,context: Context? = nil)
        {
        self.localName = name
        self.context = context
        super.init(label: name.last)
        }
    
    required public override init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func allocateAddresses(using allocator:AddressAllocator)
        {
        }
        
    public func realizeClass()
        {
        let aContext = self.context.isNil ? Context.node(TopModule.shared.argonModule) : self.context!
        self.theClass = aContext.lookup(name: self.localName) as? Class
        if self.theClass.isNil
            {
            NullReportingContext.shared.dispatchError(at: self.declaration!, message: "The forward reference to class '\(self.localName)' could not be resolved.")
            }
        }
        
    public override func realize(using realizer: Realizer)
        {
        let aContext = self.context.isNil ? Context.node(realizer.virtualMachine.topModule.argonModule) : self.context!
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

    public override func emitCode(into instance: InstructionBuffer,using: CodeGenerator) throws
        {
        fatalError()
        }
    }
