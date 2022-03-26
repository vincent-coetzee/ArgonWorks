//
//  ModuleImport.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

extension String
    {
    public var canonicalPath: String
        {
        let url = URL(fileURLWithPath: self)
        if let path = try? url.resourceValues(forKeys: [.canonicalPathKey]).canonicalPath
            {
            return(path)
            }
        return(self)
        }
    }
    
///
///
/// An Importer represents an import statement in Argon source code.
/// It is responsible for loading and managing the symbols in an object
/// file so they can be accessed later in the source after they have been
/// imported. From a naming perspective an Importer masquerades as a
/// TopModule so that when Names are used from imported symbols they
/// look as if they are rooted in a normal hierarchy rather than
/// being rooted in an Importer. The Importer does this by reporting
/// falsely what it's fullName is.
///
///
public class Importer: Symbol,Loader
    {
    public override var fullName: Name
        {
        Name(rooted: true)
        }
        
    private let path: String
    private var symbolsByLabel: Dictionary<Label,Symbol> = [:]
    private var moduleLabel: String!
    public let canonicalPath: String
    public var rootModule: Module!
    
    init(label: Label,path: String)
        {
        self.path = path
        self.canonicalPath = path.canonicalPath
        super.init(label: label)
        }
    
    public required init?(coder: NSCoder)
        {
//        print("START DECODE IMPORT")
        self.path = coder.decodeString(forKey: "path")!
        self.moduleLabel = coder.decodeString(forKey: "moduleLabel")
        self.canonicalPath = coder.decodeString(forKey: "path")!.canonicalPath
        super.init(coder: coder)
//        print("END DECODE IMPORT \(self.label)")
        }

    public required init(label: Label)
        {
        self.path = ""
        self.canonicalPath = ""
        super.init(label: label)
        }
        
    public func isPathEquivalent(to input: String) -> Bool
        {
        return(self.canonicalPath == input.canonicalPath)
        }
        
    public override func encode(with coder:NSCoder)
        {
        coder.encode(self.path,forKey: "path")
        coder.encode(self.moduleLabel,forKey: "moduleLabel")
        super.encode(with: coder)
        }
        
    public static func processPath(_ input: String) -> String
        {
        if input.isFilePath && input.hasFileExtension && input.fileExtension == "argono"
            {
            return(input)
            }
        if input.fileComponents.count == 1
            {
            let filename:NSString = (input + ".argono") as NSString
            let argonPath = (Argon.kArgonDefaultObjectFileDirectory as NSString)
            return(argonPath.appendingPathComponent(filename as String) as String)
            }
        if input.isFilePath && (!input.hasFileExtension || (input.hasFileExtension && input.fileExtension != ".argono"))
            {
            let newPath = (input as NSString).deletingPathExtension + ".argono"
            return(newPath as String)
            }
        return(input)
        }
        
    public static func tryLoadingPath(_ path: String?,topModule: TopModule,location: Location) -> String?
        {
//        guard let filePath = path else
//            {
//            return(nil)
//            }
//        let manager = FileManager.default
//        var isDirectory:ObjCBool = false
//        guard manager.fileExists(atPath: filePath,isDirectory: &isDirectory),!isDirectory.boolValue else
//            {
//            reportingContext.dispatchWarning(at: location,message: "Invalid import path.")
//            return(nil)
//            }
//        let url = URL(fileURLWithPath: filePath)
//        guard let data = try? Data(contentsOf: url) else
//            {
//            reportingContext.dispatchWarning(at: location,message: "Invalid path, file at path can not be loaded.")
//            return(nil)
//            }
//        guard let objectFile = try? ImportUnarchiver(forReadingFrom: data, topModule: topModule).decodeTopLevelObject() as? ObjectFile else
//            {
//            reportingContext.dispatchWarning(at: location,message: "Invalid path, file at path can not be loaded as an Argon object file.")
//            return(nil)
//            }
//        guard objectFile.module.symbolsByLabel.count > 0 else
//            {
//            reportingContext.dispatchWarning(at: location,message: "Invalid object file at path, object file is empty.")
//            return(nil)
//            }
//        return(objectFile.module.label)
        return("")
        }
        
    public func loadImportPath(topModule: TopModule)
        {
//        let manager = FileManager.default
//        var isDirectory:ObjCBool = false
//        guard manager.fileExists(atPath: self.path,isDirectory: &isDirectory),!isDirectory.boolValue else
//            {
//            return
//            }
//        let url = URL(fileURLWithPath: self.path)
//        guard let data = try? Data(contentsOf: url) else
//            {
//            return
//            }
//        guard let objectFile = try? ImportUnarchiver(forReadingFrom: data,loader: self,topModule: topModule).decodeTopLevelObject() as? ObjectFile else
//            {
//            return
//            }
//        self.moduleLabel = objectFile.module.label
//        self.rootModule = objectFile.module
//        self.rootModule.setParent(self)
//        for symbol in objectFile.module.symbolsByLabel.values
//            {
//            if !symbol.isSystemSymbol
//                {
//                self.symbolsByLabel[symbol.label] = symbol
//                }
//            }
        }
        
    ///
    ///
    /// NOTE: lookup(label:) in Import must not search the parent of the
    /// Import because the parent of an Import is a Module and a Module
    /// searches all of it's Imports which would result in an infinite loop.
    ///
    ///
    public override func lookup(label: Label) -> Symbol?
        {
        return(self.rootModule.lookup(label: label))
        }
        
//    public override func lookup(name: Name) -> Symbol?
//        {
//        return(self.rootModule.lookup(name: name))
//        }
    }
