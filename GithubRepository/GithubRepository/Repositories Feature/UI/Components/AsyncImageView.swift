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
    
    @ObservedObject var viewModel: AsyncImageViewModel
    
    init(url: URL, viewModel: AsyncImageViewModel, placeholder: Placeholder) {
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
            if let imageData = viewModel.data, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholder
            }
        }
    }
}

class AsyncImageViewModel: ObservableObject {
    let imageDataLoader: ImageDataLoader

    @Published public var data: Data?
    @Published public var error: Error?

    init(imageDataLoader: ImageDataLoader) {
        self.imageDataLoader = imageDataLoader
    }

    @MainActor
    func load(url: URL) async {
        do {
            data = try await imageDataLoader.load(url: url)
        } catch {
            self.error = error
        }
    }
}
