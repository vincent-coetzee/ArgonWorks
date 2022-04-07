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
    public var argonTypes: Address = 0
    public var clientModuleTypes: Address = 0
    public var clientModuleMethodInstances: Address = 0
    public var mainMethod: Address = Argon.kNullTag
    
    private var primitiveTable: PrimitiveVectorTable
    
    public var symbolRegistry: SymbolRegistry
        {
        self._symbolRegistry
        }
        
    private var _symbolRegistry: SymbolRegistry!
    
    init(argonModule: ArgonModule)
        {
        self.stackSegment = try! StackSegment(memorySize: .megabytes(25),argonModule: argonModule)
        self.staticSegment = try! StaticSegment(memorySize: .megabytes(25),argonModule: argonModule)
        self.managedSegment = try! ManagedSegment(memorySize: .megabytes(25),argonModule: argonModule)
        self.codeSegment = try! CodeSegment(memorySize: .megabytes(50),argonModule: argonModule)
        self.primitiveTable = try! PrimitiveVectorTable()
        self._symbolRegistry = SymbolRegistry(context: self)
        }
        
    init(argonModule: ArgonModule,nullSegmentSize: MemorySize = .megabytes(10),stackSegmentSize: MemorySize = .megabytes(25),staticSegmentSize:MemorySize = .megabytes(25),managedSegmentSize: MemorySize = .megabytes(50),codeSegmentSize: MemorySize = .megabytes(25))
        {
        self.stackSegment = try! StackSegment(memorySize: stackSegmentSize,argonModule: argonModule)
        self.staticSegment = try! StaticSegment(memorySize: staticSegmentSize,argonModule: argonModule)
        self.managedSegment = try! ManagedSegment(memorySize: managedSegmentSize,argonModule: argonModule)
        self.codeSegment = try! CodeSegment(memorySize: codeSegmentSize,argonModule: argonModule)
        self.primitiveTable = try! PrimitiveVectorTable()
        self._symbolRegistry = SymbolRegistry(context: self)
        }
        
    public func segment(for symbol: Symbol) -> Segment
        {
        switch(symbol.segmentType)
            {
            case .static:
                return(self.staticSegment)
            case .managed:
                return(self.managedSegment)
            case .stack:
                return(self.stackSegment)
            case .code:
                return(self.codeSegment)
            case .space:
                fatalError()
            }
        }
        
    public func address(forPrimitiveIndex: Int) -> Address
        {
        return(self.primitiveTable.address(forIndex: forPrimitiveIndex))
        }
        
    public mutating func installMainMethod(_ method: MethodInstance?)
        {
        self.mainMethod = method.isNil ? Argon.kNullTag : method!.memoryAddress
        }
        
    public mutating func installArgonModule(_ module: ArgonModule)
        {
        let types = module.allSymbols.compactMap{$0 as? Type}.sorted{$0.label < $1.label}
        let array = self.staticSegment.allocateArray(size: types.count, elements: Addresses())
        let pointer = ArrayPointer(dirtyAddress: array,argonModule: self.codeSegment.argonModule)!
        for type in types
            {
            pointer.append(type.memoryAddress)
//            MemoryPointer.dumpMemory(atAddress: type.memoryAddress, count: 20)
            }
        self.argonTypes = array
        print(array)
        MemoryPointer.dumpMemory(atAddress: array, count: 50)
        }
        
    public mutating func installClientModule(_ module: Module)
        {
        module.install(inContext: self)
        let types = module.allSymbols.compactMap{$0 as? Type}
        let array = self.staticSegment.allocateArray(size: types.count, elements: Addresses())
        let pointer = ArrayPointer(dirtyAddress: array,argonModule: self.codeSegment.argonModule)!
        for type in types
            {
            pointer.append(type.memoryAddress)
            }
        self.clientModuleTypes = array
        let instances = module.allSymbols.compactMap{$0 as? MethodInstance}
        let methods = self.staticSegment.allocateArray(size: instances.count, elements: Addresses())
        let methodPointer = ArrayPointer(dirtyAddress: methods,argonModule: self.codeSegment.argonModule)!
        for instance in instances
            {
            methodPointer.append(instance.memoryAddress)
            }
        self.clientModuleMethodInstances = methods
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
        /// sizes. We then write out the address of the Argon types array and the
        /// module types array and the module methods array.
        ///
        /// COUNT
        /// TYPE SPACE-USED SPACE-ALLOCATED ADDRESS-OF-ALLOCATION
        /// ADDRESS OF ARGON TYPE TABLE
        /// ADDRESS OF MODULE TYPE TABLE
        /// ADDRESS OF MODULE METHOD INSTANCE TABLE
        ///
        let segments = [self.codeSegment,self.stackSegment,self.staticSegment,self.managedSegment]
        var count: Word = 4
        fwrite(&count,MemoryLayout<Word>.size,1,fileStream)
        for segment in segments
            {
            var type = segment.segmentType.rawValue
            var used = Word(segment.usedSizeInBytes)
            var allocated = Word(segment.allocatedSizeInBytes)
            var address = segment.baseAddress
            fwrite(&type,MemoryLayout<Word>.size,1,fileStream)
            fwrite(&used,MemoryLayout<Word>.size,1,fileStream)
            fwrite(&allocated,MemoryLayout<Word>.size,1,fileStream)
            fwrite(&address,MemoryLayout<Word>.size,1,fileStream)
            }
        count = 0xD00D_AAA
        fwrite(&count,MemoryLayout<Word>.size,1,fileStream)
        var addressValue = self.argonTypes
        fwrite(&addressValue,MemoryLayout<Word>.size,1,fileStream)
        addressValue = self.clientModuleTypes
        fwrite(&addressValue,MemoryLayout<Word>.size,1,fileStream)
        addressValue = self.clientModuleMethodInstances
        fwrite(&addressValue,MemoryLayout<Word>.size,1,fileStream)
        addressValue = self.mainMethod
        fwrite(&addressValue,MemoryLayout<Word>.size,1,fileStream)
        self.symbolRegistry.write(toStream: fileStream)
        count = 0xD00D_BBB
        fwrite(&count,MemoryLayout<Word>.size,1,fileStream)
        self.primitiveTable.write(toStream: fileStream)
        count = 0xD00D_CCC
        fwrite(&count,MemoryLayout<Word>.size,1,fileStream)
        for segment in segments
            {
            try segment.write(toStream: fileStream)
            count = 0xDED_BED
            fwrite(&count,MemoryLayout<Word>.size,1,fileStream)
            }
        addressValue = 0xD00D_DDD
        fwrite(&addressValue,MemoryLayout<Word>.size,1,fileStream)
        fflush(fileStream)
        fclose(fileStream)
        }
    }
