//
//  NSImage+Extensions.swift
//  ArgonWorks
//
//  Created by Vincent Coetzee on 27/9/21.
//

import AppKit

extension NSImage
    {
   func image(withTintColor tintColor: NSColor) -> NSImage
        {
        guard isTemplate else
            {
            return self
            }
       guard let copiedImage = self.copy() as? NSImage else
            {
            return self
            }
       copiedImage.lockFocus()
       tintColor.set()
       let imageBounds = NSMakeRect(0, 0, copiedImage.size.width, copiedImage.size.height)
       imageBounds.fill(using: .sourceAtop)
       copiedImage.unlockFocus()
       copiedImage.isTemplate = false
       return copiedImage
       }
    }
