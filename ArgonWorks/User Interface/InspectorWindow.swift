//
//  InspectorView.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 23/7/21.
//

import SwiftUI

//struct InspectorWindow: View
//    {
//    private let someWords = 1024
//    
//    @State var startAddress: Word = 0
//    @State var endAddress: Word = 0
//    @State var wordCount: Int = 0
//    @State var isExpanded: Bool = false
//    
//    var body: some View
//        {
//        HStack
//            {
//            TextField("Start Address:",value: self.$startAddress,formatter: NumberFormatter())
//            TextField("End Address:",value: self.$endAddress,formatter: NumberFormatter())
//            TextField("Word Count:",value: self.$wordCount,formatter: NumberFormatter())
//            }
//        VStack
//            {
//            List
//                {
//                ForEach(self.loadNodes(),content: self.loadLayoutClosure())
//                }
//            }
//        }
//        
//    private typealias LayoutClosure = (AddressNode) -> AnyView
//    
//    private func loadLayoutClosure() -> LayoutClosure
//        {
//        let closure:LayoutClosure =
//            {
//            (node) -> AnyView in
//            AnyView(
//                VStack
//                    {
//                    HStack
//                        {
//                        Text(node.addressString).inspectorFont().foregroundColor(NSColor.argonNeonPink.swiftUIColor)
//                        Text(node.displayString).inspectorFont().foregroundColor(NSColor.argonNeonPink.swiftUIColor)
//                        }
//                    ForEach(node.children ?? [])
//                        {
//                        child in
//                        Text(child.displayString).inspectorFont().foregroundColor(NSColor.argonSeaGreen.swiftUIColor)
//                        let closure = self.loadLayoutClosure()
//                        List([child])
//                            {
//                            item in
//                            ForEach([item])
//                                {
//                                last in
//                                Text(node.displayString).inspectorFont().foregroundColor(NSColor.argonYellow.swiftUIColor)
//                                }
//                            }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)).foregroundColor(NSColor.argonLime.swiftUIColor)
//                        }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
//                    }
////
//              
//            )
//            }
//        return(closure)
//        }
//        
//        
//    private func loadNodes() -> Array<AddressNode>
//        {
//        let segment = VirtualMachine.shared.managedSegment
//        let start = segment.startOffset
//        let end = Int((segment.endOffset - start) / 8)
//        var offset = 0
//        var objects = Array<ObjectNode>()
//        let pointer = WordPointer(address: start)!
//        while offset < end
//            {
////            print("STARTING OBJECT AT \((Word(offset*8) + start).addressString)")
//            let objectNode = ObjectNode(address: Word(offset*8) + start)
//            let header = pointer[offset]
//            let size = Header(header).sizeInWords
//            offset += size
//            objects.append(objectNode)
//            }
//        return(objects)
//        }
//    }
//
//struct HeaderLineView: View
//    {
//    var node:AddressNode
//    
//    var body: some View
//        {
//        HStack
//            {
//            Text(node.addressString.aligned(.left,in:12)).inspectorFont()
//            Text(node.displayString.aligned(.left,in:80)).inspectorFont()
//            }.foregroundColor(.orange)
//        }
//    }
//    
//struct ExpandableLineView: View
//    {
//    var node: AddressNode
//    
//    var body: some View
//        {
//        VStack
//            {
//            if node.isExpandable
//                {
//                HeaderLineView(node: node)
//                List([node],children: \.children)
//                    {
//                    child in
//                    Text(child.displayString.aligned(.left,in:80)).inspectorFont()
//                    }
//                }
//            else
//                {
//                Text(node.displayString.aligned(.left,in:80)).inspectorFont()
//                }
//            }
//        }
//    }
//    
//struct InspectorView_Previews: PreviewProvider {
//    static var previews: some View {
//        InspectorWindow()
//    }
//}
//
//struct InspectorFont: ViewModifier
//    {
//    func body(content: Content) -> some View
//        {
//        content.font(Font.custom("Menlo",size: 11))
//        }
//    }
//
//extension View
//    {
//    func inspectorFont() -> some View
//        {
//        self.modifier(InspectorFont())
//        }
//    }
//
//class AddressNode:Identifiable
//    {
//    public var addressString: String
//        {
//        return("")
//        }
//        
//    public var isExpandable: Bool
//        {
//        return(false)
//        }
//        
//    public var hasErrors: Bool
//        {
//        get
//            {
//            return(false)
//            }
//        set
//            {
//            }
//        }
//        
//    public var displayString: String
//        {
//        return("AddressNode")
//        }
//        
//    public let id = UUID()
//    public var children: Array<AddressNode>?
//        {
//        return(nil)
//        }
//        
//    public func view() -> some View
//        {
//        Text(self.displayString)
//        }
//    }
//    
//class ObjectNode: AddressNode
//    {
//    public override var addressString: String
//        {
//        return(address.addressString)
//        }
//        
//    public override var isExpandable: Bool
//        {
//        return(true)
//        }
//        
//    public override var displayString: String
//        {
//        return("HEADER: \(self.header.bitString)")
//        }
//        
//    public override var children: Array<AddressNode>?
//        {
//        var children = Array<AddressNode>()
//        if !self.classPointer.isNil
//        {
//        for index in 1..<self.classPointer.slots.count
//            {
//            if self.classPointer.isNil
//                {
//                children.append(ChildAddressNode(word: self.wordPointer[index]))
//                }
//            else
//                {
//                let slot = self.classPointer.slot(atIndex: index)
//                let typeCode = slot.typeCode
//                if typeCode == 17
//                    {
//                    children.append(ArrayAddressNode(word: self.wordPointer[index]))
//                    }
//                else
//                    {
//                    children.append(ChildAddressNode(word: self.wordPointer[index]))
//                    }
//                }
//            }
//        for index in self.classPointer.slots.count..<self.wordCount
//            {
//            children.append(ChildAddressNode(word: self.wordPointer[index]))
//            }
//            }
//        else
//            {
//            for index in 1..<self.wordCount
//                {
//                let child = ChildAddressNode(word: self.wordPointer[index])
//                child.hasErrors = true
//                children.append(child)
//                }
//            }
//        return(children)
//        }
//        
//    private let address: Word
//    private let header: Header
//    private let wordCount: Int
//    private let wordPointer:WordPointer
//    private let classPointer: InnerClassPointer
//    
//    init(address: Word)
//        {
//        self.address = address
//        let pointer = WordPointer(address: address)!
//        self.wordPointer = pointer
//        let header = Header(pointer[0])
//        self.wordCount = header.sizeInWords
//        self.header = header
//        self.classPointer = InnerClassPointer(address: pointer[2])
//        }
//        
//    public func view() -> some View
//        {
//        OutlineGroup(self.children ?? [],children: \.children)
//            {
//            child in
//            Section(content:
//                {
//                child.view()
//                },
//            header:
//                {
//                Text(child.displayString)
//                })
//            }
//        }
//    }
//    
//class ArrayAddressNode: AddressNode
//    {
//    public override var addressString: String
//        {
//        return(word.addressString)
//        }
//        
//    public override var isExpandable: Bool
//        {
//        return(true)
//        }
//        
//    public override var displayString: String
//        {
//        return("ARRAY: \(self.word.bitString)")
//        }
//        
//    public override var children: Array<AddressNode>?
//        {
//        var children = Array<AddressNode>()
//        for index in 0..<self.arrayPointer.count
//            {
//            let aWord = self.arrayPointer[index]
//            children.append(ChildAddressNode(word: aWord))
//            }
//        return(children)
//        }
//        
//    public var word: Word
//    private let arrayPointer: InnerArrayPointer
//    
//    init(word: Word)
//        {
//        self.word = word
//        self.arrayPointer = InnerArrayPointer(address: word)
//        }
//        
//    public func view() -> some View
//        {
//        OutlineGroup(self.children ?? [],children: \.children)
//            {
//            child in
//            VStack
//                {
//                Text(child.displayString).inspectorFont()
//                child.view()
//                }.inspectorFont()
//            }
//        }
//    }
//
//class ChildAddressNode: AddressNode
//    {
//    public override var hasErrors: Bool
//        {
//        get
//            {
//            return(self._hasErrors)
//            }
//        set
//            {
//            self._hasErrors = newValue
//            }
//        }
//        
//    public override var displayString: String
//        {
//        return("CHILD: \(self.word.bitString)")
//        }
//        
//    private var _hasErrors: Bool = false
//    public var word: Word
//    
//    init(word: Word)
//        {
//        self.word = word
//        }
//        
//    public func view() -> some View
//        {
//        Text(self.displayString).inspectorFont()
//        }
//    }
