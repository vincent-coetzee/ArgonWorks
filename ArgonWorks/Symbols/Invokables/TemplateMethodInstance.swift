//
//  TemplateMethodInstance.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/2/22.
//

import Foundation

public class TemplateMethodInstance: MethodInstance
    {
    }

public class InfixInlineMethodInstance: InlineMethodInstance
    {
    public func initClosure()
        {
        switch(self.label)
            {
            case("+="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.ADD,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            case("*="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.MUL,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            case("-="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.SUB,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            case("/="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.DIV,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            case("&="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.LAND,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            case("|="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.LOR,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            case("^="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.LXOR,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            case("~="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.LNOT,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            case("<<="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.LSH,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            case(">>="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.LSH,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
           case("%="):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    try! arguments[1].value.emitValueCode(into: buffer,using: generator)
                    buffer.add(.LSH,arguments[0].value.place,arguments[1].value.place,arguments[0].value.place)
                    }
            default:
                fatalError("Invalid operation")
            }
        }
    }

public class PostfixInlineMethodInstance: InlineMethodInstance
    {
    public func initClosure()
        {
        switch(self.label)
            {
            case("++"):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    buffer.add(.INCW,arguments[0].value.place)
                    }
            case("--"):
                self.closure =
                    {
                    (arguments,generator,buffer) -> Void in
                    try! arguments[0].value.emitPointerCode(into: buffer,using: generator)
                    buffer.add(.DECW,arguments[0].value.place)
                    }
            default:
                fatalError("Invalid operation")
            }
        }
    }
