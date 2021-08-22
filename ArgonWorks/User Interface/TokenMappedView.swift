//
//  TokenMappedView.swift
//  TokenMappedView
//
//  Created by Vincent Coetzee on 5/8/21.
//

import SwiftUI
import Combine

//struct TokenView_Previews: PreviewProvider
//    {
//    @State static var source = Argon.sampleSource
//    
//    static var previews: some View
//        {
//        TokenMappingView(source: self.$source)
//        }
//    }
//
//class TokenMappingViewController: NSViewController
//    {
//    var textView = LineNumberTextView()
//    internal var source: String = ""
//    internal var compiler: Compiler = Compiler()
//    
//    override func loadView()
//        {
//        let scrollView = NSScrollView()
//        scrollView.hasVerticalScroller = true
//        textView.autoresizingMask = [.width]
//        textView.allowsUndo = true
//        textView.font = NSFont(name:"Menlo",size:11)!
//        scrollView.documentView = textView
//        textView.backgroundColor = SyntaxColorPalette.backgroundColor
//        textView.gutterBackgroundColor = SyntaxColorPalette.backgroundColor
//        textView.gutterForegroundColor = SyntaxColorPalette.lineNumberColor
//        textView.initOutsideNib()
//        self.view = scrollView
//        }
//    
//    override func viewDidAppear()
//        {
//        self.view.window?.makeFirstResponder(self.view)
//        }
//        
//    public func setSource(_ source:String)
//        {
//        compiler.compileChunk(source)
//        self.view.setNeedsDisplay(.zero)
//        }
//    }
//
//struct TokenMappingView: NSViewControllerRepresentable
//    {
//    @Binding var source: String
//    
//    func makeCoordinator() -> Coordinator
//        {
//        return Coordinator(self)
//        }
//    
//    class Coordinator: NSObject, NSTextStorageDelegate
//        {
//        private var parent: TokenMappingView
//        var shouldUpdateText = true
//        
//        init(_ parent: TokenMappingView)
//            {
//            self.parent = parent
//            }
//        
//        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int)
//            {
////            guard shouldUpdateText else {
////                return
////            }
////            let edited = textStorage.attributedSubstring(from: editedRange).string
////            let insertIndex = parent.text.utf16.index(parent.text.utf16.startIndex, offsetBy: editedRange.lowerBound)
////
////            func numberOfCharactersToDelete() -> Int
////                {
////                editedRange.length - delta
////                }
////            let endIndex = parent.text.utf16.index(insertIndex, offsetBy: numberOfCharactersToDelete())
////            self.parent.text.replaceSubrange(insertIndex..<endIndex, with: edited)
//            }
//        }
//
//    func makeNSViewController(context: Context) -> TokenMappingViewController
//        {
//        let vc = TokenMappingViewController()
//        vc.textView.textStorage?.delegate = context.coordinator
//        vc.textView.textStorage?.setAttributedString(NSAttributedString(string: self.$source.wrappedValue,attributes: [:]))
//        return vc
//        }
//    
//    func updateNSViewController(_ nsViewController: TokenMappingViewController, context: Context)
//        {
//        let compiler = Compiler()
//        compiler.compileChunk(self.$source.wrappedValue)
//        let token = compiler.tokenRenderer
//        nsViewController.textView.textStorage?.beginEditing()
//        for (range,attributes) in token.mappings
//            {
//            nsViewController.textView.textStorage?.setAttributes(attributes,range: range)
//            }
//        nsViewController.textView.textStorage?.endEditing()
//        }
//    }
