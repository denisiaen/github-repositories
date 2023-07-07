//
//  ErrorView.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import SwiftUI

struct ErrorView: View {
    var animationName: String
    var action: () -> Void
    
    init(animationName: String, action: @escaping () -> Void) {
        self.animationName = animationName
        self.action = action
    }
    
    var body: some View {
        VStack {
            lottieAnimation
                .padding(.bottom, 100)
            retryButton
                .padding()
                .padding(.bottom, 30)
        }
    }
    
    var lottieAnimation: some View {
        LottieView(name: animationName)
    }
    
    var retryButton: some View {
        Button(action: action) {
            Text("Retry")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.green)
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(.green, lineWidth: 1))
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(animationName: "retry-and-user-busy-version-2", action: {})
    }
}
