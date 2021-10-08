//
//  Palette.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 25/9/21.
//

import AppKit

public struct Palette
    {
    public struct Scheme
        {
        public enum ColorKey
            {
            case lightest
            case light
            case mid
            case dark
            case darkest
            }
            
        public let lightest: NSColor
        public let light: NSColor
        public let mid: NSColor
        public let dark: NSColor
        public let darkest: NSColor
        
        public func color(atKey: ColorKey) -> NSColor
            {
            if atKey == .lightest
                {
                return(self.lightest)
                }
            else if atKey == .light
                {
                return(self.light)
                }
            else if atKey == .mid
                {
                return(self.mid)
                }
            else if atKey == .dark
                {
                return(self.dark)
                }
            else
                {
                return(self.darkest)
                }
            }
        }
        
    public static let shared = Palette()
    
    private init()
        {
        }
        
    public let brightScheme = Scheme(lightest: .argonPapayaWhip, light: .argonOpal, mid: .argonTartOrange, dark: .argonRuby, darkest: .argonDarkPurple)
    public let spreadScheme = Scheme(lightest: .argonSkyBlueCrayola, light: .argonBrightYellowCrayola, mid: .argonCaledonGreen, dark: .argonQuinacridoneMagenta, darkest: .argonRuby)
    public let oliveScheme = Scheme(lightest: .argonYellowOrange, light: .argonFulvous, mid: .argonBrown, dark: .argonRifleGreen, darkest: .argonJet)
//    public let sunnyScheme = Scheme(lightest: .argonSizzlingRed2, light: .argonSunglow, mid: .argonYellowGreen2, dark: .argonGreenBlueCrayola, darkest: .argonRoyalPurple)
    public let sunnyScheme = Scheme(lightest: NSColor(hex: 0xEFB0A1),light: NSColor(hex: 0xF4AFB4), mid: NSColor(hex: 0xC9B7AD), dark: NSColor(hex: 0x94A89A), darkest: NSColor(hex: 0x797D81))
    public let roseScheme = Scheme(lightest: NSColor(hex: 0xFF5E79),light: NSColor(hex: 0xE44867), mid: NSColor(hex: 0xB42D3F), dark: NSColor(hex: 0x755546), darkest: NSColor(hex: 0x5B5454))
    public let loudScheme = Scheme(lightest: NSColor(hex: 0xFF494F),light: NSColor(hex: 0xFFC72C), mid: NSColor(hex: 0x85C125), dark: NSColor(hex: 0x187CBA), darkest: NSColor(hex: 0x67498E))
    public let pastelScheme = Scheme(lightest: NSColor(hex: 0xBCF4DE),light: NSColor(hex: 0xCDE5D7), mid: NSColor(hex: 0xDED6D1), dark: NSColor(hex: 0xEEC6CA), darkest: NSColor(hex: 0xFFB7C3))
    public let chosenScheme = Scheme(lightest: NSColor(hex: 0xFF0054),light: NSColor(hex: 0xCE4257), mid: NSColor(hex: 0xFF7F51), dark: NSColor(hex: 0xFF9B54), darkest: NSColor(hex: 0xFF9500))
    public let neonScheme = Scheme(lightest: NSColor(hex: 0xF51475),light: NSColor(hex: 0x009063), mid: NSColor(hex: 0x80BD04), dark: NSColor(hex: 0xFD8F3F), darkest: NSColor(hex: 0x108080))
    public let yellowScheme = Scheme(lightest: NSColor(hex: 0xFFEECC),light: NSColor(hex: 0xFFD888), mid: NSColor(hex: 0xFFCD66), dark: NSColor(hex: 0xFFB622), darkest: NSColor(hex: 0xDD9400))
    public let spectralScheme = Scheme(lightest: NSColor(hex: 0xFF9248),light: NSColor(hex: 0xFF7249), mid: NSColor(hex: 0xFF5349), dark: NSColor(hex: 0xD05954), darkest: NSColor(hex: 0xB43F4B))
    public let greenScheme = Scheme(lightest: NSColor(hex: 0xE0E0E0),light: NSColor(hex: 0xA6D4C4), mid: NSColor(hex: 0x66BCB0), dark: NSColor(hex: 0x628B6B), darkest: NSColor(hex: 0x229282))
    
    public let primaryHighlightColor = NSColor.controlAccentColor
    public let textInset = CGSize(width: 10,height: 10)
    public let headerColor = NSColor.argonWindowFrameGray
    public let headerTextColor = NSColor.argonBrightYellowCrayola
    public let headerHeight:CGFloat = 24
    public let headerFont = NSFont(name: "SF Pro SemiBold",size: 16)
    public let objectBrowserTextColor = NSColor.argonAnnotationOrange
    public let classBrowserTextColor = NSColor.argonAnnotationOrange
    public let methodBrowserTextColor = NSColor.argonAnnotationOrange
    public let hierarchyBrowserSystemClassColor = NSColor.argonStoneTerrace
    public let sourceSelectedLineHighlightColor = NSColor.argonStoneTerrace
    
    public let compilationEventSelectionColor = NSColor.white
    
    public let classColor = NSColor(hex: 0xF25680)
    public let symbolColor = NSColor(hex: 0xD0D0D0)
    public let invokableColor = NSColor(hex: 0x009F76)
    public let methodColor:NSColor = .argonRuby
    public let moduleColor = NSColor(hex: 0xFFB257)
    public let typeAliasColor = NSColor(hex: 0xA0CC00)
    public let functionColor = NSColor(hex: 0xFE5299)
    public let slotColor = NSColor.argonCoral
    public let hierarchyTextColor = NSColor.white
    public let hierarchyGroupTextColor = NSColor.white
    public let hierarchySelectionColor = NSColor.argonBrightYellowCrayola
    public let hierarchyPrimaryTintColor = NSColor.argonBrightYellowCrayola
    public let hierarchySecondaryTintColor = NSColor.argonCaledonGreen
    public let hierarchyTertiaryTintColor = NSColor.argonSkyBlueCrayola

    public let compilationEventWarningSelectionColor = NSColor.argonNeonYellow
    public let compilationEventErrorSelectionColor = NSColor.argonNeonOrange
    public let compilationEventWarningColor = NSColor.argonNeonYellow
    public let compilationEventErrorColor = NSColor.argonNeonOrange
    public let compilationEventTextColor = NSColor.white
    public let compilationEventGroupColor = NSColor.argonSeaGreen
    
    public let compilationSelectedTextColor = NSColor.black
    
    public var currentScheme: Scheme
        {
        return(self.greenScheme)
        }
    }
