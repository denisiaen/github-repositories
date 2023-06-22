//
//  RepositoryItem.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import Foundation

public struct RepositoryItem: Equatable {
    let id: UUID
    let userName: String
    let imageURL: URL
    let repositoryName: String
    let description: String?
    let language: String?
    let starts: Int?
}
