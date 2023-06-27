//
//  AsyncImageViewModel.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 27.06.2023.
//

import Foundation

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
