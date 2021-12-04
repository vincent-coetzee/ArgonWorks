//
//  ParseNode.swift
//  ParseNode
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public protocol ParseNode
    {
    var type: Type? { get }
    var privacyScope: PrivacyScope? { get set }
    func emitCode(using: CodeGenerator) throws
    func analyzeSemantics(using: SemanticAnalyzer)
    func allocateAddresses(using: AddressAllocator)
    }
