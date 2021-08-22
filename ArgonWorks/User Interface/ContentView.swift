//
//  ContentView.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import SwiftUI
import AppKit

//struct ContentView: View
//    {
//    @State var sheetPresentationTag:Int? = nil
//    @State var isPresentingSheet:Bool = true
//    @State var newItemName: String = ""
//    @State var sheetWasCancelled: Bool = false
//    @State var showNewModulePopover: Bool = false
//    @State var newItemViewTag: String?
//    @State var newItemNameField: String = ""
//
//    var body: some View
//        {
//        NavigationView
//            {
//            List([ArgonModule.argonModule], children: \.children)
//                {
//                item in
//                NavigationLink(destination: self.editorView(for: item))
//                    {
//                    HStack
//                        {
//                        SwiftUI.Label(title:
//                            {
//                            VStack
//                                {
//                                Text(item.displayName)
//                                }
//                            },
//                        icon:
//                            {
//                            Image(nsImage: NSImage(named: item.imageName)!)
//                                .resizable()
//                                .renderingMode(.original)
//                                .renderingMode(.template)
//                                .foregroundColor(item.symbolColor.swiftUIColor)
//                                .aspectRatio(1, contentMode: .fill)
//                                .frame(width:16,height:16)
//                        }).frame(maxHeight: 16,alignment:.leading)
//                        item.newItemButton(self.$newItemViewTag)
//                        }
//                    }
////                if item.isModule && self.newItemViewTag == "module"
////                    {
////                    item.newItemView(self.$newItemNameField)
////                    }
//                }
//                .toolbar
//                    {
//                    Button(action: newModule)
//                            {
//                            Image(nsImage: NSImage(named:"IconModule")!)
//                                .resizable()
//                                .aspectRatio(1,contentMode: .fit)
//                                .frame(maxWidth: 20,maxHeight: 20)
//                            }
//                    Button(action: newClass)
//                            {
//                            Image(nsImage: NSImage(named:"IconClass")!)
//                                .resizable()
//                                .aspectRatio(1,contentMode: .fit)
//                                .frame(maxWidth: 20,maxHeight: 20)
//                            }
//                    Button(action: newClass)
//                            {
//                            Image(nsImage: NSImage(named:"IconSlot")!)
//                                .resizable()
//                                .aspectRatio(1,contentMode: .fit)
//                                .frame(maxWidth: 20,maxHeight: 20)
//                            }
//                    }
//            }
//        }
//    
//    private func newModuleSheet() -> some View
//        {
//        VStack
//            {
//            Text("New Module").font(.title)
//            Spacer()
//            TextField("Module Name:",text: self.$newItemName)
//            Spacer()
//            HStack
//                {
//                Button
//                    {
//                    self.showNewModulePopover = false
//                    self.sheetWasCancelled = true
//                    }
//                label:
//                    {
//                    Text("Cancel")
//                    }.padding(10)
//                Button
//                    {
//                    self.showNewModulePopover = false
//                    self.sheetWasCancelled = false
//                    }
//                label:
//                    {
//                    Text("OK")
//                    }.padding(10)
//                }.padding(40)
//            }.padding(60)
//        }
//        
//    private func newClass()
//        {
//        }
//        
//    private func newModule()
//        {
//        self.showNewModulePopover = true
//        }
//        
//    private func editorView(for item:Symbol) -> some View
//        {
//        if item is Class
//            {
//            return AnyView(Group{ClassEditingView(someClass: item as! Class)})
//            }
//        else
//            {
//            return AnyView(Group{EmptyView()})
//            }
//        }
//    }
//
//    
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//let classes = [Class(label:"Class1"),Class(label:"Class2"),Class(label:"Class3")]
//let modules = [Module(label:"Module1"),Module(label:"Module2")]
//let testData = [Module(label:"Main Module").addSymbols(modules).addSymbols(classes)]
//
//
//struct ContextualMenu: View
//    {
//    @Binding var document: ProjectDocument
//    var isSheetPresented:Binding<Bool>
//    var body: some View
//        {
//        Group
//            {
//            ModuleMenuGroup(document: $document,isSheetPresented: self.isSheetPresented)
//            ClassMenuGroup(document: $document)
//            MethodMenuGroup(document: $document)
//            }
//        }
//    }
//
//
//struct MethodMenuGroup: View
//    {
//    @Binding var document: ProjectDocument
//    
//    var body: some View
//        {
//        Button(action: {},label: {Text("New method...")})
//        Button(action: {},label: {Text("New function...")})
//        }
//    }
//
//struct ModuleMenuGroup: View
//    {
//    @Binding var document: ProjectDocument
//    var isSheetPresented:Binding<Bool>
//    
//    var body: some View
//        {
//        Group
//            {
//            Button(action: {self.isSheetPresented.wrappedValue = true},label: {IconTextCell("New Module...","IconModule")})
//            Button(action: {},label: {Text("New Import...")})
//            Divider()
//            }
//        }
//    }
//    
//struct ClassMenuGroup: View
//    {
//    @Binding var document: ProjectDocument
//    
//    var body: some View
//        {
//        Button(action: {},label: {Text("New class...")})
//        Button(action: {},label: {Text("New initializer...")})
//        Button(action: {},label: {Text("New enumeration...")})
//        Button(action: {},label: {Text("New slot...")})
//        Button(action: {},label: {Text("New constant...")})
//        Button(action: {},label: {Text("New type...")})
//        Divider()
//        }
//    }
//
//struct IconTextCell: View
//    {
//    let text:String
//    let iconName:String
//    
//    init(_ text:String,_ name:String)
//        {
//        self.text = text
//        self.iconName = name
//        }
//        
//    var body: some View
//        {
//        HStack
//            {
//            Image(iconName)
//            Text(text)
//            }
//        }
//    }
