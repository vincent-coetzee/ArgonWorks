//
//
//
//
//
//

import Cocoa

public enum StyleFontIdentifier: String
    {
    case defaultFont
    case editorFont
    case labelFont
    case lineNumberFont
    case recordTextFont
    case textFont
    case toolbarLabelFont
    }
    
public enum StyleMetricIdentifier: String
    {
    case editorBorderWidth
    case editorBorderCornerRadius
    case lineNumberRulerWidth
    case lineNumberIndent
    case recordIconHeight
    case tabWidth
    }
    
public enum StyleColorIdentifier: String
    {
    case barBackgroundColor
    case booleanColor
    case buttonBackgroundColor
    case byteColor
    case characterColor
    case classColor
    case commentColor
    case constantColor
    case defaultBackgroundColor
    case defaultBorderColor
    case defaultColor
    case defaultOutlinerBackgroundColor
    case defaultSourceOutlinerBackgroundColor
    case editorBackgroundColor
    case editorBorderColor
    case editorTextColor
    case enumerationColor
    case errorColor
    case errorAnnotationColor
    case floatColor
    case functionColor
    case groupColor
    case importColor
    case identifierColor
    case integerColor
    case keywordColor
    case labelTextColor
    case labelBackgroundColor
    case lineColor
    case lineNumberColor
    case methodColor
    case moduleColor
    case nameColor
    case noIssuesColor
    case operatorColor
    case pathColor
    case projectColor
    case recordOutlinerBackgroundColor
    case recordBackgroundColor
    case recordSelectionColor
    case recordTextColor
    case rowSelectionColor
    case slotColor
    case stringColor
    case symbolColor
    case systemClassColor
    case systemTypeColor
    case textColor
    case toolbarLabelTextColor
    case typeColor
    case warningColor
    case warningAnnotationColor
    case versionColor
    }
    
@dynamicMemberLookup
public class Palette
    {
    public static let shared = Palette()
    
    private var colorStyles = Dictionary<StyleColorIdentifier,NSColor>()
    private var fontStyles = Dictionary<StyleFontIdentifier,NSFont>()
    private var metricStyles = Dictionary<StyleMetricIdentifier,Any>()
    
    public init()
        {
        self.fontStyles[.editorFont] = NSFont(name: "SunSans-SemiBold",size: 11)!
        self.fontStyles[.lineNumberFont] = self.fontStyles[.editorFont]
        self.metricStyles[.lineNumberIndent] = CGFloat(16)
        self.metricStyles[.lineNumberRulerWidth] = CGFloat(40 + 10)
        self.colorStyles[.defaultSourceOutlinerBackgroundColor] = NSColor.argonBlack80
        self.colorStyles[.defaultOutlinerBackgroundColor] = NSColor.argonBlack50
        self.colorStyles[.defaultColor] = NSColor.white
        self.fontStyles[.defaultFont] = NSFont(name: "SFProText-Regular",size: 11)!
        self.colorStyles[.defaultBackgroundColor] = NSColor.argonCoral
        self.colorStyles[.defaultBorderColor] = NSColor.clear
        self.metricStyles[.tabWidth] = CGFloat(4)
        self.metricStyles[.editorBorderCornerRadius] = CGFloat(5)
        self.colorStyles[.editorBorderColor] = NSColor.argonMidGray
        self.metricStyles[.editorBorderWidth] = CGFloat(1)
        self.colorStyles[.editorBackgroundColor] = NSColor.black
        self.colorStyles[.editorTextColor] = NSColor.argonNeonPink
        self.fontStyles[.toolbarLabelFont] = NSFont(name: "SunSans-Demi",size: 12)!
        self.colorStyles[.toolbarLabelTextColor] = NSColor.argonMidGray
        self.colorStyles[.keywordColor] = NSColor(red: 63,green: 149,blue: 116)
        self.colorStyles[.labelBackgroundColor] = NSColor.clear
        self.colorStyles[.labelTextColor] = NSColor.argonMidGray
        self.colorStyles[.buttonBackgroundColor] = NSColor.argonDarkerGray
        self.colorStyles[.noIssuesColor] = NSColor.argonNeonGreen
        self.colorStyles[.barBackgroundColor] = NSColor.argonBlack20
        self.colorStyles[.rowSelectionColor] = NSColor.argonDarkGray
        self.fontStyles[.textFont] = NSFont(name: "SunSans-SemiBold",size: 11)!
        self.colorStyles[.textColor] = NSColor.white
        self.colorStyles[.enumerationColor] = NSColor.argonThemeCyan
        self.colorStyles[.operatorColor] = NSColor.argonSalmonPink
        self.colorStyles[.classColor] = NSColor.argonLime
        self.colorStyles[.systemTypeColor] = NSColor.argonBrightYellowCrayola
        self.colorStyles[.identifierColor] = NSColor.argonThemePink
        self.colorStyles[.integerColor] = NSColor.argonZomp
        self.colorStyles[.symbolColor] = NSColor.argonSalmonPink
        self.colorStyles[.floatColor] = NSColor.argonSizzlingRed
        self.colorStyles[.stringColor] = NSColor.argonXBlue
        self.colorStyles[.nameColor] = NSColor.argonXIvory
        self.colorStyles[.commentColor] = NSColor(red: 145,green: 92,blue: 176)
        self.colorStyles[.byteColor] = NSColor.argonXSmoke
        self.colorStyles[.characterColor] = NSColor.argonXSmoke
        self.colorStyles[.lineNumberColor] = NSColor(hex: 0xA0A0A0)
        self.colorStyles[.methodColor] = NSColor.argonNeonOrange
        self.colorStyles[.typeColor] = NSColor.argonXIvory
        self.colorStyles[.functionColor] = NSColor.argonXSeaBlue
        self.colorStyles[.booleanColor] = NSColor.argonBayside
        self.colorStyles[.pathColor] = NSColor.argonZomp
        self.colorStyles[.groupColor] = NSColor.argonCheese
        self.colorStyles[.systemClassColor] = NSColor.argonCheese
        self.colorStyles[.moduleColor] = NSColor.argonZomp
        self.colorStyles[.projectColor] = NSColor.argonNeonPink
        self.colorStyles[.slotColor] = NSColor.argonCoral
        self.colorStyles[.constantColor] = NSColor.argonCheese
        self.colorStyles[.warningColor] = NSColor.argonSunglow
        self.colorStyles[.errorColor] = NSColor.argonSizzlingRed
        self.colorStyles[.recordTextColor] = NSColor.argonLightestGray
        self.fontStyles[.recordTextFont] = NSFont(name: "SunSans-SemiBold",size: 11)!
        self.colorStyles[.recordOutlinerBackgroundColor] = NSColor.argonBlack50
        self.colorStyles[.recordBackgroundColor] = NSColor.clear
        self.colorStyles[.recordSelectionColor] = NSColor.argonDarkGray
        self.colorStyles[.versionColor] = NSColor.argonXIvory
        self.colorStyles[.lineColor] = NSColor.argonWhite20
        self.metricStyles[.recordIconHeight] = self.font(for: .recordTextFont).lineHeight + 4
        self.colorStyles[.importColor] = NSColor.argonOpal
        }
        
    public func setFont(_ font: NSFont,for identifier: StyleFontIdentifier)
        {
        self.fontStyles[identifier] = font
        if identifier == .recordTextFont
            {
            self.metricStyles[.recordIconHeight] = font.lineHeight + 4
            }
        }
        
    public func float(for identifier: StyleMetricIdentifier) -> CGFloat
        {
        self.metricStyles[identifier] as! CGFloat
        }
        
    public func color(for identifier: StyleColorIdentifier) -> NSColor
        {
        self.colorStyles[identifier]!
        }
        
    public func font(for identifier: StyleFontIdentifier) -> NSFont
        {
        self.fontStyles[identifier]!
        }
        
    public subscript(dynamicMember dynamicMember: String) -> Any
        {
        if let identifier = StyleColorIdentifier(rawValue: dynamicMember)
            {
            return(self.color(for: identifier))
            }
        if let identifier = StyleFontIdentifier(rawValue: dynamicMember)
            {
            return(self.font(for: identifier))
            }
        if let identifier = StyleMetricIdentifier(rawValue: dynamicMember)
            {
            return(self.float(for: identifier))
            }
        fatalError("Unknown identifier")
        }
        
    public func recordTextAttributes() -> Dictionary<NSAttributedString.Key,Any>
        {
        var attributes = Dictionary<NSAttributedString.Key,Any>()
        attributes[.font] = self.font(for: .recordTextFont)
        attributes[.foregroundColor] = self.color(for: .recordTextColor)
        return(attributes)
        }
    }
