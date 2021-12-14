//
//  AddressAllocator.swift
//  AddressAllocator
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class AddressAllocator: CompilerPass
    {
    public let compiler: Compiler
    public var wasCancelled = false
    public let stackSegment: StackSegment
    public let dataSegment: DataSegment
    public let staticSegment: StaticSegment
    public let managedSegment: ManagedSegment
    
    init(_ compiler: Compiler)
        {
        self.compiler = compiler
        self.stackSegment = StackSegment(memorySize: .megabytes(25),argonModule: compiler.argonModule)
        self.dataSegment = DataSegment(memorySize: .megabytes(25),argonModule: compiler.argonModule)
        self.staticSegment = StaticSegment(memorySize: .megabytes(25),argonModule: compiler.argonModule)
        self.managedSegment = ManagedSegment(memorySize: .megabytes(25),argonModule: compiler.argonModule)
        }
        
    public func cancelCompletion()
        {
        self.wasCancelled = true
        }
        
    public func processModule(_ module: Module?) -> Module?
        {
        do
            {
            guard let module = module else
                {
                return(nil)
                }
            let newModule = try module.moduleWithAllocatedAddresses(using: self)
            guard !self.wasCancelled else
                {
                return(nil)
                }
            return(newModule)
            }
        catch let error as CompilerIssue
            {
            module?.appendIssue(error)
            }
        catch let error
            {
            module?.appendIssue(at: module!.declaration!, message: "Unexpected error: \(error).")
            }
        return(nil)
        }
    }
