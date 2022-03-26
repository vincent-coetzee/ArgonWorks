///
///
///
///
///

import Cocoa

public class MethodInstanceBlock: Block
    {
    public override var parentScope: Scope?
        {
        get
            {
            self.methodInstance
            }
        set
            {
            fatalError()
            }
        }
        
    private var methodInstance: MethodInstance!
    
    init(methodInstance: MethodInstance)
        {
        self.methodInstance = methodInstance
        super.init()
        }
        
        required init()
            {
            super.init()
            }
        
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    public override func freshTypeVariable(inContext context: TypeContext) -> Self
        {
        return(self)
        }
        
    public override func lookupMethod(label: Label) -> Method?
        {
        self.methodInstance.lookupMethod(label: label)
        }
        
    public override func lookupN(label: Label) -> Symbols?
        {
        var found = Symbols()
        for symbol in self.localSymbols
            {
            if symbol.localLabel == label
                {
                found.append(symbol)
                }
            }
        if let more = self.methodInstance.lookupN(label: label)
            {
            found.append(contentsOf: more)
            }
        return(found.isEmpty ? nil : found)
        }
        
//    public override func lookupN(name: Name) -> Symbols?
//        {
//        if name.isRooted
//            {
//            return(self.methodInstance.lookupN(name: name))
//            }
//        else if name.count == 1
//            {
//            var results = Symbols()
//            for symbol in self.localSymbols
//                {
//                if symbol.localLabel == name.last
//                    {
//                    results.append(symbol)
//                    }
//                }
//            if let upper = self.methodInstance.lookupN(name: name)
//                {
//                results.append(contentsOf: upper)
//                }
//            return(results.isEmpty ? nil : results)
//            }
//        else
//            {
//            return(self.methodInstance.lookupN(name: name))
//            }
//        }
        
//    public override func lookup(name: Name) -> Symbol?
//        {
//        if name.isRooted
//            {
//            if name.count == 1
//                {
//                return(nil)
//                }
//            if let start = TopModule.shared.lookup(label: name.first)
//                {
//                if name.count == 2
//                    {
//                    return(start)
//                    }
//                if let symbol = start.lookup(name: name.withoutFirst)
//                    {
//                    return(symbol)
//                    }
//                }
//            }
//        if name.isEmpty
//            {
//            return(nil)
//            }
//        else if name.count == 1
//            {
//            if let symbol = self.lookup(label: name.first)
//                {
//                return(symbol)
//                }
//            }
//        else if let start = self.lookup(label: name.first)
//            {
//            if let symbol = (start as? Scope)?.lookup(name: name.withoutFirst)
//                {
//                return(symbol)
//                }
//            }
//        return(self.methodInstance.lookup(name: name))
//        }
        
    public override func lookupType(label: Label) -> Type?
        {
        self.methodInstance.lookupType(label: label)
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        for symbol in self.localSymbols
            {
            if symbol.localLabel == label
                {
                return(symbol)
                }
            }
        return(self.methodInstance.lookup(label: label))
        }
        
    }
