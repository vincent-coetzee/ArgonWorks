//
//  ImportUnarchiver.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ArgonUnarchiver: NSKeyedUnarchiver
    {
    }
    
public class ImportUnarchiver: ArgonUnarchiver
    {
    public static var importSymbol: Import?
    
    public static func unarchiveTopLevelObjectWithData(_ data: Data,import: Import) throws -> Any?
        {
        self.importSymbol = `import`
        return(try self.unarchiveTopLevelObjectWithData(data))
        }
    }
