//
//  SystemMethod.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 18/7/21.
//

import Foundation

public class SystemMethod:Method
    {
    public override var isSystemMethod: Bool
        {
        return(true)
        }
    }

public class IntrinsicMethod: SystemMethod
    {
    }

public class LibraryMethod: SystemMethod
    {
    }
