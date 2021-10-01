//
//  PersistentSetPage.swift
//  PersistentSetPage
//
//  Created by Vincent Coetzee on 2/9/21.
//

import Foundation

public class PersistentSetPage: Page
    {
    private static let kCountOnPageOffset:Int = 88
    private static let kCountInSetOffset:Int = 96
    private static let kSetPrime:Int = 5099
    private static let kPrimeOffset:Int = 104
    
    override init(virtualMachine: VirtualMachine)
        {
        super.init(virtualMachine: virtualMachine)
        self.setValue(0, atOffset: Self.kCountOnPageOffset)
        self.setValue(0, atOffset: Self.kCountInSetOffset)
        self.setValue(Self.kSetPrime, atOffset: Self.kPrimeOffset)
        }
        
    public func insert(address:Word)
        {
//        let innerPointer = GeneralPointer(address: address,class: self.virtualMachine.argonModule.object)
//        let hashValue = innerPointer.hashValue
        }
    }
