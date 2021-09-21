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
        self.names["Integer"] = "i"
        self.names["UInteger"] = "u"
        self.names["Float"] = "f"
        self.names["String"] = "s"
        self.names["Array"] = "a"
        self.names["Dictionary"] = "d"
        self.names["List"] = "l"
        self.names["Set"] = "t"
        self.names["Object"] = "o"
        self.names["Pointer"] = "p"
        self.names["Slot"] = "S"
        self.names["Instruction"] = "I"
        self.names["Class"] = "c"
        self.names["Type"] = "y"
        self.names["Variable"] = "v"
        self.names["Method"] = "m"
        self.names["Void"] = "V"
        }
        
    private func encoding(forKey: String) -> String
        {
        if let encoding = self.names[forKey]
            {
            return(encoding)
            }
        return("%\(forKey)*")
        }
        
    private func mangle(type: Type) -> String
        {
        return("")
        }
        
    public func mangle(_ methodInstance: MethodInstance) -> String
        {
        var mangled = "m"
        mangled += methodInstance.label
        mangled += "_"
        mangled += self.encoding(forKey: methodInstance.returnType.label)
        mangled += "<>"
//        for type in methodInstance.parameters
//            {
////            let encoding = self.mangle(type: type.type)
//            }
        return("")
        }
    }
