//
//  SystemClassPlaceholder.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 18/10/21.
//

import Foundation

public class SystemSymbolPlaceholder: NSObject, NSCoding
    {
    private let originalKey: Int
    private let label: String
    
    init(original: Symbol)
        {
        self.originalKey = original.argonHash
        self.label = "\(original)"
        }
        
    public required init?(coder: NSCoder)
        {
        self.originalKey = coder.decodeInteger(forKey: "originalKey")
        self.label = coder.decodeObject(forKey: "label") as! String
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.originalKey,forKey:"originalKey")
        coder.encode(self.label,forKey: "label")
//        coder.encodeName(self.originalName,forKey: "originalName")
        }
        
    public override func awakeAfter(using coder: NSCoder) -> Any?
        {
//        if let importer = coder as? ImportUnarchiver
//            {
//            fatalError("Can not resolve system symbol \(self.originalKey) in topModule.")
//            }
        return(self)
        }
    }
