//
//  SystemClassPlaceholder.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/10/21.
//

import Foundation

public class SystemSymbolPlaceholder: NSObject, NSCoding
    {
    private let originalName: Name
    
    init(original: Symbol)
        {
        self.originalName = original.fullName
        }
        
    public required init(coder: NSCoder)
        {
        self.originalName = Name(coder: coder,forKey: "originalName")
        }
        
    public func encode(with coder:NSCoder)
        {
        self.originalName.encode(with: coder,forKey:"originalName")
//        coder.encodeName(self.originalName,forKey: "originalName")
        }
        
    public override func awakeAfter(using coder: NSCoder) -> Any?
        {
        if let importer = coder as? ImportUnarchiver
            {
            if let object = TopModule.shared.lookup(name: self.originalName)
                {
                return(object)
                }
            fatalError("Can not resolve system symbol \(self.originalName.displayString) in topModule.")
            }
        return(self)
        }
    }
