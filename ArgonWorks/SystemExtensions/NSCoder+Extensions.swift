//
//  NSCoder+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

extension NSCoder
    {
    public func decodeString(forKey: String) -> String?
        {
        let string = self.decodeObject(forKey: forKey)
        return(string as? String)
        }
        
    public func encode(_ parent: Parent,forKey key: String)
        {
        switch(parent)
            {
            case .none:
                self.encode(0,forKey: key + "type")
            case .node(let node):
                self.encode(1,forKey: key + "type")
                self.encode(node,forKey: key + "node")
            case .block(let block):
                self.encode(2,forKey: key + "type")
                self.encode(block,forKey: key + "block")
            case .expression(let expression):
                self.encode(3,forKey: key + "type")
                self.encode(expression,forKey: key + "expression")
            }
        }
        
    public func decodeParent(forKey key: String) -> Parent?
        {
        let type = self.decodeInteger(forKey: key + "type")
        switch(type)
            {
            case 0:
                return(Parent.none)
            case 1:
                return(Parent.node(self.decodeObject(forKey: key + "node") as! Node))
            case 2:
                return(Parent.block(self.decodeObject(forKey: key + "block") as! Block))
            case 3:
                return(Parent.expression(self.decodeObject(forKey: key + "expression") as! Expression))
            default:
                return(nil)
            }
        }
        
    public func encode(_ operand:Instruction.Operand,forKey: String)
        {
        switch(operand)
            {
        case .none:
            self.encode(1,forKey: forKey + "kind")
        case .register(let register):
            self.encode(2,forKey: forKey + "kind")
            self.encode(register.rawValue,forKey:forKey + "register")
        case .float(let float):
            self.encode(3,forKey: forKey + "kind")
            self.encode(float,forKey: forKey + "float")
        case .integer(let integer):
            self.encode(4,forKey: forKey + "kind")
            self.encode(integer,forKey: forKey + "integer")
        case .absolute(let word):
            self.encode(5,forKey: forKey + "kind")
            self.encode(word,forKey: forKey + "absolute")
        case .indirect(let register,let word):
            self.encode(6,forKey: forKey + "kind")
            self.encode(register.rawValue,forKey: forKey + "register")
            self.encode(word,forKey: forKey + "word")
        case .stack(let register,let integer):
            self.encode(7,forKey: forKey + "kind")
            self.encode(register.rawValue,forKey: forKey + "register")
            self.encode(integer,forKey: forKey + "integer")
        case .label(let integer):
            self.encode(8,forKey: forKey + "kind")
            self.encode(integer,forKey: forKey + "integer")
        case .relocation(let value):
            self.encode(9,forKey: forKey + "kind")
            self.encode(value,forKey: forKey + "value")
            }
        }
        
    public func decodeOperand(forKey: String) -> Instruction.Operand?
        {
        let kind = self.decodeInteger(forKey: forKey + "kind")
        switch(kind)
            {
            case 1:
                return(Instruction.Operand.none)
            case 2:
                let register = Instruction.Register(rawValue: self.decodeInteger(forKey: forKey + "register"))!
                return(.register(register))
            case 3:
                let float = self.decodeDouble(forKey: forKey + "float")
                return(.float(float))
            case 4:
                let integer = self.decodeInteger(forKey: forKey + "integer")
                return(.integer(Argon.Integer(integer)))
            case 5:
                let word = Word(self.decodeInteger(forKey: forKey + "absolute"))
                return(.absolute(word))
            case 6:
                let register = Instruction.Register(rawValue: self.decodeInteger(forKey: forKey + "register"))!
                let word = Word(self.decodeInteger(forKey: forKey + "word"))
                return(.indirect(register,word))
            case 7:
                let register = Instruction.Register(rawValue: self.decodeInteger(forKey: forKey + "register"))!
                let word = self.decodeInteger(forKey: forKey + "integer")
                return(.stack(register,Argon.Integer(word)))
            case 8:
                let integer = Argon.Integer(self.decodeInteger(forKey: forKey + "integer"))
                return(.label(integer))
            case 9:
                let value = self.decodeObject(forKey: forKey + "value") as! Instruction.LiteralValue
                return(.relocation(value))
            default:
                return(nil)
            }
        }
    }
