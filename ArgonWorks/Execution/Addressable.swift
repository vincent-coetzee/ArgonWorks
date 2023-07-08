//
//  Addressable.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 15/12/21.
//

import Foundation

public protocol Addressable
    {
    var dirtyAddress: Address { get }
    var cleanAddress: Address { get }
    init?(dirtyAddress: Address)
    }

public typealias Addressables = Array<Addressable>
