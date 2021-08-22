//
//  InnerFunctionPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerFunctionPointer:InnerPointer
    {
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kFunctionSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_InvokableHeader","_InvokableMagicNumber","_InvokableClassPointer","_BehaviorHeader","_BehaviorMagicNumber","_BehaviorClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","code","libraryHandle","libraryPath","librarySymbol","localSlots","name","parameters","resultType"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
