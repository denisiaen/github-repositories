//
//  RepositoriesLoader.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import Foundation

public protocol RepositoriesLoader {
    func load() async throws -> [RepositoryItem]
}
