//
//  Accumulator.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 26/3/22.
//

import Foundation

public class Accumulator: ValueModel,Dependent
    {
    public var value: Any?
        {
        get
            {
            self.total()
            }
        set
            {
            }
        }

    public let dependents = DependentSet()
    public let dependentKey = DependentSet.nextDependentKey
    private var models = Array<(Model,(Any) -> Int)>()
    private var modelsByKey: Dictionary<Int,Int> = [:]
    
    public func addModel<R,P>(_ model: Model,keyPath: KeyPath<R,P>,atKey: Int? = nil)
        {
        let reader =
            {
            (object: Any) -> Int in
            let root = object as! R
            return(root[keyPath: keyPath] as! Int)
            }
        self.models.append((model,reader))
        model.addDependent(self)
        self.changed(aspect: "value",with: self.total(),from: self)
        if atKey.isNotNil
            {
            self.modelsByKey[atKey!] = model.dependentKey
            }
        }
        
    public func addModel(_ model: ValueModel,atKey: Int? = nil)
        {
        let reader =
            {
            (object: Any) -> Int in
            return((object as! ValueModel).value as! Int)
            }
        self.models.append((model,reader))
        model.addDependent(self)
        self.changed(aspect: "value",with: self.total(),from: self)
        if atKey.isNotNil
            {
            self.modelsByKey[atKey!] = model.dependentKey
            }
        }
        
    public func removeModel(atKey: Int)
        {
        if let key = self.modelsByKey[atKey]
            {
            var index = 0
            for (model,_) in self.models
                {
                if model.dependentKey == key
                    {
                    self.models.remove(at: index)
                    self.changed(aspect: "value",with: self.total(),from: self)
                    return
                    }
                index += 1
                }
            }
        fatalError("Model with key \(atKey) not found.")
        }
        
    public func removeModel(_ inModel: Model)
        {
        var index = 0
        for (loopModel,_) in self.models
            {
            if loopModel.dependentKey == inModel.dependentKey
                {
                self.models.remove(at: index)
                self.changed(aspect: "value",with: self.total(),from: self)
                return
                }
            index += 1
            }
        }
        
    private func total() -> Int
        {
        var total = 0
        for (aModel,reader) in self.models
            {
            total += reader(aModel)
            }
        return(total)
        }
        
    public func update(aspect: String,with argument: Any?,from aModel: Model)
        {
        if aspect == "value"
            {
            self.changed(aspect: "value",with: self.total(),from: self)
            }
        }
    }
