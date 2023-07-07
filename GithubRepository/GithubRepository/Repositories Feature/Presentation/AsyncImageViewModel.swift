//
//  AsyncImageViewModel.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 27.06.2023.
//

import Foundation

public class AsyncImageViewModel<Image>: ObservableObject {
    let imageDataLoader: ImageDataLoader
    let imageTransformer: (Data) -> Image?

    @Published public var image: Image?
    @Published public var error: Error?

    public init(imageDataLoader: ImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.imageDataLoader = imageDataLoader
        self.imageTransformer = imageTransformer
    }

    @MainActor
    public func load(url: URL) async {
        do {
            let data = try await imageDataLoader.load(url: url)
            image = imageTransformer(data)
        } catch {
            self.error = error
        }
    }
}
