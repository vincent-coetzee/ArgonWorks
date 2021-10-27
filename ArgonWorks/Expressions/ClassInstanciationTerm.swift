//
//  MakeTerm.swift
//  MakeTerm
//
//  Created by Vincent Coetzee on 18/8/21.
//

import Foundation

public class ClassInstanciationTerm: Expression
    {
    private let _class: Class
    private let arguments: Arguments
    
    required init?(coder: NSCoder)
        {
        self._class = coder.decodeObject(forKey: "_class") as! Class
        self.arguments = coder.decodeArguments(forKey: "arguments")
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        super.encode(with: coder)
        coder.encode(self._class,forKey: "_class")
        coder.encode(self.arguments,forKey: "arguments")
        }
        
    public init(type: Class,arguments: Arguments)
        {
        self._class = type
        self.arguments = arguments
        super.init()
        for argument in arguments
            {
            argument.value.setParent(self)
            }
        }
        
    public override var displayString: String
        {
        let string = "[" + self.arguments.displayString + "]"
        return("MAKE(\(self.type.displayString),\(string))")
        }
        
    public override var type: Type
        {
        return(.class(self._class))
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        if self.type.isGenericClass
            {
            analyzer.cancelCompletion()
            analyzer.dispatchError(at: self.declaration!, message: "The class of this MAKE term is an uninstanciated class and can not be used until it is instanciated.")
            }
        }
        
    public override func realize(using realizer:Realizer)
        {
        self.type.realize(using: realizer)
        for argument in self.arguments
            {
            argument.value.realize(using: realizer)
            }
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.type.lookup(label: label))
        }
        
    public override func emitCode(into instance: T3ABuffer,using generator: CodeGenerator) throws
        {
        guard let location = self.declaration else
            {
            print("WARNING: CAN NOT FIND LOCATION FOR \(self)")
            return
            }
        var count:Argon.Integer = 1
        instance.append(lineNumber: location.line)
        for argument in self.arguments.reversed()
            {
            try argument.value.emitCode(into: instance,using: generator)
            instance.append(nil,"PUSH",argument.value.place,.none,.none)
            count += 1
            }
        instance.append(nil,"PUSH",.relocatable(.class(self._class)),.none,.none)
        instance.append(nil,"CALL",.relocatable(.function(Function(label: "MAKE"))),.none,.none)
        instance.append("ADD",.stackPointer,.literal(.integer(count * 8)),.stackPointer)
        if !self._class.initializers.isEmpty
            {
            let temp = instance.nextTemporary()
            instance.append("MOV",.returnRegister,.none,temp)
            instance.append("PUSH",.returnRegister,.none,.none)
            let initializer = self._class.initializers.first!
            instance.append("CALL",.relocatable(.function(initializer)),.none,.none)
            instance.append("ADD",.stackPointer,.literal(.integer(8)),.stackPointer)
            self._place = temp
            }
        else
            {
            self._place = .returnRegister
            }
        }
    }
