//
//  VirtualMachine.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 16/12/21.
//

import Foundation

public protocol ExecutionContext
    {
    var stackSegment: StackSegment { get }
    var managedSegment: ManagedSegment { get }
    var staticSegment: StaticSegment { get }
    var codeSegment: CodeSegment { get }
    var symbolRegistry: SymbolRegistry { get }
    func segment(for: Symbol) -> Segment
    }
    
public class VirtualMachine
    {
    private var loadedObjectFiles: Array<ObjectFile>
    internal let payload: VMPayload
    
    init(payload: VMPayload)
        {
        self.payload = payload
        self.loadedObjectFiles = []
        }
        
    init()
        {
        self.payload = VMPayload()
        self.loadedObjectFiles = []
        }
        
    public func segment(for symbol: Symbol) -> Segment
        {
        return(self.payload.segment(for: symbol))
        }
        
    public func loadObjectFile(atPath path: String) throws
        {
        if let objectFile = try ObjectFile.read(atPath: path,topModule: TopModule.shared)
            {
            self.loadedObjectFiles.append(objectFile)
            }
        }
        
    public func prepareToExecute()
        {
        }
        
    public func display(address: Address,indent: String,count: Int)
        {
        let wordPointer = WordPointer(bitPattern: address.cleanAddress)
        var index = 0
        while index < count
            {
            let header = Header(atAddress: address + Word(index))
            print("HEADER: \(header.displayString)")
            for offset in (index + 1)..<(index + header.sizeInWords - 1)
                {
                let word = wordPointer[offset]
                let kind = word.tag.displayString
                let bitString = word.bitString
                var objectString = ""
                if word.tag == .pointer
                    {
                    if let objectPointer = ObjectPointer(dirtyAddress: word)
                        {
                        if objectPointer.classAddress == 0
                            {
                            objectString = "OBJECT WITH NO CLASS"
                            }
                        else
                            {
                            if let classPointer = objectPointer.classPointer
                                {
                                objectString = "OBJECT OF CLASS: \(classPointer.namePointer!.string)"
                                }
                            }
                        }
                    }
                let indexString = String(format: "%010d",offset)
                let integerString = String(format: "% 10d",word)
                print("\(indent)\(indexString) \(kind) \(bitString) \(integerString) \(objectString)")
                }
            index += header.sizeInWords
            }
        }
    }
