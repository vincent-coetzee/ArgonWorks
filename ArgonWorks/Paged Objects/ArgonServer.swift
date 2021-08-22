//
//  Xenon.swift
//  Xenon
//
//  Created by Vincent Coetzee on 15/8/21.
//

import Foundation

public class ArgonServer
    {
    private let pageServer: PageServer
    
    init()
        {
        self.pageServer = PageServer.openStore()
        }
        
    public func pointer(toHandle: ObjectHandle) -> Word?
        {
        return(self.pageServer.loadPage(index: toHandle.pageIndex) + toHandle.offset)
        }
        
    public func persistObject(address: Word) -> ObjectHandle
        {
        return(ObjectHandle(page: 0, offset: 0))
        }

    }

extension Optional where Wrapped == UInt64
    {
    public static func +(lhs:Optional,rhs:UInt64) -> UInt64?
        {
        switch(lhs)
            {
            case .none:
                return(nil)
            case .some(let word):
                return(rhs + word)
            }
        }
    }
