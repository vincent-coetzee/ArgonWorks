//
//  NSCoder+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 21/9/21.
//

import Foundation

extension NSCoder
    {
    public func encodeOperand(_ operand: T3AInstruction.Operand,forKey: String)
        {
        switch(operand)
            {
        case .none:
            self.encode(1,forKey: forKey + "kind")
        case .returnRegister:
            self.encode(2,forKey: forKey + "kind")
        case .temporary(let integer):
            self.encode(3,forKey: forKey + "kind")
            self.encode(integer,forKey: forKey + "temporary")
        case .label(let label):
            self.encode(4,forKey: forKey + "kind")
            self.encode(label,forKey: forKey + "label")
        case .relocatable(let relocatable):
            self.encode(5,forKey: forKey + "kind")
            self.encodeRelocatableValue(relocatable,forKey: forKey + "relocatable")
        case .literal(let literal):
            self.encode(6,forKey: forKey + "kind")
            self.encodeLiteral(literal,forKey: forKey + "literal")
        case .framePointer:
            self.encode(7,forKey: forKey + "kind")
        case .stackPointer:
            self.encode(8,forKey: forKey + "kind")
        case .indirect(let base,let offset):
            self.encode(9,forKey: forKey + "kind")
            self.encodeOperand(base,forKey: forKey + "base")
            self.encode(offset,forKey: forKey + "offset")
        case .dataPointer:
            self.encode(10,forKey: forKey + "kind")
        case .staticPointer:
            self.encode(11,forKey: forKey + "kind")
        case .managedPointer:
            self.encode(12,forKey: forKey + "kind")
            }
        }
        
    public func decodeOperand(forKey: String) -> T3AInstruction.Operand
        {
        let kind = self.decodeInteger(forKey: forKey + "kind")
        switch(kind)
            {
            case 1:
                return(.none)
            case 2:
                return(.returnRegister)
            case 3:
                return(.temporary(self.decodeInteger(forKey: forKey + "temporary")))
            case 4:
                return(.label(self.decodeObject(forKey: forKey + "label") as! T3ALabel))
            case 5:
                return(.relocatable(self.decodeRelocatableValue(forKey: forKey + "relocatable")))
            case 6:
                return(.literal(self.decodeLiteral(forKey: forKey + "literal")))
            case 7:
                return(.framePointer)
            case 8:
                return(.stackPointer)
            case 9:
                return(.indirect(self.decodeOperand(forKey: forKey + "base"),self.decodeInteger(forKey: "offset")))
            case 10:
                return(.dataPointer)
            case 11:
                return(.staticPointer)
            case 12:
                return(.managedPointer)
            default:
                fatalError("This should not happen")
            }
        }

    public func encodeRelocatableValue(_ relocatableValue: T3AInstruction.RelocatableValue,forKey key: String)
        {
        switch(relocatableValue)
            {
            case .function(let string):
                self.encode(1,forKey: key + "kind")
                self.encode(string,forKey: key + "function")
            case .class(let string):
                self.encode(2,forKey: key + "kind")
                self.encode(string,forKey: key + "class")
            case .module(let string):
                self.encode(3,forKey: key + "kind")
                self.encode(string,forKey: key + "module")
            case .enumeration(let string):
                self.encode(4,forKey: key + "kind")
                self.encode(string,forKey: key + "enumeration")
//            case .method(let string):
//                self.encode(5,forKey: key + "kind")
//                self.encode(string,forKey: key + "method")
            case .enumerationCase(let string):
                self.encode(6,forKey: key + "kind")
                self.encode(string,forKey: key + "enumerationCase")
            case .constant(let string):
                self.encode(7,forKey: key + "kind")
                self.encode(string,forKey: key + "constant")
            case .self:
                self.encode(8,forKey: key + "kind")
            case .Self:
                self.encode(9,forKey: key + "kind")
            case .super:
                self.encode(10,forKey: key + "kind")
            case .segmentDS:
                self.encode(11,forKey: key + "kind")
            case .slot(let slot):
                self.encode(12,forKey: key + "kind")
                self.encode(slot,forKey: key + "slot")
            case .relocatableIndex(let index):
                self.encode(13,forKey: key + "kind")
                self.encode(index,forKey: key + "index")
            case .methodInstance(let instance):
                self.encode(14,forKey: key + "kind")
                self.encode(instance,forKey: key + "methodInstance")
            case .type(let type):
                self.encode(15,forKey: key + "kind")
                self.encode(type,forKey: key + "type")
            case .closure(let buffer):
                self.encode(16,forKey: key + "kind")
                self.encode(buffer,forKey: key + "buffer")
            case .context(let instance,let ip):
                self.encode(17,forKey: key + "kind")
                self.encode(instance,forKey: key + "instance")
                self.encode(ip,forKey: key + "ip")
            case .string(let string):
                self.encode(18,forKey: key + "kind")
                self.encode(string,forKey: key + "string")
            case .address(let address):
                self.encode(19,forKey: key + "kind")
                self.encode(Int(address),forKey: key + "address")
            }
        }
        
    public func decodeRelocatableValue(forKey key: String) -> T3AInstruction.RelocatableValue
        {
        let kind = self.decodeInteger(forKey: key + "kind")
        switch(kind)
            {
            case 1:
                return(.function(self.decodeObject(forKey: key + "function") as! Function))
            case 2:
                return(.class(self.decodeObject(forKey: key + "class") as! Class))
            case 3:
                return(.module(self.decodeObject(forKey: key + "module") as! Module))
            case 4:
                return(.enumeration(self.decodeObject(forKey: key + "enumeration") as! Enumeration))
//            case 5:
//                return(.method(self.decodeObject(forKey: key + "method") as! Method))
            case 6:
                return(.enumerationCase(self.decodeObject(forKey: key + "enumerationCase") as! EnumerationCase))
            case 7:
                return(.constant(self.decodeObject(forKey: key + "constant") as! Constant))
            case 8:
                return(.self)
            case 9:
                return(.Self)
            case 10:
                return(.super)
            case 11:
                return(.segmentDS)
            case 12:
                return(.slot(self.decodeObject(forKey: key + "slot") as! Slot))
            case 13:
                return(.relocatableIndex(self.decodeInteger(forKey: key + "index")))
            case 14:
                return(.methodInstance(self.decodeObject(forKey: key + "methodInstance") as! MethodInstance))
            case 15:
                return(.type(self.decodeObject(forKey: key + "type") as! Type))
            case 16:
                return(.closure(self.decodeObject(forKey: key + "buffer") as! T3ABuffer))
            case 17:
                return(.context(self.decodeObject(forKey: key + "instance") as! MethodInstance,self.decodeInteger(forKey: key + "ip")))
            case 18:
                return(.string(self.decodeObject(forKey: key + "string") as! StaticString))
            case 19:
                return(.address(Address(self.decodeInteger(forKey: key + "address"))))
            default:
                fatalError("This should not happen")
            }
        }
        
    public func encodeLiteral(_ literal: Literal,forKey: String)
        {
        switch(literal)
            {
            case .nil:
                self.encode(1,forKey:forKey + "kind")
            case .integer(let integer):
                self.encode(2,forKey:forKey + "kind")
                self.encode(integer,forKey:forKey + "integer")
            case .float(let float):
                self.encode(3,forKey:forKey + "kind")
                self.encode(float,forKey:forKey + "float")
            case .string(let string):
                self.encode(4,forKey:forKey + "kind")
                self.encode(string,forKey:forKey + "string")
            case .boolean(let boolean):
                self.encode(5,forKey:forKey + "kind")
                self.encode(boolean,forKey:forKey + "boolean")
            case .symbol(let symbol):
                self.encode(6,forKey:forKey + "kind")
                self.encode(symbol,forKey:forKey + "symbol")
            case .array(let array):
                self.encode(7,forKey:forKey + "kind")
                self.encode(array,forKey: "array")
            case .class(let aClass):
                self.encode(8,forKey:forKey + "kind")
                self.encode(aClass,forKey:forKey + "class")
            case .module(let module):
                self.encode(9,forKey:forKey + "kind")
                self.encode(module,forKey:forKey + "module")
            case .enumeration(let enumeration):
                self.encode(10,forKey:forKey + "kind")
                self.encode(enumeration,forKey:forKey + "enumeration")
//            case .method(let method):
//                self.encode(12,forKey:forKey + "kind")
//                self.encode(method,forKey:forKey + "method")
            case .constant(let constant):
                self.encode(13,forKey:forKey + "kind")
                self.encode(constant,forKey:forKey + "constant")
            case .enumerationCase(let aCase):
                self.encode(11,forKey:forKey + "kind")
                self.encode(aCase,forKey:forKey + "enumerationCase")
            case .function(let aCase):
                self.encode(14,forKey:forKey + "kind")
                self.encode(aCase,forKey:forKey + "function")
            case .address(let address):
                self.encode(15,forKey:forKey + "kind")
                self.encode(Int(address),forKey:forKey + "address")
            }
        }
        
    public func decodeLiteral(forKey: String) -> Literal
        {
        let kind = self.decodeInteger(forKey: forKey + "kind")
        switch(kind)
            {
            case 1:
                return(.nil)
            case 2:
                return(.integer(Argon.Integer(self.decodeInteger(forKey: forKey + "integer"))))
            case 3:
                return(.float(Argon.Float(self.decodeDouble(forKey:forKey +  "float"))))
            case 4:
                return(.string(self.decodeObject(forKey: forKey + "string") as! StaticString))
            case 5:
                return(.boolean(self.decodeBool(forKey: forKey + "boolean") ? .trueValue : .falseValue))
            case 6:
                return(.symbol(self.decodeObject(forKey: forKey + "symbol") as! StaticSymbol))
            case 7:
                return(.array(self.decodeObject(forKey: "array") as! StaticArray))
            case 8:
                return(.class(self.decodeObject(forKey: forKey + "class") as! Class))
            case 9:
                return(.module(self.decodeObject(forKey: forKey + "module") as! Module))
            case 10:
                return(.enumeration(self.decodeObject(forKey: forKey + "enumeration") as! Enumeration))
            case 11:
                return(.enumerationCase(self.decodeObject(forKey: forKey + "enumerationCase") as! EnumerationCase))
//            case 12:
//                return(.method(self.decodeObject(forKey: forKey + "method") as! Method)
            case 13:
                return(.constant(self.decodeObject(forKey: forKey + "constant") as! Constant))
            case 14:
                return(.function(self.decodeObject(forKey: forKey + "function") as! Function))
            case 15:
                return(.address(Address(self.decodeInteger(forKey: forKey + "address"))))
            default:
                fatalError()
            }
        }
        
//    public func encodeT3AOperand(_ operand: T3AInstruction.Operand,forKey key: String)
//        {
//        switch(operand)
//            {
//            case .none:
//                self.encode(0,forKey: key + "kind")
//            case .temporary(let index):
//                self.encode(1,forKey: key + "kind")
//                self.encode(index,forKey: key + "index")
//            case .label(let label):
//                self.encode(3,forKey: key + "kind")
//                self.encode(label,forKey: key + "label")
//            case .literal(let literal):
//                self.encode(4,forKey: key + "kind")
//                self.encodeLiteralValue(literal,forKey: key + "literal")
//            case .returnRegister:
//                self.encode(5,forKey: key + "kind")
//            case .relocatable(let relocatable):
//                self.encode(6,forKey: key + "kind")
//                self.encodeRelocatableValue(relocatable,forKey: key + "relocatable")
//            }
//        }
//        
//    public func decodeT3AOperand(forKey key: String) -> T3AInstruction.Operand
//        {
//        let kind = self.decodeInteger(forKey: key + "kind")
//        switch(kind)
//            {
//            case 0:
//                return(.none)
//            case 1:
//                return(.temporary(self.decodeInteger(forKey: key + "index")))
//            case 3:
//                return(.label(self.decodeObject(forKey: key + "label") as! T3ALabel))
//            case 4:
//                return(.literal(self.decodeLiteralValue(forKey: key + "literal")))
//            case 5:
//                return(.returnRegister)
//            default:
//                fatalError("This should not occur")
//            }
//        }
        
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
        self.encode(location.line,forKey: forKey + "lineNumber")
        self.encode(location.lineStart,forKey: forKey + "lineStart")
        self.encode(location.lineStop,forKey: forKey + "lineStop")
        self.encode(location.tokenStart,forKey: forKey + "tokenStart")
        self.encode(location.tokenStop,forKey: forKey + "tokenStop")
        }
        
    public func decodeLocation(forKey: String) -> Location
        {
        let lineNumber = self.decodeInteger(forKey: forKey + "lineNumber")
        let lineStart = self.decodeInteger(forKey: forKey + "lineStart")
        let lineStop = self.decodeInteger(forKey: forKey + "lineStop")
        let tokenStart = self.decodeInteger(forKey: forKey + "tokenStart")
        let tokenStop = self.decodeInteger(forKey: forKey + "tokenStop")
        return(Location(line: lineNumber, lineStart: lineStart, lineStop: lineStop, tokenStart: tokenStart, tokenStop: tokenStop))
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
        
//    public func decodeType(forKey: String) -> Type?
//        {
//        let flag = self.decodeInteger(forKey: forKey + "flag")
//        if flag == -1
//            {
//            return(nil)
//            }
//        let kind = self.decodeInteger(forKey: forKey + "kind")
//        switch(kind)
//            {
//            case(1):
//                 return(Type.class(self.decodeObject(forKey: forKey + "class") as! Class))
//            case(2):
//                return(Type.enumeration(self.decodeObject(forKey: forKey + "enumeration") as! Enumeration))
//            case(5):
//                return(Type.methodInstance(self.decodeString(forKey: forKey + "name")!,self.decodeTypes(forKey: forKey + "types"),self.decodeType(forKey: forKey + "type")!))
//            case(6):
//                return(Type.unknown)
//            case(7):
//                return(Type.typeParameter(self.decodeObject(forKey:forKey + "genericClassParameter") as! TypeParameter))
//            case(8):
//                return(Type.genericClass(self.decodeObject(forKey:forKey + "genericClass") as! GenericClass))
//            case(9):
//                return(Type.genericClassInstance(self.decodeObject(forKey:forKey + "genericClassInstance") as! GenericClassInstance))
//            default:
//                fatalError("Invalid type kind - error in archive")
//            }
//        }
        
//    public func decodeTypes(forKey: String) -> Types
//        {
//        let count = self.decodeInteger(forKey: forKey + "count")
//        var types = Types()
//        for index in 0..<count
//            {
//            types.append(self.decodeType(forKey: forKey + "type\(index)")!)
//            }
//        return(types)
//        }
//        
//    public func encodeTypes(_ types: Types,forKey: String)
//        {
//        self.encode(types.count,forKey: forKey + "count")
//        var index = 0
//        for type in types
//            {
//            self.encodeType(type,forKey: forKey + "type\(index)")
//            index += 1
//            }
//        }
        
//    public func encodeType(_ type: Type?,forKey: String)
//        {
//        if type.isNil
//            {
//            self.encode(-1,forKey:forKey + "flag")
//            return
//            }
//        else
//            {
//            self.encode(1,forKey: forKey + "flag")
//            switch(type)
//                {
//                case .class(let aClass):
//                    self.encode(1,forKey: forKey + "kind")
//                    self.encode(aClass,forKey: forKey + "class")
//                case .enumeration(let aClass):
//                    self.encode(2,forKey: forKey + "kind")
//                    self.encode(aClass,forKey: forKey + "enumeration")
//                case .methodInstance(let name,let types,let type):
//                    self.encode(5,forKey: forKey + "kind")
//                    self.encode(name,forKey:forKey + "name")
//                    self.encodeTypes(types,forKey: forKey + "types")
//                    self.encodeType(type,forKey: forKey + "type")
//                case .unknown:
//                    self.encode(6,forKey: forKey + "kind")
//                case .typeParameter(let aClass):
//                    self.encode(7,forKey: forKey + "kind")
//                    self.encode(aClass,forKey: forKey + "genericClassParameter")
//                case .genericClass(let aClass):
//                    self.encode(8,forKey: forKey + "kind")
//                    self.encode(aClass,forKey: forKey + "genericClass")
//                case .genericClassInstance(let aClass):
//                    self.encode(9,forKey: forKey + "kind")
//                    self.encode(aClass,forKey: forKey + "genericClassInstance")
//                default:
//                    fatalError("Should not happen")
//                }
//            }
//        }
        
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
        let type = self.decodeInteger(forKey: key + "type")
        switch(type)
            {
            case 0:
                return(Parent.none)
            case 1:
                return(Parent.node(self.decodeObject(forKey: key + "node") as! Symbol))
            case 2:
                return(Parent.block(self.decodeObject(forKey: key + "block") as! Block))
            case 3:
                return(Parent.expression(self.decodeObject(forKey: key + "expression") as! Expression))
            default:
                return(nil)
            }
        }
        
    public func decodeTokenSymbol(forKey: String) -> Token.Symbol
        {
        return(Token.Symbol(rawValue: self.decodeString(forKey: forKey)!)!)
        }
    }
