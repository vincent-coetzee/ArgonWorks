//
//  NameMangler.swift
//  NameMangler
//
//  Created by Vincent Coetzee on 28/8/21.
//

import Foundation

public struct NameMangler
    {
    public var names: Dictionary<String,String> = [:]
    
    public init()
        {
        self.initNames()
        }
        
    private mutating func initNames()
        {
        self.names["Boolean"] = "b"
        self.names["Integer"] = "i"
        self.names["UInteger"] = "u"
        self.names["Float"] = "f"
        self.names["String"] = "s"
        self.names["Array"] = "A"
        self.names["Dictionary"] = "D"
        self.names["List"] = "L"
        self.names["Set"] = "S"
        self.names["Object"] = "o"
        self.names["Pointer"] = "p"
        self.names["Slot"] = "L"
        self.names["Instruction"] = "I"
        self.names["Class"] = "c"
        self.names["Type"] = "e"
        self.names["Variable"] = "v"
        self.names["Method"] = "m"
        self.names["Void"] = "V"
        self.names["Symbol"] = "l"
        self.names["Character"] = "h"
        self.names["Byte"] = "y"
        }
        
    private func encoding(forKey: String) -> String
        {
        if let encoding = self.names[forKey]
            {
            return(encoding)
            }
        return("%\(forKey)*")
        }
        
        
    public func mangle(_ methodInstance: MethodInstance) -> String
        {
        let count = methodInstance.parameters.count
        let start = "\(methodInstance.label)_\(count)_"
        let middle = methodInstance.parameters.map{$0.type!.mangledName}.joined(separator: "_")
        let end = methodInstance.returnType.mangledName
        return(start + middle + "_" + end)
        }
        
    public func mangle(_ function: Function) -> String
        {
        let count = function.parameters.count
        let start = "\(function.label)_\(count)_"
        let middle = function.parameters.map{$0.type!.mangledName}.joined(separator: "_")
        let end = function.returnType.mangledName
        return(start + middle + "_" + end)
        }
    }
