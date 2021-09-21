//
//  DispatchNode.swift
//  DispatchNode
//
//  Created by Vincent Coetzee on 18/8/21.
//

import Foundation

public struct ClassNode
    {
    public let clazz: Type
    public let node: DispatchNode
    }
    
public class DispatchNode
    {
    internal let type: Type!
    internal let typeDepth: Int
    internal var score: Int = 0
    
    public var isLeaf: Bool
        {
        return(false)
        }
        
    init(type: Type)
        {
        self.type = type
        self.typeDepth = type.depth
        }
        
    init()
        {
        self.type = nil
        self.typeDepth = 0
        }
        
    public func addSignature(_ signature:  MethodSignature)
        {
        fatalError("")
        }
        
    internal func child(atType: Type) -> DispatchNode?
        {
        return(nil)
        }
        
    public func dispatch(with classes: Types) -> MethodInstance?
        {
        return(nil)
        }
    }
    
public class DispatchChildNode: DispatchNode
    {
    internal var children = Array<DispatchNode>()
    
    init(type: Type,signature: MethodSignature)
        {
        super.init(type: type)
        self.addSignature(signature)
        }
        
    override init()
        {
        super.init()
        }
        
    public override func addSignature(_ signature: MethodSignature)
        {
        if signature.parameters.count == 1
            {
            self.children.append(DispatchLeafNode(type: signature.firstParameter.type,instance: signature.instance))
            }
        else
            {
            if let node = self.child(atType: signature.firstParameter.type)
                {
                node.addSignature(signature.withoutFirst())
                }
            else
                {
                let node = DispatchChildNode(type: signature.firstParameter.type,signature: signature.withoutFirst())
                self.children.append(node)
                }
            }
        }
        
    internal override func child(atType type: Type) -> DispatchNode?
        {
        for child in self.children
            {
            if child.type == type
                {
                return(child)
                }
            }
        return(nil)
        }
        
    public override func dispatch(with classes: Types) -> MethodInstance?
        {
        if classes.isEmpty
            {
            return(nil)
            }
        let firstClass = classes.first!
        var nodes = Array<DispatchNode>()
        var lowestScoringNode:DispatchNode? = nil
        for node in self.children
            {
            if firstClass.isSubtype(of: node.type)
                {
                node.score = firstClass.depth - node.type.depth
                if lowestScoringNode.isNil
                    {
                    lowestScoringNode = node
                    }
                else if node.score < lowestScoringNode!.score
                    {
                    lowestScoringNode = node
                    }
                nodes.append(node)
                }
            }
        if lowestScoringNode.isNil
            {
            return(nil)
            }
        return(lowestScoringNode!.dispatch(with: Types(classes.dropFirst())))
        }

    }
    
public class DispatchRootNode: DispatchChildNode
    {
    public static func rootNode(for signatures: MethodSignatures) -> DispatchRootNode
        {
        if signatures.count == 1
            {
            return(DirectDispatchRootNode(instance: signatures.first!.instance))
            }
        return(DispatchRootNode(signatures: signatures))
        }
        
    init(signatures: MethodSignatures)
        {
        super.init()
        for signature in signatures
            {
            self.addSignature(signature)
            }
        }
        
    override init()
        {
        super.init()
        }
    }
    
public class DirectDispatchRootNode: DispatchRootNode
    {
    private let instance: MethodInstance
    
    init(instance: MethodInstance)
        {
        self.instance = instance
        super.init()
        }
        
    public override func dispatch(with classes: Types) -> MethodInstance?
        {
        return(instance)
        }
    }
    
public class DispatchLeafNode: DispatchNode
    {
    private let instance: MethodInstance
    
    public override var isLeaf: Bool
        {
        return(true)
        }
        
    public init(type: Type,instance: MethodInstance)
        {
        self.instance = instance
        super.init(type: type)
        }
        
    public override func dispatch(with classes: Types) -> MethodInstance?
        {
        return(self.instance)
        }
    }

public typealias TypeSignature = Array<Class>
