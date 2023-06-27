//
//  LottieView.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import SwiftUI
import Lottie

public struct LottieView: UIViewRepresentable {
    var name: String

    public init(name: String) {
        self.name = name
    }
    
    public func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) { }
}
