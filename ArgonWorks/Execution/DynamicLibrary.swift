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
        
    private let path: String
    private var handle: UnsafeMutableRawPointer!
    
    init(path:String)
        {
        self.path = path
        self.handle = dlopen(self.path,RTLD_LOCAL)
        if self.handle == nil
            {
            print(String(cString: dlerror()!))
            }
        }
        
    init()
        {
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
