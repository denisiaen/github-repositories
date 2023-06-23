//
//  RepositoriesLoader.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import Foundation

public enum LoadRepositoriesResult {
    case success([RepositoryItem])
    case failure(Error)
}

protocol RepositoriesLoader {
    func load() async throws -> [RepositoryItem]
}
