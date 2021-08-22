//
//  Dictionary+Extensions.swift
//  Dictionary+Extensions
//
//  Created by Vincent Coetzee on 14/8/21.
//

import Foundation

extension Dictionary where Key:Comparable
    {
    public var valuesByKey: KeyOrderSequence<Key,Value>
        {
        return(KeyOrderSequence(dictionary: self))
        }
    }

public class KeyOrderSequence<Key,Value>: Sequence where Key:Comparable,Key:Hashable
    {
    public struct KeyOrderIterator: IteratorProtocol
        {
        private let keys: Array<Key>
        private let dictionary: Dictionary<Key,Value>
        private var index: Int?
        
        init(dictionary: Dictionary<Key,Value>)
            {
            self.keys = dictionary.keys.sorted{$0 < $1}
            self.dictionary = dictionary
            }
            
        private func nextIndex(for index:Int?) -> Int?
            {
            if let index = self.index, index < self.keys.count - 1
                {
                return(index + 1)
                }
            if index.isNil, !self.keys.isEmpty
                {
                return(0)
                }
            return(nil)
            }
            
        public mutating func next() -> Value?
            {
            if let index = self.nextIndex(for: self.index)
                {
                self.index = index
                return(self.dictionary[self.keys[index]])
                }
            return(nil)
            }
        }
        
    private let dictionary: Dictionary<Key,Value>
        
    public init(dictionary: Dictionary<Key,Value>)
        {
        self.dictionary = dictionary
        }
        
    public func makeIterator() -> KeyOrderIterator
        {
        return(KeyOrderIterator(dictionary: dictionary))
        }
    }
