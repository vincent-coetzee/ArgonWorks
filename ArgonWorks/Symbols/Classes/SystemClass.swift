//
//  SystemClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class SystemClass:Class
    {
    public override var isSystemSymbol: Bool
        {
        return(true)
        }
        
    public override var typeCode:TypeCode
        {
        return(self._typeCode)
        }
        
    public override var isSystemClass: Bool
        {
        return(true)
        }
        
    private let _typeCode:TypeCode
    
    init(label:Label,typeCode:TypeCode = .class)
        {
        self._typeCode = typeCode
        super.init(label: label)
        }
        
//    ///
//    ///
//    /// This method returns an instance of a surrogate class during archiving to make
//    /// sure that system classes are not archived but rather markers for them. When an
//    /// archive in unarchived, the markers are replaced with the real system classes. This
//    /// allows for multiple archives to be loaded into the same environment and have them
//    /// all use the same common system classes rather than carrying around copies of
//    /// their own system classes. The companion method on SystemClassSurrogate
//    /// is awakeAfterUserCoder: which looks up the correct system classes and
//    /// substitutes them for the markers.
//    ///
//    ///
//    public override func replacementObject(for coder: NSCoder) -> Any?
//        {
//        return(SystemClassSurrogate(systemClassIndex: self.index))
//        }
    ///
    ///
    /// Don't mess with the names of this method or the next one because they are here solely
    /// for the use of the ArgonModule.
    ///
    ///
    init(label:Label,superclasses:Array<Label>,typeCode:TypeCode = .none)
        {
        self._typeCode = typeCode
        super.init(label:label)
        self.superclassReferences = superclasses.map{ForwardReferenceClass(name:Name($0))}
        }
    
    public required init?(coder: NSCoder)
        {
        print("DECODE SystemClass")
        self._typeCode = .class
        super.init(coder: coder)
        }
        
 
}
