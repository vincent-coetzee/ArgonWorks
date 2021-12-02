//
//  ImportExpression.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 12/10/21.
//

import Foundation

public class ImportExpression: Expression
    {
    private let importSymbol: Importer
    
    init(import: Importer)
        {
        self.importSymbol = `import`
        super.init()
        }
        
    public required init?(coder: NSCoder)
        {
//        print("START DECODE IMPORT")
        self.importSymbol = coder.decodeObject(forKey: "import") as! Importer
        super.init(coder: coder)
//        print("END DECODE IMPORT")
        }
        
    public override func encode(with coder: NSCoder)
        {
        coder.encode(self.importSymbol,forKey: "import")
        super.encode(with: coder)
        }
    
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.importSymbol.lookup(label: label))
        }
    }
