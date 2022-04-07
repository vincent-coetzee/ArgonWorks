//
//
//
//
//
//

import Cocoa

public enum StyleIdentifier: String
    {
    case none
    case defaultColor
    case rowSelectionColor
    case editorBackgroundColor
    case editorTextColor
    case editorFont
    case textFont
    case textColor
    case operatorColor
    case keywordColor
    case classColor
    case systemTypeColor
    case identifierColor
    case integerColor
    case symbolColor
    case floatColor
    case stringColor
    case enumerationColor
    case nameColor
    case commentColor
    case byteColor
    case characterColor
    case lineNumberColor
    case methodColor
    case typeColor
    case functionColor
    case booleanColor
    case pathColor
    case groupColor
    case moduleColor
    case projectColor
    case slotColor
    case constantColor
    case warningColor
    case errorColor
    case warningAnnotationColor
    case errorAnnotationColor
    case recordTextColor
    case recordTextFont
    case recordBackgroundColor
    case recordSelectionColor
    case versionColor
    case lineColor
    case recordIconHeight
    case importColor
    }
    
@dynamicMemberLookup
public class Palette
    {
    public static let shared = Palette()
    
    private var styles = Dictionary<StyleIdentifier,Any>()
    
    public init()
        {
        self.styles[.rowSelectionColor] = NSColor.argonDarkGray
        self.styles[.editorBackgroundColor] = NSColor.black
        self.styles[.editorTextColor] = NSColor.argonNeonPink
        self.styles[.editorFont] = NSFont(name: "SunSans-SemiBold",size: 11)!
        self.styles[.textFont] = NSFont(name: "SunSans-SemiBold",size: 11)!
        self.styles[.textColor] = NSColor.white
        self.styles[.enumerationColor] = NSColor.argonThemeCyan
        self.styles[.operatorColor] = NSColor.argonSalmonPink
        self.styles[.keywordColor] = NSColor(red: 63,green: 149,blue: 116)
        self.styles[.classColor] = NSColor.argonLime
        self.styles[.systemTypeColor] = NSColor.argonBrightYellowCrayola
        self.styles[.identifierColor] = NSColor.argonThemePink
        self.styles[.integerColor] = NSColor.argonZomp
        self.styles[.symbolColor] = NSColor.argonSalmonPink
        self.styles[.floatColor] = NSColor.argonSizzlingRed
        self.styles[.stringColor] = NSColor.argonXBlue
        self.styles[.nameColor] = NSColor.argonXIvory
        self.styles[.commentColor] = NSColor(red: 145,green: 92,blue: 176)
        self.styles[.byteColor] = NSColor.argonXSmoke
        self.styles[.characterColor] = NSColor.argonXSmoke
        self.styles[.lineNumberColor] = NSColor(hex: 0xA0A0A0)
        self.styles[.methodColor] = NSColor.argonNeonOrange
        self.styles[.typeColor] = NSColor.argonXIvory
        self.styles[.functionColor] = NSColor.argonXSeaBlue
        self.styles[.booleanColor] = NSColor.argonBayside
        self.styles[.pathColor] = NSColor.argonZomp
        self.styles[.groupColor] = NSColor.argonCheese
        self.styles[.moduleColor] = NSColor.argonZomp
        self.styles[.projectColor] = NSColor.argonNeonPink
        self.styles[.slotColor] = NSColor.argonCoral
        self.styles[.constantColor] = NSColor.argonCheese
        self.styles[.warningColor] = NSColor.argonSunglow
        self.styles[.errorColor] = NSColor.argonSizzlingRed
        self.styles[.warningAnnotationColor] = NSColor.argonCheese
        self.styles[.errorAnnotationColor] = NSColor.argonPersianRose
        self.styles[.recordTextColor] = NSColor.white
        self.styles[.recordTextFont] = NSFont(name: "SunSans-SemiBold",size: 11)!
        self.styles[.recordBackgroundColor] = NSColor.clear
        self.styles[.recordSelectionColor] = NSColor.argonDarkGray
        self.styles[.versionColor] = NSColor.argonXIvory
        self.styles[.defaultColor] = NSColor.white
        self.styles[.lineColor] = NSColor.argonWhite20
        self.styles[.recordIconHeight] = self.font(for: .recordTextFont).lineHeight + 4
        self.styles[.importColor] = NSColor.argonOpal
        }
        
    public func setFont(_ font: NSFont,for identifier: StyleIdentifier)
        {
        self.styles[identifier] = font
        if identifier == .recordTextFont
            {
            self.styles[.recordIconHeight] = font.lineHeight + 4
            }
        }
        
    public func float(for identifier: StyleIdentifier) -> CGFloat
        {
        self.styles[identifier] as! CGFloat
        }
        
    public func color(for identifier: StyleIdentifier) -> NSColor
        {
        self.styles[identifier] as! NSColor
        }
        
    public func font(for identifier: StyleIdentifier) -> NSFont
        {
        self.styles[identifier] as! NSFont
        }
        
    public subscript(dynamicMember dynamicMember: String) -> NSColor
        {
        let key = StyleIdentifier(rawValue: dynamicMember)!
        return(self.styles[key] as! NSColor)
        }
    }
