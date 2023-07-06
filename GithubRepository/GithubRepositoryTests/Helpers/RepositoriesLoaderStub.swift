//
//  RepositoriesLoaderStub.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 06.07.2023.
//

import Foundation
import GithubRepository

class RepositoriesLoaderStub: RepositoriesLoader {
    var invokedLoadCount = 0
    
    private var result: Result<[RepositoryItem], Error>
    
    init(result: Result<[RepositoryItem], Error>) {
        self.result = result
    }
    
    func load() async throws -> [RepositoryItem] {
        invokedLoadCount += 1
        return try result.get()
    }
}
