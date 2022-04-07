//
//  TypeApplication.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 30/11/21.
//

import Foundation

public class TypeApplication: Type
    {
    public override var hasVariableTypes: Bool
        {
        for type in self.types
            {
            if type.hasVariableTypes
                {
                return(true)
                }
            }
        return(false)
        }
        
    public override var argonHash: Int
        {
        var hashValue = "\(Swift.type(of: self))".polynomialRollingHash
        hashValue = hashValue << 13 ^ self.label.polynomialRollingHash
        hashValue = hashValue << 13 ^ self.function.argonHash
        for type in self.types
            {
            hashValue = hashValue << 13 ^ type.argonHash
            }
        let word = Word(bitPattern: hashValue) & ~Argon.kTagMask
        return(Int(bitPattern: word))
        }
        
    internal let function: TypeFunction
    internal let types: Types
    
    init(function: TypeFunction,types: Types)
        {
        self.function = function
        self.types = types
        super.init(label: "")
        }
    
    public override func typeCheck() throws
        {
        }
        
    required init?(coder: NSCoder)
        {
        self.function = coder.decodeObject(forKey: "function") as! TypeFunction
        self.types = coder.decodeObject(forKey: "types") as! Types
        super.init(coder: coder)
        }
    
    required init(label: Label)
        {
        fatalError()
        }
        
    init(label: Label,argonModule: ArgonModule)
        {
        self.types = []
        self.function = TypeFunction(label: "", types: [], returnType: argonModule.void)
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.function,forKey: "function")
        coder.encode(self.types,forKey: "types")
        super.encode(with: coder)
        }
    }
