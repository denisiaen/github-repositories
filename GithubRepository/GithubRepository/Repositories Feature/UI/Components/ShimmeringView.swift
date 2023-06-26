//
//  ShimmeringView.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import Foundation
import SwiftUI

public extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

public struct ShimmerModifier: ViewModifier {
    public func body(content: Content) -> some View {
        ShimmeringView() { content }
    }
}

struct ShimmeringView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let content: () -> Content
        
    @State private var startPoint: UnitPoint = UnitPoint(x: -1, y: 0.5)
    @State private var endPoint: UnitPoint = .leading
    
    private var shimmerColor: Color {
        return colorScheme == .dark ? Color.white : Color.black
    }
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    private var gradient: LinearGradient {
        let gradient = Gradient(stops: [
            .init(color: .black, location: 0),
            .init(color: .white, location: 0.5),
            .init(color: .black, location: 1),
        ])
        return LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
    }
    
    var body: some View {
        ZStack {
            content()
            gradient
                .opacity(0.6)
                .blendMode(.screen)
                .onAppear {
                    withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        startPoint = .trailing
                        endPoint = UnitPoint(x: 2, y: 0.5)
                    }
                }
        }
    }
}
