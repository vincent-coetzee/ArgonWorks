//
//  Function.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import AppKit
import FFI
import Interpreter

public class Function:Invokable,Displayable
    {
    public var library:DynamicLibrary = .emptyLibrary
    
    public override var defaultColor: NSColor
        {
        Palette.shared.functionColor
        }
        
    public override var displayString: String
        {
        let parms = "(" + self.parameters.map{$0.displayString}.joined(separator: ",") + ")"
        return(self.label + parms + " -> " + self.returnType.displayString)
        }
        
    public override var imageName: String
        {
        "IconFunction"
        }
        
    public override init(label: Label)
        {
        super.init(label: label)
        }
        
    public required init?(coder: NSCoder)
        {
        self.library = coder.decodeDynamicLibrary(forKey: "library")
        super.init(coder: coder)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encodeDynamicLibrary(self.library,forKey: "library")
        super.encode(with: coder)
        }
        
    public func call(withArguments: Words) -> Word?
        {
        let argTypes:UnsafeMutablePointer<ffi_type>? = UnsafeMutablePointer<ffi_type>.allocate(capacity: self.parameters.count)
        var argPointer = argTypes
        for type in self.parameters.map({$0.type.ffiType})
            {
            argPointer?.pointee = type
            argPointer = argPointer! + 1
            }
        var interface = ffi_cif()
        let output = (self.returnType.isVoidType ? UnsafeMutablePointer<ffi_type>.allocate(capacity: 1).assigned(ffi_type_void) : UnsafeMutablePointer<ffi_type>.allocate(capacity: 1).assigned(ffi_type_uint64))
        let argTypePointer:UnsafeMutablePointer<UnsafeMutablePointer<ffi_type>?> = UnsafeMutablePointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 1)
        argTypePointer.pointee = argTypes
        ffi_prep_cif(&interface,FFI_DEFAULT_ABI,UInt32(self.parameters.count),output,argTypePointer)
        let argumentPointers = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: withArguments.count)
        var index = 0
        for argument in withArguments
            {
            let pointer = UnsafeMutablePointer<Word>.allocate(capacity: 1).assigned(argument)
            argumentPointers[index] = UnsafeMutableRawPointer(pointer)
            index += 1
            }
        if let address = self.library.findSymbol(self.cName)
            {
            ffi_call(&interface,MutateSymbol(address.address!),nil,argumentPointers)
            }
        return(0)
        }
    }

extension UnsafeMutablePointer
    {
    public func assigned(_ value:Pointee) -> UnsafeMutablePointer<Pointee>
        {
        self.pointee = value
        return(self)
        }
    }
