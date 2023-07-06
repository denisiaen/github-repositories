//
//  AsyncImageViewModel.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 27.06.2023.
//

import Foundation

public class AsyncImageViewModel: ObservableObject {
    let imageDataLoader: ImageDataLoader

    @Published public var data: Data?
    @Published public var error: Error?

    public init(imageDataLoader: ImageDataLoader) {
        self.imageDataLoader = imageDataLoader
    }

    @MainActor
    public func load(url: URL) async {
        do {
            data = try await imageDataLoader.load(url: url)
        } catch {
            self.error = error
        }
    }
}
