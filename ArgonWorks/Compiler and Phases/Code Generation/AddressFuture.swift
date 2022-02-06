//
//  AddressFuture.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/2/22.
//

import Foundation

public class Future<R,T>
    {
    private var root: R
    private let path: WritableKeyPath<R,T>
    
    init(root: R,path: WritableKeyPath<R,T>)
        {
        self.root = root
        self.path = path
        }
        
    public func setValue(_ value: T)
        {
        self.root[keyPath: path] = value
        }
    }

public class FutureHolder<R,T>
    {
    private var futures = Array<Future<R,T>>()
    
    public func addFuture(_ future: Future<R,T>)
        {
        self.futures.append(future)
        }
        
    public func setValue(_ value: T)
        {
        for future in self.futures
            {
            future.setValue(value)
            }
        }
    }
