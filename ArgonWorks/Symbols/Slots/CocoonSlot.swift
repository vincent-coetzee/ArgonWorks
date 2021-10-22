//
//  CocoonSlot.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 5/10/21.
//

import Foundation

public class CocoonSlot: VirtualSlot
    {
    private let rawLabel: Label
    
    init(rawLabel: Label,label:Label,type:Type)
        {
        self.rawLabel = rawLabel
        super.init(label: label,type: type)
        }
    
    required init?(coder: NSCoder)
        {
        self.rawLabel = coder.decodeString(forKey: "rawLabel")!
        super.init(coder: coder)
        }
    
    required init(labeled: Label, ofType: Type)
        {
        fatalError()
//        super.init(labeled: labeled,ofType: ofType)
        }
    
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.rawLabel,forKey: "rawLabel")
        super.encode(with: coder)
        }
    }
