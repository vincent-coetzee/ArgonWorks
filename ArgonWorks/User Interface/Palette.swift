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
        public let lightest: NSColor
        public let light: NSColor
        public let mid: NSColor
        public let dark: NSColor
        public let darkest: NSColor
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
    
    public let primaryHighlightColor = NSColor.controlAccentColor
    public let textInset = CGSize(width: 10,height: 10)
    public let headerColor = NSColor.argonHeaderGray
    public let headerTextColor = NSColor.argonDarkPurple
    public let headerHeight:CGFloat = 24
    public let headerFont = NSFont(name: "SF Pro Bold",size: 14)
    public let objectBrowserTextColor = NSColor.argonAnnotationOrange
    public let classBrowserTextColor = NSColor.argonAnnotationOrange
    public let methodBrowserTextColor = NSColor.argonAnnotationOrange
    public let hierarchyBrowserSystemClassColor = NSColor.argonStoneTerrace
    public let sourceSelectedLineHighlightColor = NSColor.argonStoneTerrace
    }
