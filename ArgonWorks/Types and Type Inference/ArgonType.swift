//
//  ArgonType.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 4/1/22.
//

import Foundation

public protocol ArgonType
    {
    var label: Label { get }
    var isClass: Bool { get }
    var isEnumeration: Bool { get }
    var isTypeVariable: Bool { get }
    var isMetaclass: Bool { get }
    var isConstructor: Bool { get }
    var type: ArgonType { get }
    }
