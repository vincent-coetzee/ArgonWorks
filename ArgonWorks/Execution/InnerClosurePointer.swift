//
//  InnerClosurePointer.swift
//  InnerClosurePointer
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class InnerClosurePointer:InnerPointer
    {
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kClosureSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_FunctionHeader","_FunctionMagicNumber","_FunctionClassPointer","_InvokableHeader","_InvokableMagicNumber","_InvokableClassPointer","_BehaviorHeader","_BehaviorMagicNumber","_BehaviorClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","codeSegment","contextPointer","initialIP","instructions","localCount","localSlots","parameters","returnType"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
