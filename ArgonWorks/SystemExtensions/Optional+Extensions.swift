//
//  Optional+Extensions.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 12/7/21.
//

import Foundation

extension Optional
    {
    public var isNotNil: Bool
        {
        switch(self)
            {
            case .some:
                return(true)
            case .none:
                return(false)
            }
        }
        
    public var isNil: Bool
        {
        switch(self)
            {
            case .some:
                return(false)
            case .none:
                return(true)
            }
        }
    }

extension Optional where Wrapped:Displayable
    {
    public var displayString: String
        {
        switch(self)
            {
            case .some(let object):
                return(object.displayString)
            default:
                return("nil value")
            }
        }
    }

extension Optional where Wrapped == Word
    {
    public var objectAddress: Word
        {
        switch(self)
            {
            case .some(let word):
                return(word.objectAddress)
            default:
                return(Address(0).objectAddress)
            }
        }
        
   public var cleanAddress: Word
        {
        switch(self)
            {
            case .some(let word):
                return(word.cleanAddress)
            default:
                return(Address(0))
            }
        }
    }

extension Optional where Wrapped:Pointer
    {
    public var dirtyAddress: Word
        {
        switch(self)
            {
            case .some(let word):
                return(word.dirtyAddress)
            default:
                return(Address(0))
            }
        }
        
    public var objectAddress: Word
        {
        switch(self)
            {
            case .some(let word):
                return(word.cleanAddress.objectAddress)
            default:
                return(Address(0).objectAddress)
            }
        }
        
   public var cleanAddress: Word
        {
        switch(self)
            {
            case .some(let word):
                return(word.cleanAddress)
            default:
                return(Address(0))
            }
        }
    }
