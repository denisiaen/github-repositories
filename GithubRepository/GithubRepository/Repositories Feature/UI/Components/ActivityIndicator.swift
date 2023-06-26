//
//  ActivityIndicator.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import Foundation
import SwiftUI

public struct ActivityIndicator: View {
    
    @State private var isAnimating: Bool = false
    private var strokeColor: Color
    private var size: CGFloat
    private var lineWidth: CGFloat
    
    public init(strokeColor: Color = .gray, size: CGFloat = 20, lineWidth: CGFloat = 1.5) {
        self.strokeColor = strokeColor
        self.size = size
        self.lineWidth = lineWidth
    }

    public var body: some View {
        Circle()
            .trim(from: 0.2, to: 1)
            .stroke(
                strokeColor,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                )
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: isAnimating)
            .onAppear {
                self.isAnimating = true
            }
            .onDisappear {
                self.isAnimating = false
            }
    }
}
