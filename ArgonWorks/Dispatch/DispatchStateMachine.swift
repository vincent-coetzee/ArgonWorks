//
//  DispatchStateMachine.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/10/21.
//

import Foundation

//public struct DispatchGraph
//    {
//    private struct DispatchEdge
//        {
//        public let type: Type
//        public let node: DispatchNode
//        }
//        
//    private class DispatchNode
//        {
//        public var edges: Array<DispatchEdge> = []
//        
//        private func findEdge(withType: Type) -> DispatchEdge
//            {
//            
//            }
//            
//        private func addInstance(_ instance: MethodInstance,with parameters: Array<Parameter>)
//            {
//            guard !parameters.isEmpty else
//                {
//                
//            for edge in self.edges
//                {
//                if edge.type == instance
//                }
//            }
//        }
//        
//    private class DispatchTerminalNode: DispatchNode
//        {
//        public let instance: MethodInstance
//        
//        init(instance: MethodInstance)
//            {
//            self.instance = instance
//            }
//        }
//        
//    private var node: DispatchNode!
//    
//    init(method: Method)
//        {
//        self.buildGraph(with: method)
//        }
//        
//    private func buildGraph(with method: Method)
//        {
//        let first = DispatchNode()
//        for instance in method.instances
//            {
//            first.addInstance(instance,with: instance.parameters)
//            }
//        }
//    }
