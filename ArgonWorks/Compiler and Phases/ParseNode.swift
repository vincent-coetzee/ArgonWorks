//
//  ParseNode.swift
//  ParseNode
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public protocol ParseNode
    {
//    var subNodes: Array<ParseNode>? { get }
    var type: Class { get }
    var privacyScope: PrivacyScope? { get set }
    func emitCode(using: CodeGenerator) throws
    func realize(using: Realizer)
    func realizeSuperclasses(in vm: VirtualMachine)
    func analyzeSemantics(using: SemanticAnalyzer)
    func allocateAddresses(using: AddressAllocator)
    }
