//
//  Capsule.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/9/21.
//

import Foundation

public class Capsule
    {
    public let path: URL
    public var transaction: Transaction?
    public let date: Date
    public let key: UUID
    public var compilationProduct: ParseNode?
    public var source: String = ""
    
    init(path: URL)
        {
        self.path = path
        self.date = Date()
        self.key = UUID()
        }
        
    public func with(source:String, product: ParseNode,transaction: Transaction)
        {
        self.source = source
        self.transaction = transaction
        self.compilationProduct = product
        }
    }
