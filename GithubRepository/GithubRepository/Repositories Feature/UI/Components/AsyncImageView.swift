//
//  AsyncImageView.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import SwiftUI

struct AsyncImageView<Placeholder: View>: View {
    private let placeholder: Placeholder
    private let url: URL
    
    @ObservedObject var viewModel: AsyncImageViewModel<UIImage>
    
    init(url: URL, viewModel: AsyncImageViewModel<UIImage>, placeholder: Placeholder) {
        self.url = url
        self.viewModel = viewModel
        self.placeholder = placeholder
    }

    var body: some View {
        content
            .onAppear {
                Task {
                    await viewModel.load(url: url)
                }
            }
    }
    
    private var content: some View {
        VStack {
            if let uiImage = viewModel.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholder
            }
        }
    }
}
