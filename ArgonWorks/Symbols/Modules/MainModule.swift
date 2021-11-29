//
//  MainModule.swift
//  MainModule
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class MainModule: Module
    {
    public override var isMainModule: Bool
        {
        true
        }

    public override var firstMainModule: MainModule?
        {
        return(self)
        }
        
    public override var firstMainMethod: Method?
        {
        return(self.mainMethod)
        }
        
    public override var typeCode:TypeCode
        {
        .mainModule
        }
        
    public var mainMethod: Method?
    
    public required init(label: Label)
        {
        super.init(label: label)
        }
        
    public required init?(coder: NSCoder)
        {
        self.mainMethod = coder.decodeObject(forKey: "mainMethod") as? Method
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.mainMethod,forKey: "mainMethod")
        super.encode(with: coder)
        }
        
    public override func addSymbol(_ symbol: Symbol)
        {
        if symbol is Method && (symbol as! Method).isMainMethod
            {
            self.mainMethod = symbol as? Method
            }
        super.addSymbol(symbol)
        }
        
    public override class func classForKeyedUnarchiver() -> AnyClass
        {
        return(ImportedMainModule.self)
        }
    }

public class ImportedMainModule: MainModule
    {
    }
