//
//  SlideUpModifier.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 18/7/24.
//

import SwiftUI

struct SlideUpModifier: ViewModifier {
    var isPresented: Bool

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                // Adjust the frame height to the desired portion of the screen
                .frame(height: geometry.size.height * 0.42) // Adjust this value as needed
                .frame(width: geometry.size.width)
                .offset(y: isPresented ? (geometry.size.height * 0.58) : geometry.size.height)
                .animation(.easeInOut, value: isPresented)
        }
    }
}

extension AnyTransition {
    static var slideUp: AnyTransition {
        AnyTransition.modifier(
            active: SlideUpModifier(isPresented: false),
            identity: SlideUpModifier(isPresented: true)
        )
    }
}


