//
//  CircularAsyncImage.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import SwiftUI

public struct CircularAsyncImage<Placeholder: View>: View {
    let url: URL
    let placeholder: Placeholder
    var width: CGFloat
    
    public init(url: URL, placeholder: Placeholder, width: CGFloat = 24) {
        self.url = url
        self.placeholder = placeholder
        self.width = width
    }
    
    public var body: some View {
        asyncImage
    }
    
    @ViewBuilder
    var asyncImage: some View {
//        if #available(iOS 15.0, *) {
//            AsyncImage(url: url, content: asyncImagePhaseContent(phase:))
//        } else {
            AsyncImageView(url: url, placeholder: placeholder)
//        }
    }
    
    @available(iOS 15.0, *)
    @ViewBuilder
    func asyncImagePhaseContent(phase: AsyncImagePhase) -> some View {
        if let image = phase.image {
            // Displays the loaded image.
            image
                .resizable()
                .frame(width: width, height: width)
                .cornerRadius(width / 2)
        } else if phase.error != nil {
            placeholder
        } else {
            placeholder
        }
    }
}

struct CircularAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        CircularAsyncImage(url: URL(string: "")!, placeholder: Color.red)
    }
}
