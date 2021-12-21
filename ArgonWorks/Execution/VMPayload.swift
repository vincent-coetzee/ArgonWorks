//
//  VMPayload.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 20/12/21.
//

import Foundation

public struct VMPayload: ExecutionContext
    {
    public let stackSegment: StackSegment
    public let staticSegment: StaticSegment
    public let managedSegment: ManagedSegment
    public let codeSegment: CodeSegment

    public var symbolTable: SymbolTable
        {
        self._symbolTable
        }
        
    private var _symbolTable: SymbolTable!
    
    init()
        {
        self.stackSegment = try! StackSegment(memorySize: .megabytes(25),argonModule: ArgonModule.shared)
        self.staticSegment = try! StaticSegment(memorySize: .megabytes(25),argonModule: ArgonModule.shared)
        self.managedSegment = try! ManagedSegment(memorySize: .megabytes(25),argonModule: ArgonModule.shared)
        self.codeSegment = try! CodeSegment(memorySize: .megabytes(50),argonModule: ArgonModule.shared)
        self._symbolTable = SymbolTable(context: self)
        }
        
    init(stackSegmentSize: MemorySize = .megabytes(25),staticSegmentSize:MemorySize = .megabytes(25),managedSegmentSize: MemorySize = .megabytes(50),codeSegmentSize: MemorySize = .megabytes(25))
        {
        self.stackSegment = try! StackSegment(memorySize: stackSegmentSize,argonModule: ArgonModule.shared)
        self.staticSegment = try! StaticSegment(memorySize: staticSegmentSize,argonModule: ArgonModule.shared)
        self.managedSegment = try! ManagedSegment(memorySize: managedSegmentSize,argonModule: ArgonModule.shared)
        self.codeSegment = try! CodeSegment(memorySize: codeSegmentSize,argonModule: ArgonModule.shared)
        self._symbolTable = SymbolTable(context: self)
        }
        
    public func segment(for symbol: Symbol) -> Segment
        {
        switch(symbol.segmentType)
            {
            case .empty:
                break
            case .static:
                return(self.staticSegment)
            case .managed:
                return(self.managedSegment)
            case .stack:
                return(self.stackSegment)
            case .code:
                return(self.codeSegment)
            }
        fatalError("Can not determine segment")
        }
        
    public func write(toPath: String) throws
        {
        guard let fileStream = fopen(toPath,"wb") else
            {
            throw(CompilerIssue(location: .zero,message: "Could not open file at path '\(toPath)'."))
            }
        ///
        ///
        /// Before we write the segments out need to write a small table detailing
        /// the number of segments written out, the order of the segments and their
        /// sizes.
        ///
        let segments = [self.codeSegment,self.stackSegment,self.staticSegment,self.managedSegment]
        var count: Word = 4
        fwrite(&count,MemoryLayout<Word>.size,1,fileStream)
        for segment in segments
            {
            var type = segment.segmentType.rawValue
            var used = Word(segment.usedSizeInBytes)
            var allocated = Word(segment.allocatedSizeInBytes)
            fwrite(&type,MemoryLayout<Word>.size,1,fileStream)
            fwrite(&used,MemoryLayout<Word>.size,1,fileStream)
            fwrite(&allocated,MemoryLayout<Word>.size,1,fileStream)
            }
        for segment in segments
            {
            try segment.write(toStream: fileStream)
            }
        fflush(fileStream)
        fclose(fileStream)
        }
    }
