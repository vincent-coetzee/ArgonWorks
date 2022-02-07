//
//  SymbolTable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/12/21.
//

import Foundation

public class SymbolRegistry
    {
    private static let kTableSize:Word = 39829

    private var rootNodeAddress: Address
    private let context: ExecutionContext
    private var nextIndex: Int = 1
    private var vector: Address = 0
    private let vectorPointer: VectorPointer
    
    init(context: ExecutionContext)
        {
        self.context = context
        self.rootNodeAddress = 0
        self.vector = context.staticSegment.allocateVector(size: 10_000)
        self.vectorPointer = VectorPointer(address: self.vector, segment: self.context.staticSegment)
        }
        
    public func write(toStream onStream: UnsafeMutablePointer<FILE>)
        {
        var address = self.rootNodeAddress
        fwrite(&address,MemoryLayout<Word>.size,1,onStream)
        address = self.vector
        fwrite(&address,MemoryLayout<Word>.size,1,onStream)
        var index = Word(integer: self.nextIndex)
        fwrite(&index,MemoryLayout<Word>.size,1,onStream)
        }
        
    public func registerSymbol(_ symbol: Argon.Symbol) -> Int
        {
        if symbol.isEmpty || symbol == "#"
            {
            return(0)
            }
        let cleanSymbol = symbol.hasPrefix("#") ? String(symbol.dropFirst()) : symbol
        if self.rootNodeAddress.isNil
            {
            self.rootNodeAddress = self.context.staticSegment.allocateObject(ofType: ArgonModule.shared.treeNode,extraSizeInBytes: 0)
            let pointer = TreeNodePointer(dirtyAddress: self.rootNodeAddress)!
            let symbolAddress = self.context.staticSegment.allocateSymbol(cleanSymbol)
            let index = self.nextIndex
            pointer.payload1 = Word(integer: index)
            self.nextIndex += 1
            pointer.keyAddress = self.context.staticSegment.allocateString(cleanSymbol)
            pointer.valueAddress = symbolAddress
            self.vectorPointer[index] = symbolAddress
            return(index)
            }
        else
            {
            let root = TreeNodePointer(dirtyAddress: self.rootNodeAddress)!
            if let node = root.nodeAtKey(cleanSymbol)
                {
                return(node.payload1.intValue)
                }
            let symbolAddress = self.context.staticSegment.allocateSymbol(cleanSymbol)
            let index = self.nextIndex
            self.nextIndex += 1
            let pointer = root.setValue(symbolAddress, forKey: cleanSymbol,inSegment: self.context.staticSegment)
            pointer.payload1 = Word(integer: index)
            self.vectorPointer[index] = symbolAddress
            return(index)
            }
        }
        
    public func symbolAddress(atSymbol: Int) -> Address?
        {
        return(self.vectorPointer[atSymbol])
        }
        
    public func dump()
        {
        if self.rootNodeAddress == 0
            {
            return
            }
        let root = TreeNodePointer(dirtyAddress: self.rootNodeAddress)!
        root.printNode()
        }
    }
