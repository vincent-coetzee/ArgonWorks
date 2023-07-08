//
//  RootClass.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 15/10/21.
//

import Foundation
//
//public class RootClass: SystemClass
//    {
//    public override var type: Type?
//        {
//        get
//            {
//            return(super.type)
//            }
//        set
//            {
//            print("halt")
//            if self.type.isNotNil
//                {
//                print("EXISTING HASH \(self.type!.argonHash)")
//                }
//            super.type = newValue
//            print("NEW HASH \(self.type!.argonHash)")
//            }
//        }
//        
//    public init()
//        {
//        super.init(label: "Object")
//        }
//        
//    public required init(label: Label)
//        {
//        fatalError("FORBIDDEN")
//        }
//    
//    public required init?(coder: NSCoder)
//        {
//        super.init(coder: coder)
//        }
//        
//    public override var depth: Int
//        {
//        return(1)
//        }
//        
//    public override var isRootClass: Bool
//        {
//        return(true)
//        }
//        
////    public override class func classForKeyedUnarchiver() -> AnyClass
////        {
////        return(ImportedRootClass.self)
////        }
//    }
//
//public class ImportedRootClass: RootClass
//    {
//    public override var isImported: Bool
//        {
//        return(true)
//        }
//        
//    public var importSymbol: Importer?
//    }
//
//public class RootMetaclass: Metaclass
//    {
//    public override var metaclass: Class
//        {
//        self
//        }
//        
//    init(label: Label,class: Class)
//        {
//        super.init(label: label,class: `class`)
//        self.type = TypeClass(systemClass: self,generics: [])
//        }
//        
//    required init?(coder: NSCoder)
//        {
//        super.init(coder: coder)
//        }
//        
//    required init(label: Label)
//        {
//        super.init(label: label)
//        }
//    }
