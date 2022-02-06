//
//  ValuePromise.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/2/22.
//

import Foundation

public class AddressPromise
    {
    public var address: Address
        {
        if self._address.isNil
            {
            fatalError()
            }
        return(self._address!)
        }
        
    private var _address: Address?
    
    public func setAddress(_ address: Address)
        {
        self._address = address
        }
    }
