//
//  Transaction.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/9/21.
//

import Foundation

public class Transaction:Equatable
    {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool
        {
        return(lhs.key == rhs.key)
        }

    internal enum Holder: Equatable
        {
        case node(Node)
        case block(Block)
        
        public func addSymbol(_ symbol:Symbol)
            {
            switch(self)
                {
                case .node(let node):
                    node.addSymbol(symbol)
                case .block(let block):
                    block.addSymbol(symbol)
                }
            }
            
        public func removeSymbol(_ symbol:Symbol)
            {
            switch(self)
                {
                case .node(let node):
                    node.removeSymbol(symbol)
                case .block(let block):
                    block.removeSymbol(symbol)
                }
            }
        }
        
    public enum Action: Equatable
        {
        case add
        case remove
        
        internal func reverse(entity: Symbol,on target: Holder)
            {
            switch(self)
                {
                case .add:
                    target.removeSymbol(entity)
                case .remove:
                    target.addSymbol(entity)
                }
            }
        }

    public struct Command: Equatable
        {
        private let action: Action
        private let entity: Symbol
        private let target: Holder
        
        init(entity: Symbol,action: Action,target: Holder)
            {
            self.entity = entity
            self.action = action
            self.target = target
            }
            
        public func reverse()
            {
            self.action.reverse(entity: entity,on: target)
            }
        }
        
    internal typealias Commands = Array<Command>
        
    private let key: UUID = UUID()
    private var commands: Array<Command> = []
    
    internal init(commands: Commands)
        {
        self.commands = commands
        }
        
    public func copy() -> Transaction
        {
        Transaction(commands: commands)
        }
        
    public static private(set) var current = Transaction(commands: [])
    
    public func rollback()
        {
        for command in self.commands
            {
            command.reverse()
            }
        }
        
    @discardableResult
    public static func begin() -> Transaction
        {
        self.current = Transaction(commands: [])
        return(self.current)
        }
        
    public static func abort()
        {
        self.current.rollback()
        self.current.commands = []
        }
        
    public static func commit()
        {
        self.current.commands = []
        }
        
    internal static func recordAddSymbol(_ symbol: Symbol,to target: Holder)
        {
        self.current.commands.append(Command(entity: symbol,action: .add,target: target))
        }
        
    internal static func recordRemoveSymbol(_ symbol: Symbol,to target: Holder)
        {
        self.current.commands.append(Command(entity: symbol,action: .remove,target: target))
        }
    }
