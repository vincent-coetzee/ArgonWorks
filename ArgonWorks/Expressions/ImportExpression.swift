//
//  ImportExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportExpression: Expression
    {
    private let importSymbol: Import
    
    init(import: Import)
        {
        self.importSymbol = `import`
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
        self.importSymbol = coder.decodeObject(forKey: "import") as! Import
        super.init(coder: coder)
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.importSymbol,forKey: "import")
        super.encode(with: coder)
        }
    
    public override func scopedExpression(for identifier: String) -> Expression?
        {
        if let value = self.importSymbol.lookup(label: identifier)
            {
            return(value.asLiteralExpression)
            }
        return(nil)
        }
    }
