//
//  AsyncImageView.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import SwiftUI

struct AsyncImageView<Placeholder: View>: View {
    private let placeholder: Placeholder
    
    @ObservedObject var viewModel: AsyncImageViewModel
    
    init(url: URL, imageDataLoader: () -> ImageDataLoader, placeholder: Placeholder) {
        self.viewModel = AsyncImageViewModel(imageDataLoader: imageDataLoader(), url: url)
        self.placeholder = placeholder
    }

    var body: some View {
        VStack {
            if let imageData = viewModel.data, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                               .resizable()
                               .aspectRatio(contentMode: .fit)
            } else {
                placeholder
            }
        }.onAppear {
            Task {
                await viewModel.viewDidAppear()
            }
        }
    }
}

class AsyncImageViewModel: ObservableObject {
    let imageDataLoader: ImageDataLoader
    let url: URL

    @Published public var data: Data?
    @Published public var error: Error?

    init(imageDataLoader: ImageDataLoader, url: URL) {
        self.imageDataLoader = imageDataLoader
        self.url = url
    }

    @MainActor
    func viewDidAppear() async {
        do {
            data = try await imageDataLoader.load(url: url)
        } catch {
            self.error = error
        }
    }
}
