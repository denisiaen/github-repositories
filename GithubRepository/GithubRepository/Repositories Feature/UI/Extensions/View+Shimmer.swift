//
//  View+Shimmer.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 27.06.2023.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func shimmer(_ isShimmering: Bool) -> some View {
        if isShimmering {
            modifier(ShimmeringViewModifier())
        } else {
            self
        }
    }
}

struct ShimmeringViewModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .modifier(
                AnimatedMask(phase: phase)
                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false))
            )
            .onAppear {
                phase = 0.8
            }
    }
}

struct AnimatedMask: AnimatableModifier {
    @Environment(\.colorScheme) private var colorScheme

    private var color: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var phase: CGFloat = 0
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: color.opacity(0.5), location: phase),
                .init(color: color, location: phase + 0.1),
                .init(color: color.opacity(0.5), location: phase + 0.2)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    func body(content: Content) -> some View {
        content
            .mask(gradient.scaleEffect(3))
    }
}
