//
//  CustomNavigationBar.swift
//  DK
//
//  Created by Dipin Krishna on 8/23/23.
//

import SwiftUI

struct CustomNavigationBar: View {
    var leftElement: (any View)? = Text("Back")
    var leftAction: (() -> Void)?
    var rightElement: (any View)?
    var rightAction: (() -> Void)?
    var title: (any View)?
    var inlineTitle: Bool? = true
    var backgroundColor: Color? = Color.black
    var foregroundColor: Color? = Color.white
    var height: CGFloat? = 44
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack (alignment: .top) {
                HStack {
                    Spacer()
                    if let title {
                        if let inlineTitle, inlineTitle {
                            AnyView(title)
                        }
                    }
                    Spacer()
                }.background(.clear).frame(maxHeight: .infinity)
                
                HStack (alignment: .center) {
                    if let leftElement {
                        Button(action: {
                            if let leftAction {
                                leftAction() // Invoke the left action closure
                            }
                        }) {
                            AnyView(leftElement)
                        }
                    }
                    
                    Spacer()
                    
                    if let rightElement {
                        Button(action: {
                            if let rightAction {
                                rightAction() // Invoke the right action closure
                            }
                        }) {
                            AnyView(rightElement)
                        }
                    }
                }.frame(maxHeight: .infinity)
            }
            .frame(height: height)
            
            if let inlineTitle, !inlineTitle {
                if let title {
                    HStack {
                        AnyView(title)
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
    }
}




struct CustomNavigationBar_Preview_1: View {
    var body: some View {
        CustomNavigationBar(
            leftElement: Text("Back"),
            leftAction: {
                // Left Action
            },
            rightElement: Text("Save"),
            rightAction: {
                // Left Action
            },
            title: Text("Title"),
            backgroundColor: Color.clear,
            foregroundColor: Color.black).padding(0)
        
    }
}

struct CustomNavigationBar_Preview_2: View {
    var body: some View {
        CustomNavigationBar(
            leftElement: Text("Back"),
            rightElement: Text("Save"),
            title: Text("Title").font(.subheadline),
            backgroundColor: Color.black,
            foregroundColor: Color.white).padding(0)
    }
}

struct CustomNavigationBar_Preview_3: View {
    var body: some View {
        CustomNavigationBar(
            leftElement: Image(systemName: "arrowshape.backward.fill"),
            title: Text("Title")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle),
            inlineTitle: false,
            backgroundColor: Color.blue,
            foregroundColor: Color.white).padding(0)
    }
}

struct CustomNavigationBar_Preview_4: View {
    var body: some View {
        CustomNavigationBar(
            leftElement: Text("Title")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle),
            rightElement: Text("Close"),
            backgroundColor: Color.red,
            foregroundColor: Color.white).padding(0)
    }
}

struct CustomNavigationBar_Preview_5: View {
    var body: some View {
        CustomNavigationBar(
            leftElement: Text("Title")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle),
            rightElement: Image(systemName: "xmark.circle").font(.largeTitle),
            backgroundColor: Color.green,
            foregroundColor: Color.white,
            height: 100).padding(0)
    }
}

#Preview {
    VStack (alignment: .leading) {
        CustomNavigationBar_Preview_1()
        CustomNavigationBar_Preview_2()
        CustomNavigationBar_Preview_3()
        CustomNavigationBar_Preview_4()
        CustomNavigationBar_Preview_5()
        Spacer()
    }.padding(0)
}

// Screenshot: https://dipinkrishna.com/wp-content/uploads/2023/08/Custom-Navigation-Bar-1.png
// Article: https://dipinkrishna.com/blog/2023/08/swiftui-create-a-custom-navigation-bar/
