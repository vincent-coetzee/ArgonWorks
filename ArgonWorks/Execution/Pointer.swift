//
//  Pointer.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 19/12/21.
//

import Foundation

public protocol Pointer
    {
    var dirtyAddress: Address { get }
    var cleanAddress: Address { get }
    init?(dirtyAddress: Address,argonModule: ArgonModule)
    }
