//
//  Library.swift
//  Library
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public struct DynamicLibrary
    {
    public static let emptyLibrary = DynamicLibrary()
    
    public struct Symbol
        {
        public let address:Word?
        public let label:String
        
        init(label:String,address:Word?)
            {
            self.label = label
            self.address = address
            }
        }
        
    public let path: String
    private var handle: UnsafeMutableRawPointer!
    private let openOnDemand: Bool
    
    init(openPathOnDemand path: String)
        {
        self.openOnDemand = true
        self.path = path
        }
        
    init(path:String)
        {
        self.openOnDemand = false
        self.path = path
        self.handle = dlopen(self.path,RTLD_LOCAL)
        if self.handle == nil
            {
            print(String(cString: dlerror()!))
            }
        }
        
    init()
        {
        self.openOnDemand = false
        self.path = ""
        self.handle = nil
        }
        
    public func findSymbol(_ symbol:String) -> Symbol?
        {
        let pointer = dlsym(self.handle,symbol)
        if pointer == nil
            {
            return(nil)
            }
        let address = Word(bitPattern: Int(bitPattern: pointer!))
        return(Symbol(label: symbol,address: address))
        }
    }
