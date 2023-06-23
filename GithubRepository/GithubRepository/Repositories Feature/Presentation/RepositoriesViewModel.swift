//
//  RepositoriesViewModel.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import Foundation

public class RepositoriesViewModel: ObservableObject {
    
    private let repositoriesLoader: RepositoriesLoader
    
    @Published public var repositoryItems = [RepositoryItem]()
    @Published public var isLoading = false
    @Published public var error: Error?
    
    public init(repositoriesLoader: RepositoriesLoader) {
        self.repositoriesLoader = repositoriesLoader
    }
    
    @MainActor
    public func viewDidAppear() async {
        isLoading = true

        defer {
            isLoading = false
        }
        
        do {
            repositoryItems = try await repositoriesLoader.load()
        } catch {
            self.error = error
        }
    }
}