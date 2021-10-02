//
//  NSCoder+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

extension NSCoder
    {
    public func encodeOperand(_ operand:Instruction.Operand,forKey: String)
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
        
    public func encodeArgument(_ argument: Argument,forKey: String)
        {
        self.encode(argument.tag,forKey: forKey + "tag")
        self.encode(argument.value,forKey: forKey + "value")
        }
        
    public func encodeArguments(_ arguments: Arguments,forKey: String)
        {
        self.encode(arguments.count,forKey: forKey + "count")
        var index = 0
        for argument in arguments
            {
            self.encodeArgument(argument,forKey: forKey + "argument\(index)")
            index += 1
            }
        }
        
    public func encodePrivacyScope(_ privacyScope: PrivacyScope?,forKey: String)
        {
        if privacyScope.isNil
            {
            self.encode("nil",forKey: forKey + "flag")
            }
        else
            {
            self.encode("notNil",forKey: forKey + "flag")
            self.encode(privacyScope!.rawValue,forKey: forKey + "rawValue")
            }
        }
        
    public func encodeNodeLocation(_ location: NodeLocation,forKey: String)
        {
        switch(location)
            {
            case .declaration(let aLocation):
                self.encode(1,forKey: forKey + "kind")
                self.encodeLocation(aLocation,forKey: forKey)
            case .reference(let aLocation):
                self.encode(2,forKey: forKey + "kind")
                self.encodeLocation(aLocation,forKey: forKey)
            }
        }
        
    public func encodeSourceLocation(_ location: SourceLocation,forKey: String)
        {
        switch(location)
            {
            case .declaration(let aLocation):
                self.encode(1,forKey: forKey + "kind")
                self.encodeLocation(aLocation,forKey: forKey)
            case .reference(let aLocation):
                self.encode(2,forKey: forKey + "kind")
                self.encodeLocation(aLocation,forKey: forKey)
            }
        }
        
    public func encodeLocation(_ location:Location,forKey: String)
        {
        self.encode(location.line,forKey: forKey + "line")
        self.encode(location.lineStart,forKey: forKey + "lineStart")
        self.encode(location.lineStop,forKey: forKey + "lineStop")
        self.encode(location.tokenStart,forKey: forKey + "tokenStart")
        self.encode(location.tokenStop,forKey: forKey + "tokenStop")
        }
        
    public func decodeLocation(forKey: String) -> Location
        {
        let line = self.decodeInteger(forKey: forKey + "line")
        let lineStart = self.decodeInteger(forKey: forKey + "lineStart")
        let lineStop = self.decodeInteger(forKey: forKey + "lineStop")
        let tokenStart = self.decodeInteger(forKey: forKey + "tokenStart")
        let tokenStop = self.decodeInteger(forKey: forKey + "tokenStop")
        return(Location(line: line, lineStart: lineStart, lineStop: lineStop, tokenStart: tokenStart, tokenStop: tokenStop))
        }
        

    public func encodeNodeLocations(_ locations: NodeLocations,forKey: String)
        {
        self.encode(locations.count,forKey: forKey + "count")
        var index = 0
        for location in locations
            {
            self.encodeNodeLocation(location,forKey: forKey + "location\(index)")
            index += 1
            }
        }
        
    public func encodeSourceLocations(_ locations: SourceLocations,forKey: String)
        {
        self.encode(locations.count,forKey: forKey + "count")
        var index = 0
        for location in locations
            {
            self.encodeSourceLocation(location,forKey: forKey + "location\(index)")
            index += 1
            }
        }
        
    public func encodeLocations(_ locations: Locations,forKey: String)
        {
        self.encode(locations.count,forKey: forKey + "count")
        var index = 0
        for location in locations
            {
            self.encodeLocation(location,forKey: forKey + "location\(index)")
            index += 1
            }
        }
        
    public func encodeTokenSymbol(_ symbol: Token.Symbol,forKey: String)
        {
        self.encode(symbol.rawValue,forKey: forKey)
        }
        
    public func decodeType(forKey: String) -> Type?
        {
        print("DECODING TYPE")
        let flag = self.decodeInteger(forKey: forKey + "flag")
        if flag == -1
            {
            return(nil)
            }
        let kind = self.decodeInteger(forKey: forKey + "kind")
        switch(kind)
            {
            case(1):
                 return(Type.class(self.decodeObject(forKey: forKey + "class") as! Class))
            case(2):
                return(Type.enumeration(self.decodeObject(forKey: forKey + "enumeration") as! Enumeration))
            case(3):
                return(Type.method(self.decodeString(forKey:forKey + "name")!,self.decodeTypes(forKey: forKey + "types"),self.decodeType(forKey: forKey + "returnType")!))
            default:
                fatalError("Invalid type kind - error in archive")
            }
        }
        
    public func decodeTypes(forKey: String) -> Types
        {
        let count = self.decodeInteger(forKey: forKey + "count")
        var types = Types()
        for index in 0..<count
            {
            types.append(self.decodeType(forKey: forKey + "type\(index)")!)
            }
        return(types)
        }
        
    public func encodeTypes(_ types: Types,forKey: String)
        {
        self.encode(types.count,forKey: forKey + "count")
        var index = 0
        for type in types
            {
            self.encodeType(type,forKey: forKey + "type\(index)")
            index += 1
            }
        }
        
    public func encodeType(_ type: Type?,forKey: String)
        {
        if type.isNil
            {
            self.encode(-1,forKey:forKey + "flag")
            return
            }
        else
            {
            self.encode(1,forKey: forKey + "flag")
            switch(type)
                {
                case .method(let name,let types,let returnType):
                    self.encode(3,forKey: forKey + "kind")
                    self.encode(name,forKey: forKey + "name")
                    self.encodeTypes(types,forKey: forKey + "types")
                    self.encodeType(returnType,forKey: forKey + "returnType")
                case .class(let aClass):
                    self.encode(1,forKey: forKey + "kind")
                    self.encode(aClass,forKey: forKey + "class")
                case .enumeration(let aClass):
                    self.encode(2,forKey: forKey + "kind")
                    self.encode(aClass,forKey: forKey + "enumeration")
                case .forwardReference(let name,let context):
                    if let value = context.lookup(name: name)
                        {
                        if value is Class
                            {
                            self.encode(1,forKey: forKey + "kind")
                            self.encode(value as! Class,forKey: forKey + "class")
                            }
                        else if value is Enumeration
                            {
                            self.encode(2,forKey: forKey + "kind")
                            self.encode(value as! Enumeration,forKey: forKey + "enumeration")
                            }
                        else
                            {
                            fatalError("FIX ME")
                            }
                        }
                    else
                        {
                        fatalError("Using a forward reference here is a fuckup and needs to be fixed")
                        }
                default:
                    fatalError("Should not happen")
                }
            }
        }
        
    public func encodeDynamicLibrary(_ library: DynamicLibrary,forKey: String)
        {
        self.encode(library.path,forKey: forKey + "path")
        }
        
    public func decodeString(forKey: String) -> String?
        {
        let string = self.decodeObject(forKey: forKey)
        return(string as? String)
        }
        
    public func encodeParent(_ parent: Parent,forKey key: String)
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

    public func decodeNodeLocations(forKey: String) -> NodeLocations
        {
        let count = self.decodeInteger(forKey: forKey + "count")
        var locations = NodeLocations()
        for index in 0..<count
            {
            locations.append(self.decodeNodeLocation(forKey: forKey + "location\(index)"))
            }
        return(locations)
        }
        
    public func decodeLocations(forKey: String) -> Locations
        {
        let count = self.decodeInteger(forKey: forKey + "count")
        var locations = Locations()
        for index in 0..<count
            {
            locations.append(self.decodeLocation(forKey: forKey + "location\(index)"))
            }
        return(locations)
        }
        
    public func decodeSourceLocations(forKey: String) -> SourceLocations
        {
        let count = self.decodeInteger(forKey: forKey + "count")
        var locations = SourceLocations()
        for index in 0..<count
            {
            locations.append(self.decodeSourceLocation(forKey: forKey + "location\(index)"))
            }
        return(locations)
        }
        
    public func decodeDynamicLibrary(forKey: String) -> DynamicLibrary
        {
        let path = self.decodeString(forKey: forKey + "path")!
        return(DynamicLibrary(openPathOnDemand: path))
        }
        

    public func decodeArgument(forKey: String) -> Argument
        {
        let tag = self.decodeString(forKey: forKey + "tag")
        let value = self.decodeObject(forKey: forKey + "value") as! Expression
        return(Argument(tag: tag, value: value))
        }
        
    public func decodeArguments(forKey: String) -> Arguments
        {
        let count = self.decodeInteger(forKey: forKey + "count")
        var arguments = Arguments()
        for index in 0..<count
            {
            arguments.append(self.decodeArgument(forKey: forKey + "argument\(index)"))
            }
        return(arguments)
        }
        
    public func decodeNodeLocation(forKey: String) -> NodeLocation
        {
        let kind = self.decodeInteger(forKey: forKey + "kind")
        if kind == 1
            {
            let location = self.decodeLocation(forKey: forKey)
            return(.declaration(location))
            }
        else
            {
            let location = self.decodeLocation(forKey: forKey)
            return(.reference(location))
            }
        }
        
    public func decodeSourceLocation(forKey: String) -> SourceLocation
        {
        let kind = self.decodeInteger(forKey: forKey + "kind")
        if kind == 1
            {
            let location = self.decodeLocation(forKey: forKey)
            return(.declaration(location))
            }
        else
            {
            let location = self.decodeLocation(forKey: forKey)
            return(.reference(location))
            }
        }
        
    public func decodePrivacyScope(forKey: String) -> PrivacyScope?
        {
        let flag = self.decodeString(forKey: forKey + "flag")!
        if flag == "nil"
            {
            return(nil)
            }
        let string = self.decodeObject(forKey: forKey + "rawValue") as! String
        return(PrivacyScope(rawValue: string)!)
        }
        
    public func decodeParent(forKey key: String) -> Parent?
        {
        print("DECODE PARENT")
        let type = self.decodeInteger(forKey: key + "type")
        print("DECODED KEY Parent.type")
        switch(type)
            {
            case 0:
                return(Parent.none)
            case 1:
                print("ABOUT TO DECODE PARENT KEY Parent.\(key)node")
                return(Parent.node(self.decodeObject(forKey: key + "node") as! Node))
            case 2:
                print("ABOUT TO DECODE PARENT KEY Parent.\(key)block")
                return(Parent.block(self.decodeObject(forKey: key + "block") as! Block))
            case 3:
                print("ABOUT TO DECODE PARENT KEY Parent.\(key)expression")
                return(Parent.expression(self.decodeObject(forKey: key + "expression") as! Expression))
            default:
                return(nil)
            }
        }
        
    public func decodeOperand(forKey: String) -> Instruction.Operand?
        {
        print("DECODE OPERAND")
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
        
    public func decodeTokenSymbol(forKey: String) -> Token.Symbol
        {
        return(Token.Symbol(rawValue: self.decodeString(forKey: forKey)!)!)
        }
    }
