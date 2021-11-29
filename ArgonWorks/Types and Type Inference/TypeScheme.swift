//
//  TypeScheme.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/11/21.
//

import Foundation

public class TypeScheme: Type
    {
    private enum Kind
        {
        case monomorphic(Type)
        case forAll(Type)
        }
        
    private let kind:Kind
    
    public init(type: Type)
        {
        self.kind = .monomorphic(type)
        super.init()
        }
        
    public init(forAll: Type)
        {
        self.kind = .forAll(forAll)
        super.init()
        }
        
    required init?(coder: NSCoder)
        {
        fatalError()
        }
        
    required init(label: Label)
        {
        self.kind = .monomorphic(Type())
        super.init(label: label)
        }
        
    public override func encode(with coder: NSCoder)
        {
        fatalError()
        }
    }
