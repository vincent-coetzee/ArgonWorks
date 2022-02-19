//
//  TopologicalSorter.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/2/22.
//

import Foundation

public class TopologicalSorter
    {
    private var result = Array<TypeClass>()
    private var stack = Stack<TypeClass>()
    private var vertices = TypeClasses()
    private var incoming = Dictionary<TypeClass,Int>()
    private let theClass: TypeClass
    
    init(class aClass: TypeClass)
        {
        self.theClass = aClass
        self.initSort()
        }
        
    private func initSort()
        {
        self.vertices = self.theClass.allSuperclasses
        for clazz in self.theClass.allSuperclasses
            {
            self.incoming[clazz] = 0
            }
        }
        
    private func adjacentVertices(to: TypeClass) -> TypeClasses
        {
        return(to.superclasses)
        }
        
    public func sortedClasses() -> TypeClasses
        {
        for vertex in self.vertices
            {
            for u in self.adjacentVertices(to: vertex)
                {
                let value = self.incoming[u]!
                self.incoming[u] = value + 1
                }
            }
        for vertex in self.vertices
            {
            if self.incoming[vertex]! == 0
                {
                self.stack.push(vertex)
                }
            }
        while !self.stack.isEmpty
            {
            let vertex = self.stack.pop()
            self.result.append(vertex)
            for u in self.adjacentVertices(to: vertex).reversed()
                {
                let value = self.incoming[u]!
                self.incoming[u] = value - 1
                if self.incoming[u]! == 0
                    {
                    self.stack.push(u)
                    }
                }
            }
        return(result)
        }
    }
