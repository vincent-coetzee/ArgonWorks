//
//  SystemClassSurrogate.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 29/9/21.
//

import Foundation

public class SystemClassSurrogate: NSObject,NSCoding
    {
    public let systemClassIndex: UUID
    
    init(systemClassIndex: UUID)
        {
        self.systemClassIndex = systemClassIndex
        }
        
    public required init?(coder: NSCoder)
        {
        self.systemClassIndex = coder.decodeObject(forKey: "systemClassIndex") as! UUID
        super.init()
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(systemClassIndex,forKey: "systemClassIndex")
        }
        
    public override func awakeAfter(using coder:NSCoder) -> Any?
        {
        fatalError()
        }
    }
