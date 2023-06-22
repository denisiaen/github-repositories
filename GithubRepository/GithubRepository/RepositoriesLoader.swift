//
//  RepositoriesLoader.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import Foundation

enum LoadRepositoriesResult {
    case success([RepositoryItem])
    case error(Error)
}

protocol RepositoriesLoader {
    func load(completion: @escaping (LoadRepositoriesResult) -> Void)
}
